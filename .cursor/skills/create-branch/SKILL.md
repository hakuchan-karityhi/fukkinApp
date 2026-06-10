---
name: create-branch
description: >-
  devPolicy/branch/branchRule.md に準拠して Git ブランチを作成する。
  ブランチ作成、feature/fix/hotfix/docs ブランチ、分岐元の選択、
  命名規則、issue 番号の付与が話題のときに使う。
---

# Create Branch

`devPolicy/branch/branchRule.md` に準拠してブランチを作成する。

## 前提

- ブランチ作成は **必ず** `scripts/git/new-branch.sh` 経由で行う
- 直接 `git checkout -b` や `git switch -c` を使わない
- 詳細ルールは [branchRule.md](../../../devPolicy/branch/branchRule.md) を参照

## ワークフロー

### Step 1: 作業種別を決める

| ユーザーの意図 | 種類 (`TYPE`) | 既定の分岐元 |
|----------------|---------------|--------------|
| 新機能・機能追加 | `feature` | `develop` |
| 通常のバグ修正 | `fix` | `develop`（フェーズ版のバグなら `mvp` / `beta` / `release`） |
| 本番の緊急修正 | `hotfix` | `main` |
| 設計書・ドキュメント更新 | `docs` | `develop` |

不足している場合はユーザーに確認する。

### Step 2: issue 番号を確認する

- `feature` / `fix` → issue 番号が必要（例: `001`）
- subissue がある場合 → 親 issue 番号と subissue 番号の両方を確認
- `hotfix` / `docs` → issue 番号は不要（説明的な名前でよい）

### Step 3: ブランチ名（サフィックス）を組み立てる

| 種類 | 形式 | 例 |
|------|------|-----|
| feature（issue） | `<issue番号>-<機能名>` | `001-flutter-setup` |
| feature（subissue） | `<親issue>-<機能名>-<subissue>-<サブタスク>` | `001-flutter-setup-001-setup-library` |
| fix | `<issue番号>-<修正内容>` | `008-timer-bug` |
| hotfix | `<修正内容>` | `critical-security-fix` |
| docs | `<更新内容>` | `update-basic-design` |

ルール: 小文字・ハイフンのみ。スペース・大文字・特殊文字は禁止。

### Step 4: 分岐元を決める

- `feature` → 常に `develop`
- `docs` → 常に `develop`
- `hotfix` → 常に `main`
- `fix` → 状況に応じて選択:
  - develop 上のバグ → `develop`（命名: `<issue番号>-<修正内容>`）
  - フェーズ版で見つかったバグ → 該当の `mvp` / `beta` / `release`（命名: issue 番号または説明的な名前、例: `mvp-login-bug`）

フェーズブランチで `fix` を作った場合、マージ後は **必ず `develop` にも反映** する旨をユーザーに伝える。

### Step 5: ユーザーに確認してから実行

作成前に以下を提示し、承認を得る:

```
種類:     feature
ブランチ: feature/001-flutter-setup
分岐元:   develop
```

### Step 6: スクリプトで作成

```bash
# 形式: scripts/git/new-branch.sh <TYPE> <サフィックス> [分岐元]

scripts/git/new-branch.sh feature 001-flutter-setup develop
scripts/git/new-branch.sh fix 008-timer-bug develop
scripts/git/new-branch.sh fix mvp-login-bug mvp
scripts/git/new-branch.sh hotfix critical-security-fix main
scripts/git/new-branch.sh docs update-basic-design develop
```

分岐元を省略すると、種類ごとの既定値が使われる。

### Step 7: 作成後

- `git branch --show-current` で確認
- フェーズブランチ向け `fix` の場合、develop への逆流を TODO として伝える
- `hotfix` の場合、main マージ後に develop / 該当フェーズへの反映が必要と伝える

## 長期ブランチの初期作成

`mvp` / `beta` / `release` など基幹ブランチの作成は `branchRule.md` §2 に従う。
通常の作業ブランチとは別フロー。ユーザーが明示的に依頼した場合のみ実施する。

```bash
git checkout develop
git pull
git checkout -b mvp   # 例: develop から mvp を作成
```

基幹ブランチ作成は `new-branch.sh` の対象外。
