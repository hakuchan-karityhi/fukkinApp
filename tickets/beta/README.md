# β版 チケット一覧

**プロジェクト:** ふっきん（Plank Buddy）  
**フェーズ:** β版（第12〜16週）  
**参照:** [`01-design/03-phase.md`](../01-design/03-phase.md) §4.3 / [`02-youken.md`](../01-design/02-youken.md)  
**UI モック:** ホーム画面は [`01-design/screen/`](../01-design/screen/)（2026-06-11 確定）。種目選択・秒数設定はホーム種目ビューに統合。記録は下部タブ。

---

## 目的

MVP で検証したコア体験をベースに、**種目拡張・数値調整・継続率検証・分析・GDPR 対応** を行い、正式版（v1.0）へ進む判断材料を揃える。

## β の完了定義（DoD）

- [ ] 10名以上が7日以上利用し、フィードバックを収集した
- [ ] D7 継続率・7日ストリーク到達率を計測した
- [ ] 数値調整を1回以上反映した
- [ ] ストリーク途切れ後の復帰率を確認した
- [ ] ソフトローンチでストア公開（限定）し、クラッシュ率を確認した
- [ ] EU ユーザーを含む場合、分析の同意フローが動作する（未同意時は計測しない）

## スコープ外（β ではやらない）

- 本番課金（Pro サブスクリプション）
- 完了後動画広告
- クラウド同期・アカウント
- マイルーティン・マイ種目・ストリークフリーズ・詳細レポート

---

## チケット一覧

| # | ファイル | タイトル | 優先度 | 依存 |
|---|--------|----------|--------|------|
| 000 | [000-flutter-dev-environment.md](000-flutter-dev-environment.md) | Flutter 開発環境・プロジェクト基盤構築 | Must | — |
| 001 | [001-remote-config-game-constants.md](001-remote-config-game-constants.md) | ゲーム定数の Remote Config 化 | Must | 000, MVP 完了 |
| 002 | [002-plank-types-phase1.md](002-plank-types-phase1.md) | プランク種目拡張 Phase1（PK-03〜05） | Must | 000, MVP 完了 |
| 003 | [003-plank-types-phase2.md](003-plank-types-phase2.md) | プランク種目拡張 Phase2（PK-06〜07） | Must | 002 |
| 004 | [004-plank-types-phase3.md](004-plank-types-phase3.md) | プランク種目拡張 Phase3（PK-08〜09） | Must | 003 |
| 005 | [005-character-poses-assets.md](005-character-poses-assets.md) | 新種目キャラポーズ・アセット追加 | Must | 002 |
| 006 | [006-character-dialogue-expansion.md](006-character-dialogue-expansion.md) | キャラセリフ・表情の拡充 | Should | MVP 完了 |
| 007 | [007-milestone-60-100-days.md](007-milestone-60-100-days.md) | マイルストーン 60日・100日 | Should | MVP 完了 |
| 008 | [008-same-day-multiple-sessions.md](008-same-day-multiple-sessions.md) | 同日複数回プランク（再実施ボーナス段階加算） | Must | MVP 完了 |
| 009 | [009-streak-notification.md](009-streak-notification.md) | ストリーク通知（ローカル通知） | Must | MVP 完了 |
| 010 | [010-firebase-analytics.md](010-firebase-analytics.md) | Firebase Analytics 連携 | Must | 013 |
| 011 | [011-analytics-kpi-events.md](011-analytics-kpi-events.md) | 分析イベント定義・KPI 計測 | Must | 010 |
| 012 | [012-privacy-policy.md](012-privacy-policy.md) | プライバシーポリシー公開 | Must | — |
| 013 | [013-analytics-consent-gdpr.md](013-analytics-consent-gdpr.md) | 分析同意フロー（GDPR オプトイン） | Must | 012 |
| 014 | [014-pro-lock-ui-mock.md](014-pro-lock-ui-mock.md) | Pro 種目ロック UI モック | Should | 004 |
| 015 | [015-pro-upsell-screen-mock.md](015-pro-upsell-screen-mock.md) | Pro 誘導画面モック | Should | 014 |
| 016 | [016-numerical-balance-tuning.md](016-numerical-balance-tuning.md) | 数値バランス調整（プレイテスト反映） | Must | 001, 011 |
| 017 | [017-closed-beta-playtest.md](017-closed-beta-playtest.md) | クローズド β 配信・フィードバック収集 | Must | 009, 011 |
| 018 | [018-soft-launch.md](018-soft-launch.md) | ソフトローンチ準備・配信 | Must | 017, 016 |

---

## 推奨実装順序

```
000 Flutter 開発環境・プロジェクト基盤  ← 最初に必ず
  ↓
（MVP コア実装 — tickets/mvp 想定。ホーム統合 UI・ストリーク等）
  ↓
001 Remote Config
  ↓
002 → 003 → 004 種目拡張（並行: 005 アセット）
006 セリフ拡充 / 007 マイルストーン / 008 同日複数回（MVP 後いつでも）
012 プライバシーポリシー → 013 同意フロー → 010 Analytics → 011 KPI
009 通知
014 Pro ロック UI → 015 Pro 誘導モック
017 クローズド β → 016 数値調整 → 018 ソフトローンチ
```

---

## チケット形式

各チケットは以下のセクションで構成する。

| セクション | 内容 |
|------------|------|
| メタ情報 | フェーズ、要件ID、優先度、依存、参照ドキュメント |
| 概要 | 何を・なぜやるか |
| スコープ | 含む / 含まない |
| 受け入れ条件 | 完了の判定基準（チェックリスト） |
| 実装メモ | 技術的な注意点・未決事項 |
| 備考 | その他 |

---

## ホーム画面モックとの整合（2026-06-11 更新）

| 旧設計 | 新設計（モック準拠） |
|--------|----------------------|
| ホーム → 種目選択 → 秒数設定 → 実行 | ホーム種目ビューで種目・秒数・スタートまで完結 |
| ストリークが画面最上位の大表示 | ヘッダーにレベルバー主、ストリーク・倍率はコンパクト行 |
| ストリークカレンダー画面 | 下部タブ「記録」 |
| 設定はホームから遷移 | 下部タブ「設定」 |

**前提:** `000` で Flutter 基盤を整えたうえで、ホーム統合 UI 等の **MVP コア** を実装する。β チケット（001〜）はその上に載せる。

---

*作成日: 2026-06-10 / 更新: 2026-06-11（000 追加・ホームモック反映）*

tickets/beta/000 から 005 まで順に実装して。

ルール:
- 各チケットごとに feature ブランチを切り、PR は develop 向けに1件ずつ
- 001〜005 の「MVP完了」依存は、000完了後は一旦スキップして進めてよい（種目拡張・基盤優先）
- 003は002マージ後、004は003マージ後。005は002完了後に着手
- ブロックしたら次に進めるチケットを報告して止まらない