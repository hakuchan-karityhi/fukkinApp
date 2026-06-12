#!/bin/bash
# チケット番号から feature ブランチを用意し、並行作業用 worktree をセットアップする
#
# 使い方:
#   scripts/git/start-ticket.sh <ticket> [--checkout | --worktree] [--base develop]
#
# 例:
#   scripts/git/start-ticket.sh 009              # develop 上ならメイン checkout で 009
#   scripts/git/start-ticket.sh 011              # 既に feature 中なら worktree を追加
#   scripts/git/start-ticket.sh mvp/011 --worktree
#   scripts/git/start-ticket.sh beta/009 --checkout
#
# 詳細: devPolicy/branch/branchRule.md / scripts/git/new-branch.sh
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/git/start-ticket.sh <ticket> [options]

<ticket>  チケット番号（例: 009, 11, mvp/011, beta/009）

Options:
  --checkout   メインの checkout でブランチを切り替える（new-branch.sh 相当）
  --worktree   別ディレクトリに worktree を追加（2ウィンドウ並行作業向け）
  --base BR    分岐元ブランチ（既定: develop）
  --no-setup   flutter pub get をスキップ
  -h, --help   このヘルプを表示

モード省略時:
  現在 develop / main / mvp / beta / release 上 → --checkout
  それ以外の feature ブランチ上           → --worktree

worktree の配置先:
  <リポジトリの親>/<リポジトリ名>-<チケット番号>
  例: .../syumi/fukkin-011

EOF
}

die() {
  echo "ERROR: $*" >&2
  exit 1
}

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || die "Git リポジトリ内で実行してください"
cd "$REPO_ROOT"

TICKET_ARG=""
MODE=""
BASE_BRANCH="develop"
RUN_SETUP=true

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --checkout|--worktree)
      MODE="${1#--}"
      shift
      ;;
    --base)
      [[ $# -ge 2 ]] || die "--base にはブランチ名が必要です"
      BASE_BRANCH="$2"
      shift 2
      ;;
    --no-setup)
      RUN_SETUP=false
      shift
      ;;
    -*)
      die "不明なオプションです: $1"
      ;;
    *)
      [[ -z "$TICKET_ARG" ]] || die "チケット番号は1つだけ指定してください"
      TICKET_ARG="$1"
      shift
      ;;
  esac
done

[[ -n "$TICKET_ARG" ]] || { usage; exit 1; }

PHASE=""
TICKET_NUM=""
if [[ "$TICKET_ARG" =~ ^(mvp|beta)/([0-9]+)$ ]]; then
  PHASE="${BASH_REMATCH[1]}"
  TICKET_NUM="${BASH_REMATCH[2]}"
elif [[ "$TICKET_ARG" =~ ^[0-9]+$ ]]; then
  TICKET_NUM="$TICKET_ARG"
else
  die "チケット番号の形式が不正です: $TICKET_ARG（例: 009, mvp/011）"
fi

TICKET_PADDED="$(printf '%03d' "$TICKET_NUM")"

