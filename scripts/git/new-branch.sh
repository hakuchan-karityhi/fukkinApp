#!/bin/bash
# devPolicy/branch/branchRule.md に準拠して作業ブランチを作成する
#
# 使い方:
#   scripts/git/new-branch.sh <TYPE> <サフィックス> [分岐元]
#
# 例:
#   scripts/git/new-branch.sh feature 001-flutter-setup
#   scripts/git/new-branch.sh fix 008-timer-bug develop
#   scripts/git/new-branch.sh fix mvp-login-bug mvp
#   scripts/git/new-branch.sh hotfix critical-security-fix
#   scripts/git/new-branch.sh docs update-basic-design
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/git/new-branch.sh <TYPE> <suffix> [base-branch]

TYPE:
  feature  機能開発（分岐元: develop）
  fix      バグ修正（分岐元: develop / mvp / beta / release）
  hotfix   緊急修正（分岐元: main）
  docs     ドキュメント（分岐元: develop）

Examples:
  scripts/git/new-branch.sh feature 001-flutter-setup
  scripts/git/new-branch.sh fix 008-timer-bug develop
  scripts/git/new-branch.sh hotfix critical-security-fix main
  scripts/git/new-branch.sh docs update-basic-design

詳細: devPolicy/branch/branchRule.md
EOF
}

if [[ $# -lt 2 ]] || [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

TYPE="$1"
SUFFIX="$2"
BASE_BRANCH="${3:-}"

VALID_TYPES=(feature fix hotfix docs)
VALID_BASES=(main develop mvp beta release)
FORBIDDEN_SUFFIXES=(test fix update main develop mvp beta release)

# 種類の検証
if [[ ! " ${VALID_TYPES[*]} " =~ " ${TYPE} " ]]; then
  echo "ERROR: 無効な種類です: $TYPE"
  echo "有効な値: feature, fix, hotfix, docs"
  exit 1
fi

# サフィックスの検証（小文字・数字・ハイフンのみ）
if [[ ! "$SUFFIX" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "ERROR: サフィックスは小文字・数字・ハイフンのみ使用できます: $SUFFIX"
  exit 1
fi

# 意味のない単独名を禁止
for forbidden in "${FORBIDDEN_SUFFIXES[@]}"; do
  if [[ "$SUFFIX" == "$forbidden" ]]; then
    echo "ERROR: 意味のないブランチ名は使用できません: $SUFFIX"
    exit 1
  fi
done

# 既定の分岐元
case "$TYPE" in
  feature|docs)
    DEFAULT_BASE="develop"
    ALLOWED_BASES=(develop)
    ;;
  fix)
    DEFAULT_BASE="develop"
    ALLOWED_BASES=(develop mvp beta release)
    ;;
  hotfix)
    DEFAULT_BASE="main"
    ALLOWED_BASES=(main)
    ;;
esac

if [[ -z "$BASE_BRANCH" ]]; then
  BASE_BRANCH="$DEFAULT_BASE"
fi

# feature は issue 番号（先頭に数字）を必須
if [[ "$TYPE" == "feature" ]] && [[ ! "$SUFFIX" =~ ^[0-9]+- ]]; then
  echo "ERROR: feature ブランチは issue 番号を先頭に含めてください（例: 001-flutter-setup）"
  exit 1
fi

# fix: develop 起点は issue 番号必須、フェーズブランチ起点は説明的な名前も可
if [[ "$TYPE" == "fix" ]] && [[ "$BASE_BRANCH" == "develop" ]] && [[ ! "$SUFFIX" =~ ^[0-9]+- ]]; then
  echo "ERROR: develop からの fix ブランチは issue 番号を先頭に含めてください（例: 008-timer-bug）"
  exit 1
fi

# 分岐元の検証
if [[ ! " ${ALLOWED_BASES[*]} " =~ " ${BASE_BRANCH} " ]]; then
  echo "ERROR: $TYPE ブランチの分岐元として無効です: $BASE_BRANCH"
  echo "許可される分岐元: ${ALLOWED_BASES[*]}"
  exit 1
fi

BRANCH_NAME="${TYPE}/${SUFFIX}"

# 既存ブランチの確認
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
  echo "ERROR: ブランチは既に存在します: $BRANCH_NAME"
  exit 1
fi

# 分岐元の存在確認
if ! git show-ref --verify --quiet "refs/heads/$BASE_BRANCH"; then
  echo "ERROR: 分岐元ブランチが存在しません: $BASE_BRANCH"
  echo "先に分岐元ブランチを作成するか、リモートから取得してください"
  exit 1
fi

echo "ブランチ作成:"
echo "  名前:   $BRANCH_NAME"
echo "  分岐元: $BASE_BRANCH"
echo ""

git checkout "$BASE_BRANCH"
git pull --ff-only 2>/dev/null || true
git checkout -b "$BRANCH_NAME"

echo ""
echo "作成完了: $BRANCH_NAME (from $BASE_BRANCH)"

if [[ "$TYPE" == "fix" && "$BASE_BRANCH" != "develop" ]]; then
  echo ""
  echo "注意: フェーズブランチ ($BASE_BRANCH) での修正は、マージ後に develop にも必ず反映してください"
fi

if [[ "$TYPE" == "hotfix" ]]; then
  echo ""
  echo "注意: hotfix は main マージ後、develop と該当フェーズブランチにも反映してください"
fi
