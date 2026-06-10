# developBase

開発用のベースリポジトリです。新しいプロジェクトの土台として利用できます。

## 概要

このリポジトリは、開発を始めるための最小構成のベースです。  
必要に応じてディレクトリ構成・ツール・ドキュメントを追加してください。

## セットアップ

```bash
git clone <repository-url>
cd developBase
```

## ディレクトリ構成

```
developBase/
├── README.md
├── 01-design/              # 設計ドキュメント（雛形）
│   ├── about-this-folder.md
│   ├── 01-kikaku.md
│   ├── 02-youken.md
│   ├── 03-phase.md
│   ├── 04-basic-design.md
│   └── 05-detailed-design.md
└── ...
```

## 01-design（設計ドキュメント）

`01-design` は、プロジェクトの設計に関するドキュメントをまとめるフォルダです。  
企画から詳細設計まで、設計フェーズで必要な文書の雛形を配置しています（現在作成中）。

| ファイル | 内容 |
|----------|------|
| `01-kikaku.md` | 企画書 |
| `02-youken.md` | 要件定義書（軽量版） |
| `03-phase.md` | 開発フェーズ計画書（MVP / β / 正式版） |
| `04-basic-design.md` | 基本設計 |
| `05-detailed-design.md` | 詳細設計 |

設計は次の順で進めます。

```
企画 → 要件定義 → フェーズ計画 → 基本設計 → 詳細設計
```

詳細は [`01-design/about-this-folder.md`](01-design/about-this-folder.md) を参照してください。

## 開発

1. `01-design` で企画・設計をする
2. Cursor に基幹ブランチの作成を依頼する（`main`, `develop`, `mvp`, `beta`, `release`）
3. `01-design/02-youken.md` から `tickets/mvp` / `tickets/beta` にチケットを切る
4. チケットを実装して PR まで進める → Cursor コマンド **`/implement-ticket`**

### チケット実装コマンド

```
/implement-ticket tickets/beta/002-plank-types-phase1.md
/implement-ticket beta/002
```

`develop` から feature ブランチを切り、実装・コミット・`develop` 向け PR 作成まで自動で進める。  
詳細: `.cursor/skills/implement-ticket/SKILL.md`

## ライセンス

未定（必要に応じて追記してください）