find_ticket_file() {
  local phase="$1"
  local num_padded="$2"
  local num_raw="$3"
  local p ticket_file

  for p in mvp beta; do
    [[ -z "$phase" || "$phase" == "$p" ]] || continue
    for num in "$num_padded" "$num_raw"; do
      shopt -s nullglob
      local matches=(tickets/"$p"/"$num"-*.md)
      shopt -u nullglob
      if [[ ${#matches[@]} -eq 1 ]]; then
        echo "${matches[0]}"
        return 0
      fi
      if [[ ${#matches[@]} -gt 1 ]]; then
        die "チケット $num が複数見つかりました: ${matches[*]}（フェーズを指定してください）"
      fi
    done
  done
  return 1
}

TICKET_FILE="$(find_ticket_file "$PHASE" "$TICKET_PADDED" "$TICKET_NUM")" \
  || die "チケットが見つかりません: $TICKET_ARG（tickets/mvp または tickets/beta を確認）"

TICKET_BASENAME="$(basename "$TICKET_FILE" .md)"
BRANCH_NAME="feature/${TICKET_BASENAME}"
CURRENT_BRANCH="$(git branch --show-current)"
REPO_NAME="$(basename "$REPO_ROOT")"
WORKTREE_PATH="$(dirname "$REPO_ROOT")/${REPO_NAME}-${TICKET_PADDED}"

LONG_LIVED_BRANCHES=(develop main mvp beta release)

is_long_lived() {
  local b="$1"
  local lb
  for lb in "${LONG_LIVED_BRANCHES[@]}"; do
    [[ "$b" == "$lb" ]] && return 0
  done
  return 1
}

if [[ -z "$MODE" ]]; then
  if is_long_lived "$CURRENT_BRANCH"; then
    MODE="checkout"
  else
    MODE="worktree"
  fi
fi

git show-ref --verify --quiet "refs/heads/$BASE_BRANCH" \
  || die "分岐元ブランチが存在しません: $BASE_BRANCH"

run_flutter_setup() {
  local dir="$1"
  if [[ "$RUN_SETUP" != true ]]; then
    return 0
  fi
  if [[ -f "$dir/app/pubspec.yaml" ]]; then
    echo ""
    echo "Flutter 依存関係を取得しています..."
    (cd "$dir/app" && flutter pub get)
  fi
}

print_worktree_hint() {
  echo ""
  echo "次のステップ:"
  echo "  1. Cursor で File → New Window"
  echo "  2. Open Folder → $WORKTREE_PATH"
  echo "  3. このウィンドウ（$REPO_ROOT）は $CURRENT_BRANCH のまま作業を続けられます"
}

echo "チケット:     $TICKET_FILE"
echo "ブランチ:     $BRANCH_NAME"
echo "分岐元:       $BASE_BRANCH"
echo "モード:       $MODE"
echo ""

if [[ "$MODE" == "checkout" ]]; then
  if [[ "$(git branch --show-current)" == "$BRANCH_NAME" ]]; then
    echo "すでに $BRANCH_NAME 上です"
  elif git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    echo "既存ブランチに切り替えます: $BRANCH_NAME"
    git checkout "$BRANCH_NAME"
  else
    echo "ブランチを作成して切り替えます..."
    "$REPO_ROOT/scripts/git/new-branch.sh" feature "$TICKET_BASENAME" "$BASE_BRANCH"
  fi

  run_flutter_setup "$REPO_ROOT"

  echo ""
  echo "準備完了: $BRANCH_NAME @ $REPO_ROOT"
  exit 0
fi

# --- worktree モード ---
if git worktree list --porcelain | grep -q "^worktree $WORKTREE_PATH$"; then
  echo "worktree は既に存在します: $WORKTREE_PATH"
  wt_branch="$(git -C "$WORKTREE_PATH" branch --show-current)"
  echo "ブランチ: $wt_branch"
  run_flutter_setup "$WORKTREE_PATH"
  print_worktree_hint
  exit 0
fi

if [[ -d "$WORKTREE_PATH" ]]; then
  die "worktree 以外のディレクトリが既に存在します: $WORKTREE_PATH"
fi

git fetch origin "$BASE_BRANCH" 2>/dev/null || true

if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
  echo "既存ブランチで worktree を追加します..."
  git worktree add "$WORKTREE_PATH" "$BRANCH_NAME"
else
  echo "ブランチを作成して worktree を追加します..."
  git worktree add -b "$BRANCH_NAME" "$WORKTREE_PATH" "$BASE_BRANCH"
fi

run_flutter_setup "$WORKTREE_PATH"

echo ""
echo "準備完了:"
echo "  worktree: $WORKTREE_PATH"
echo "  ブランチ: $BRANCH_NAME"
git worktree list
print_worktree_hint
