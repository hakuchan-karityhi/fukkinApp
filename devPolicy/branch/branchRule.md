# 🌿 ブランチ運用規則 — World Sudoku
**プロジェクト名:** 
**作成日:** 2025-01-XX  
**バージョン:** 1.0  

---

## 1. ブランチの種類

### 1.1 長期ブランチ（常駐する"基幹ブランチ"）

- **main**: 本番。タグでリリースを管理。
- **develop**: 次リリースへ向けた統合先（常に最新の完成形に近い状態）
- **mvp, beta, release**: フェーズ用の安定化ブランチ（ステージング扱い）

developFlow.mdの前準備で必要なブランチをcusorに切らせる。

### 1.2 短期ブランチ（作業単位）

- **feature/***: 機能追加
- **fix/***: 通常バグ修正
- **hotfix/***: 本番緊急修正（main起点）
- **docs/***: ドキュメント更新


### 1.3 ブランチ一覧表

| ブランチ | 用途 | 説明 | 分岐元 |
|---------|------|------|--------|
| **main** | 本番環境用 | リリース可能な安定版のみを保持。タグでリリースを管理 | - |
| **develop** | 開発統合ブランチ | 全フェーズ共通の統合ブランチ。常に最新の完成形に近い状態 | - |
| **mvp** | MVP版の開発用 | MVPとして出す範囲だけ。developから分岐 | develop |
| **beta** | β版の開発用 | β版として出す範囲だけ。developから分岐 | develop |
| **release** | 正式版開発 | 正式版開発用。developから分岐 | develop |
| **feature/** | 機能開発 | 機能追加用の作業ブランチ | develop |
| **fix/** | バグ修正 | 通常のバグ修正用の作業ブランチ | develop / mvp / beta / release |
| **hotfix/** | 緊急修正 | 本番緊急修正用。mainから直接分岐 | main |
| **docs/** | ドキュメント専用 | 設計書、仕様書の更新用 | develop |

## 2. フェーズブランチの運用

### 2.1 MVPブランチ

- `develop`から`mvp`を作成
- 定期的に`develop`を`mvp`へ反映（マージ or cherry-pick運用）
- **MVPリリース時**: `mvp`から`main`へマージしてタグ付け（例: `v0.1.0`）

### 2.2 Betaブランチ

- `develop`から`beta`を作成
- `develop`のうち`beta`に入れるものだけを`beta`に反映
- **βリリース時**: `beta`→`main`マージ、タグ`v0.9.0`など

### 2.3 Releaseブランチ

- `develop`から`release`を作成
- `release`ブランチには新機能を入れない
- `fix/*`のみ許可（バグ、微調整、性能、セキュリティ）
- **正式リリース時**: `release`→`main`で`v1.0.0`



## 3. バグ修正のフロー

### 3.1 develop上のバグ（次リリースにだけ影響）

- `fix/*`を`develop`から作成
- `develop`にマージ
- 必要なら`mvp`/`beta`/`release`へcherry-pick

### 3.2 フェーズ版（mvp/beta/release）で見つかったバグ

- `fix/*`を該当フェーズブランチから作成（例：`fix/mvp-login-bug`）
- 該当フェーズにマージ
- **同じ修正を`develop`にも必ず反映**（cherry-pick or merge）

> **重要ルール**: **「フェーズブランチで直したバグは`develop`に必ず逆流させる」**

### 3.3 本番障害（hotfix）

- `hotfix/*`を`main`から作成
- `main`にマージ（緊急リリース）
- `develop`と該当フェーズにも必ず反映（cherry-pick）

### 3.4 ドキュメント更新

- `docs/*`はブランチプレフィックスとして使用
- **対象ブランチは`develop`**
- 例：`docs/update-api-spec`を`develop`から作成して`develop`へPR


## 4. ブランチポリシー（必須の運用ルール）

### 4.1 基本ルール

1. `main`への直接push禁止（PRのみ）
2. `develop`は常にビルド可能な状態（CI必須）
3. `mvp`/`beta`/`release`には「フェーズで必要なものだけ入れる」
4. `hotfix`は必ず`main → develop`にも反映
5. フェーズブランチでの修正は`develop`に必ず反映

### 4.2 MVP取り込みポリシー（事故防止）

1. `mvp`への反映は**PR必須**（pushしない、必ずPull Request（PR）を作ってレビューとCIを通す）
2. `mvp`には**MVP対象（ラベル付き）だけ**を入れる。PRに**MVPラベル**（例：`MVP`）を付けて管理
3. `mvp`で修正した`fix/*`は**必ず`develop`に逆流**
4. `mvp`で**新規feature開発はしない**（やるなら例外として、最後に`develop`へ逆流）



### 4.3 ブランチ運用の基本フロー

- `develop`から`mvp`、`beta`、`release`を分岐
- `develop`↔`feature`で開発する
- 定期的に`develop`から`mvp`へマージする

#### ブランチ戦略図

![ブランチ戦略図](branch_strategy_diagram_corrected%201.png)

---

## 5. ブランチ命名規則

### 5.1 必須ルール

- **issueの場合**: issue番号を含める
  - 例: `feature/001-flutter-setup`
- **subissueの場合**: 親issue番号とsubissue番号を含める（ハイフン区切り）
  - 形式: `feature/<親issue番号>-<機能名>-<subissue番号>-<サブタスク機能名>`
  - 例: `feature/001-flutter-setup-001-setup-library`
- **機能名を含める**: `feature/home-screen`
- **ドキュメント更新**: `docs/update-basic-design` または `docs/add-architecture-diagram`
- **命名規則**: 小文字とハイフンを使用（スネークケースや大文字は使用禁止）

### 5.2 禁止事項

- ブランチ名にスペースを含めない
- ブランチ名に特殊文字（`@`, `#`, `$`, `%`など）を含めない
- 意味のないブランチ名（`test`, `fix`, `update`など単独）は使用禁止

### 5.3 命名例

| 種類 | 形式 | 例 |
|------|------|-----|
| 機能開発（issue） | `feature/<issue番号>-<機能名>` | `feature/001-flutter-setup` |
| 機能開発（subissue） | `feature/<親issue番号>-<機能名>-<subissue番号>-<サブタスク機能名>` | `feature/001-flutter-setup-001-setup-library` |
| バグ修正 | `fix/<issue番号>-<修正内容>` | `fix/008-timer-bug` |
| 緊急修正 | `hotfix/<修正内容>` | `hotfix/critical-security-fix` |
| ドキュメント | `docs/<更新内容>` | `docs/update-basic-design` |

---

## 6. 参照ドキュメント

- `.cursor/rules/devPolicy/developFlow.md`: 開発フローの参照
- `.cursor/rules/devPolicy/git-githubRule.md`: Git/GitHub運用規則の参照
- `docs/開発方針.md`: 開発方針の参照

---

## 7. 更新履歴

| 日付 | バージョン | 変更内容 |
|------|-----------|----------|
| 2025-01-XX | 1.0 | 初版作成 |


