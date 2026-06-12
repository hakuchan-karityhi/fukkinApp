---
name: implement-ticket
description: >-
  develop からブランチを切り、チケット（tickets/mvp または tickets/beta）を実装し、
  PR を作成する。チケット実装、feature ブランチ、develop 向け PR、依存チケット確認の
  依頼時に使う。create-branch スキルと併用する。
---

# Implement Ticket

チケット1件を **develop 起点** で実装し、PR まで進める。

このスキルの起動は、コミット・PR 作成の明示依頼とみなす。

## 前提スキル・ルール

- ブランチ作成: [create-branch/SKILL.md](../create-branch/SKILL.md) — チケット番号が分かるときは `scripts/git/start-ticket.sh` を優先（worktree 自動判定）。それ以外は `scripts/git/new-branch.sh`
- ブランチポリシー: `.cursor/rules/branch-policy.mdc`
- 設計参照: `01-design/02-youken.md`, `01-design/04-basic-design.md`
- PR 作成: `gh pr create`（ユーザールールの PR 手順に従う）

## 入力の解釈

ユーザー引数の例:

| 入力 | 解釈 |
|------|------|
| `tickets/beta/002-plank-types-phase1.md` | そのファイルをチケットとする |
| `beta/002` | `tickets/beta/002-*.md` を検索 |
| `mvp/008` | `tickets/mvp/008-*.md` を検索 |

複数候補がある場合はユーザーに確認する。

## ワークフロー

```
Task Progress:
- [ ] Step 0: チケット読込・依存確認
- [ ] Step 1: ブランチ作成（develop）
- [ ] Step 2: 実装
- [ ] Step 3: 検証
- [ ] Step 4: コミット
- [ ] Step 5: PR 作成
```

### Step 0: チケット読込・依存確認

1. チケット MD を読む（メタ情報・スコープ・受け入れ条件・実装メモ）
2. `tickets/<phase>/README.md` の依存列を確認
3. 依存チケットが **develop にマージ済みか** 確認:

```bash
git fetch origin
git log origin/develop --oneline -20
# 依存チケットの feature ブランチが未マージの場合は gh pr list で状態確認
```

**依存未完了時の分岐:**

| 状況 | 対応 |
|------|------|
| 依存が develop にマージ済み | Step 1 へ |
| 依存 PR がオープン（未マージ） | ユーザーに **待つ / スタック PR** を確認 |
| スタック PR を選んだ場合 | 依存の `feature/<番号>-*` ブランチを checkout し、そこから `git checkout -b feature/<今回>-*`（`new-branch.sh` は使わない例外。ユーザー承認必須） |
| ゲート依存（例: MVP 完了） | 未達なら実装を中止し、ブロック理由を報告 |

着手不可のときは **実装せず** ブロック理由と次にやるべきチケットを提示する。

### Step 1: ブランチ作成

1. チケットファイル名からブランチ名を決める（例: `009-records-day-detail.md` → `feature/009-records-day-detail`）
2. ユーザーに以下を提示し承認を得る:

```
種類:     feature
ブランチ: feature/009-records-day-detail
分岐元:   develop
モード:   checkout（develop 上）/ worktree（既に別 feature 上）
```

3. **チケット番号が分かる場合**（推奨）— `start-ticket.sh` で自動セットアップ:

```bash
git fetch origin
# 例: MVP-009 → develop 上なら checkout、既に feature 中なら worktree
scripts/git/start-ticket.sh 009
# フェーズ明示: scripts/git/start-ticket.sh mvp/009
# worktree 強制:  scripts/git/start-ticket.sh 011 --worktree
```

4. チケット番号が不明・fix/docs など **feature 以外** のときのみ `new-branch.sh`:

```bash
scripts/git/new-branch.sh feature 002-plank-types-phase1 develop
```

`develop` が無い場合は先に作成・fetch するようユーザーに伝える。  
worktree が作られた場合は、**そのパスを完了報告に記載**し、実装は worktree 側で行う。

### Step 2: 実装

1. チケットの **受け入れ条件** をチェックリストとして保持
2. スコープ **含む / 含まない** を守る（含まないものは実装しない）
3. `01-design/` の該当セクションを参照し、既存コードの慣習に合わせる
4. 受け入れ条件を1つずつ満たすまで実装

### Step 3: 検証

チケットにテスト指示があれば実行。なければ最低限:

```bash
# Flutter プロジェクトの場合（該当するとき）
flutter analyze
flutter test
```

失敗時は Step 2 に戻り修正する。

### Step 4: コミット

1. 並列で状態確認:

```bash
git status
git diff
git log -5 --oneline
```

2. コミットメッセージは **why** を1〜2文で。HEREDOC を使う:

```bash
git add <関連ファイルのみ>
git commit -m "$(cat <<'EOF'
チケットの目的を一文で。

EOF
)"
```

3. `.env` や鍵ファイルはコミットしない

### Step 5: PR 作成

1. 並列で PR 前確認:

```bash
git status
git diff
git log origin/develop..HEAD --oneline
git diff origin/develop...HEAD
```

2. push:

```bash
git push -u origin HEAD
```

3. PR 作成（base は **develop**）:

```bash
gh pr create --base develop --title "feat: <チケット要約>" --body "$(cat <<'EOF'
## Summary
- チケット: [BETA-002] ...
- 変更の要点を箇条書き

## 受け入れ条件
- [x] 条件1
- [x] 条件2

## Test plan
- [ ] 手動確認項目

EOF
)"
```

4. **PR URL をユーザーに返す**

## ブランチ名の規則（早見）

| チケット ID | ブランチ名例 |
|-------------|--------------|
| BETA-002 | `feature/002-plank-types-phase1` |
| MVP-008 | `feature/008-same-day-multiple-sessions` |

チケットファイル名の番号部分（`002`）を先頭に使う。機能名はファイル名からハイフン区切りで抜く。

## エラー時

| エラー | 対応 |
|--------|------|
| `develop` がない | `git fetch` / 基幹ブランチ作成をユーザーに依頼 |
| ブランチが既に存在 | 別サフィックスにするか既存ブランチを使うか確認 |
| 依存未マージ | Step 0 に戻る。スタック or 待機 |
| push 失敗 | `git remote -v` を確認。URL 修正は `git remote set-url` |
| PR 作成失敗 | `gh auth status` を確認 |

## 完了報告テンプレート

```markdown
## 完了
- チケット: [BETA-002] ...
- ブランチ: feature/002-plank-types-phase1
- PR: <URL>

## 受け入れ条件
- [x] ...

## 次のチケット候補（依存より）
- BETA-003（002 マージ後）
- BETA-005（002 と並行可、002 マージ後が安全）
```
