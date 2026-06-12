# MVP チケット一覧

**プロジェクト:** ふっきん（Plank Buddy）  
**フェーズ:** MVP  
**参照:** [`01-design/03-phase.md`](../../01-design/03-phase.md) / [`02-youken.md`](../../01-design/02-youken.md)

---

## チケット一覧

| # | ファイル | タイトル | 優先度 | 依存 |
|---|--------|----------|--------|------|
| 000 | [000-flutter-dev-environment.md](000-flutter-dev-environment.md) | Flutter 開発環境・プロジェクト基盤構築 | Must | — |
| 001 | [001-remote-config-game-constants.md](001-remote-config-game-constants.md) | ゲーム定数の Remote Config 化 | Must | 000 |
| 002 | [002-plank-types-phase1.md](002-plank-types-phase1.md) | プランク種目拡張 Phase1（PK-03〜05） | Must | 000 |
| 003 | [003-plank-types-phase2.md](003-plank-types-phase2.md) | プランク種目拡張 Phase2（PK-06〜07） | Must | 002 |
| 004 | [004-plank-types-phase3.md](004-plank-types-phase3.md) | プランク種目拡張 Phase3（PK-08〜09） | Must | 003 |
| 005 | [005-character-poses-assets.md](005-character-poses-assets.md) | 新種目キャラポーズ・アセット追加 | Must | 002 |
| 006 | [006-character-dialogue-expansion.md](006-character-dialogue-expansion.md) | キャラセリフ・表情の拡充 | Should | 000 |
| 007 | [007-milestone-60-100-days.md](007-milestone-60-100-days.md) | マイルストーン 60日・100日 | Should | 000 |
| 008 | [008-same-day-multiple-sessions.md](008-same-day-multiple-sessions.md) | 同日複数回プランク（再実施ボーナス） | Must | 000 |
| 009 | [009-records-day-detail.md](009-records-day-detail.md) | 記録タブ：日別プランク履歴表示 | Must | 000 |
| 010 | [010-plank-set.md](010-plank-set.md) | プランクセット（固定3種連続実行） | Must | 002, 008, **011** |
| 011 | [011-plank-session-countdown-pause.md](011-plank-session-countdown-pause.md) | プランク実行：3・2・1 開始カウントと一時停止 UI | Must | 000 |
| 012 | [012-custom-plank-set.md](012-custom-plank-set.md) | カスタムプランクセットの作成・保存 | Must | 010, 011, **013** |
| 013 | [013-custom-plank-type.md](013-custom-plank-type.md) | カスタム種目の作成・保存（名前のみ・ベーシック固定） | Must | 000, 011 |

---

## 推奨実装順序（009〜011 追加後）

```
000 Flutter 基盤
  ↓
001 Remote Config（抽象層）
002 → 003 → 004 種目拡張
005 アセット / 006 セリフ / 007 マイルストーン / 008 同日複数回
  ↓
011 プランク実行 UI（3・2・1・一時停止）  ← 010 より先
009 記録日別詳細（008 と並行可）
010 プランクセット（002, 008, 011 完了後）
  ↓
013 カスタム種目（011 完了後。010 と並行可）
  ↓
012 カスタムプランクセット（010, 011, 013 完了後）
```

---

*更新: 2026-06-12（013 カスタム種目追加）*
