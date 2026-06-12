# [BETA-000] Flutter 開発環境・プロジェクト基盤構築

## メタ情報

| 項目 | 値 |
|------|-----|
| フェーズ | MVP |
| 要件ID | —（`04-basic-design.md` §1.1, §2, §8） |
| 優先度 | Must |
| 依存 | — |
| 参照 | `01-design/04-basic-design.md` / `02-youken.md` §7 / `03-phase.md` §7 |

## 概要

設計ドキュメントのみの状態から、**Flutter アプリとしてビルド・実行・テストできる開発基盤** を整える。以降のチケット（MVP コア実装・β 機能追加）を進めるための最初の実装チケット。

## スコープ

### 含む

**プロジェクト作成**

- `flutter create` でアプリプロジェクトをリポジトリに追加（パッケージ名・表示名は設計に合わせて決定）
- iOS 最小バージョン **15+**（`04-basic-design.md` §7）
- `.gitignore`（Flutter / Dart / iOS / Android 標準）

**ディレクトリ構成（`04-basic-design.md` §2 準拠）**

```
lib/
├── main.dart
├── app/                 # ルーティング、テーマ、DI
├── presentation/
├── application/
├── domain/
│   ├── models/
│   ├── services/
│   └── repositories/
└── infrastructure/
assets/
├── character/
├── lottie/
└── master/
```

- 各層にプレースホルダファイルまたは README コメントで責務を明示
- `assets/master/plank_types.json` の雛形（PK-01, PK-02 のみ `enabled: true`）

**主要パッケージ（初期導入）**

| 用途 | パッケージ（案） |
|------|------------------|
| 状態管理 | `flutter_riverpod` |
| ローカル DB | `drift` + `sqlite3_flutter_libs`（または `hive` — どちらか一方に決定し README に記載） |
| 軽量設定 | `shared_preferences` |
| 静的解析 | `flutter_lints`（`analysis_options.yaml`） |

**開発者向けドキュメント**

- `docs/DEV_SETUP.md`（または README 追記）に以下を記載:
  - 必要ツール: Flutter 3.x / Dart 3.x、Xcode 15+、CocoaPods
  - `flutter doctor` の確認手順
  - 依存取得・起動・テスト・analyze コマンド
  - iOS シミュレータでの実行手順

**動作確認の最低ライン**

- `flutter pub get` 成功
- `flutter analyze` エラーなし
- `flutter test` 成功（起動スモークテスト1件以上）
- iOS シミュレータでアプリ起動（プレースホルダ画面で可）

**CI（任意・余力があれば）**

- GitHub Actions: `flutter analyze` + `flutter test` on push/PR

### 含まない

- ホーム画面・ゲームロジックなど **MVP 機能の実装**（別チケット）
- Firebase / Remote Config / Analytics の設定（BETA-001, 010 以降）
- キャラアセットの本番素材
- Android 実機検証（MVP は iOS 先行。エミュレータ設定のみでも可）
- TestFlight 配信（BETA-017 以降）

## 受け入れ条件

- [ ] リポジトリ内に Flutter プロジェクトが存在し、`flutter pub get` が通る
- [ ] `lib/` が Clean Architecture 風の層構成になっている（`04-basic-design.md` §2 と一致）
- [ ] `assets/master/plank_types.json` の雛形がある
- [ ] `flutter analyze` がエラーなく完了する
- [ ] `flutter test` が1件以上成功する
- [ ] iOS シミュレータでアプリが起動する
- [ ] 開発環境構築手順が `docs/DEV_SETUP.md`（または同等）に文書化されている
- [ ] 採用した DB（drift / hive）と状態管理（Riverpod）がドキュメントに明記されている

## 実装メモ

- プロジェクト名例: `fukkin` / 表示名: `ふっきん`
- Bundle ID は reverse-DNS（例: `com.<org>.fukkin`）— ストア申請前に確定
- `new-branch.sh` の feature 例: `feature/000-flutter-dev-environment`
- 既存の `01-design/`・`tickets/`・`scripts/` と共存する配置を選ぶ（ルート直下 `app/` または `packages/fukkin_app/` 等。採用構成を DEV_SETUP に記載）

## 備考

- **全実装チケットの前提**。`001` 以降の着手前に完了すること。
- MVP コア体験（ホーム統合 UI・ストリーク等）の実装は `tickets/mvp`（未作成）または別チケット群を想定。本チケットは **空の骨格** まで。
- `/implement-ticket beta/000` で着手可能。
