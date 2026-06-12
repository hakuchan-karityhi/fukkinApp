# ふっきん 開発環境セットアップ

## 必要ツール

| ツール | バージョン |
|--------|------------|
| Flutter | 3.x（stable） |
| Dart | 3.x |
| Xcode | 15+（iOS 開発） |
| CocoaPods | 最新 |

## リポジトリ構成

Flutter アプリはリポジトリ直下の `app/` に配置しています。

```
fukkin/
├── app/           # Flutter プロジェクト（パッケージ名: fukkin）
├── 01-design/     # 設計ドキュメント
├── tickets/       # 実装チケット
└── docs/          # 開発ドキュメント
```

## 技術選定（BETA-000）

| 用途 | 採用 |
|------|------|
| 状態管理 | **flutter_riverpod** |
| ローカル DB | **drift** + sqlite3_flutter_libs |
| 軽量設定 | **shared_preferences** |

## 初回セットアップ

```bash
# 1. Flutter 環境確認
flutter doctor

# 2. 依存取得
cd app
flutter pub get

# 3. 静的解析・テスト
flutter analyze
flutter test
```

## iOS シミュレータで起動

```bash
cd app
open -a Simulator   # シミュレータを起動
flutter run
```

最小対応 OS: **iOS 15+**

## drift コード生成（DB スキーマ追加時）

```bash
cd app
dart run build_runner build --delete-conflicting-outputs
```

## 参照

- 基本設計: `01-design/04-basic-design.md`
- チケット: `tickets/beta/000-flutter-dev-environment.md`
