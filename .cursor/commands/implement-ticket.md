チケットを実装して PR まで進めて: $ARGUMENTS

`.cursor/skills/implement-ticket/SKILL.md` のワークフローに **厳密に** 従うこと。

## 手順

1. **implement-ticket スキルを読む**（`.cursor/skills/implement-ticket/SKILL.md`）
2. **create-branch スキルを読む**（ブランチ作成時）
3. 引数 `$ARGUMENTS` からチケットファイルを特定（例: `tickets/beta/002-plank-types-phase1.md` または `beta/002`）
4. Step 0〜5 を順に実行:
   - 依存チケット確認（未完了ならブロック or スタック PR をユーザーに確認）
   - `develop` から `scripts/git/new-branch.sh feature <番号>-<機能名> develop` でブランチ作成
   - チケットの受け入れ条件どおりに実装
   - 検証（`flutter analyze` / `flutter test` 等、プロジェクトに応じて）
   - コミット
   - `develop` 向けに `gh pr create`
5. PR URL と次に着手できるチケットを報告する

## 引数が空のとき

`tickets/beta/README.md` または `tickets/mvp/README.md` を読み、**依存が解消済みで着手可能なチケット** を一覧し、ユーザーにどれを実装するか確認する。

## 注意

- ブランチは `git checkout -b` 禁止。`scripts/git/new-branch.sh` を使う（スタック PR の例外はスキル記載どおり）
- PR の base は `develop`
- 応答は日本語
