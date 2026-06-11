# Remote Config キー一覧（BETA-001）

Firebase Remote Config に設定するキーとデフォルト値。未取得時は `GameConstants.defaults()` を使用。

| キー | 型 | デフォルト | 説明 |
|------|-----|-----------|------|
| `level_thresholds` | JSON 配列 | `[150,400,800,1400]` | 腹筋ステージ閾値（累計 EXP） |
| `repeat_session_bonus_step` | number | `0.05` | 再実施ボーナス加算率（2回目以降、回数ごとに +5%） |
| `repeat_session_bonus_cap` | number | `1.15` | 再実施ボーナス上限倍率（+15%。4回目以降は固定） |
| `daily_exp_cap` | number | `150` | 1日 EXP 上限 |
| `penalty_min_exp` | number | `10` | ペナルティ最小減少量 |
| `penalty_second_day_rate` | number | `0.5` | 2日目ペナルティ率 |

## ストリーク倍率

`streak_multiplier_json` は将来拡張用。現状はコード内デフォルトを使用。

| 連続日数 | 倍率 |
|----------|------|
| 1〜2 | 1.0 |
| 3〜6 | 1.1 |
| 7〜13 | 1.2 |
| 14〜29 | 1.3 |
| 30+ | 1.5 |

## 実装

- リポジトリ: `RemoteConfigGameConstantsRepository`
- フォールバック: `LocalGameConstantsRepository`
- Domain: `ExpCalculator`, `StreakService`, `LevelService`, `PenaltyService`
