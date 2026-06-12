# [MVP-013] カスタム種目の作成・保存

## メタ情報

| 項目 | 値 |
|------|-----|
| フェーズ | MVP |
| 要件ID | PL-31 |
| 優先度 | Must |
| 依存 | 000（基盤）, 011（プランク実行 UI） |
| 参照 | `02-youken.md` §3.1 PL-31, §3.3.6 / `04-basic-design.md` SC-03, SC-07, SC-12 |

## 概要

ユーザーが**自分だけの種目名**を付けて単種目を追加できる。見た目（キャラポーズ・フォーム画像）は **PK-01 ベーシックプランクで固定**。EXP 倍率・難易度も PK-01 準拠。カルーセルに並び、通常の単種目と同様に SC-07 で実行する。

**PL-24（Pro・マイ種目）との違い:** PL-31 は公式種目をベースにせず、名前のみカスタム。ポーズ・倍率は変更不可。PL-24 は公式種目ベースで名前・秒数・メモを拡張。

## カルーセル構成（左→右）

```
公式単種目（PK-01…） → カスタム種目A → カスタム種目B → … → ＋（種目を追加）
  → SET-01 → カスタムセット… → ＋（セットを作る）   ※セット部分は MVP-012
```

## スコープ

### 含む

- カルーセル上の **カスタム種目タイル**（ユーザー名表示・ベーシックプランク固定プレビュー）
- **＋（種目を追加）** タイル → **SC-12** カスタム種目編集画面
  - 種目名入力（必須）
  - プレビュー（PK-01 固定ポーズ・画像）
  - 保存・削除（既存編集時）
- `CustomPlankType` のローカル永続化（`CustomPlankTypeRepository` + Drift）
- `PlankTypeRepository` の合成（アセットマスタ + カスタム種目 → `PlankType`）
- カスタム種目の単独実行（既存 SC-07 フロー再利用）
- 記録タブ・結果画面でのカスタム種目名表示
- 上限 **20件**

### 含まない

- ポーズ・フォーム画像の選択（Pro / PL-24 でもベース種目準拠のため MVP では不可）
- EXP 倍率・難易度の変更
- メモ欄
- クラウド同期
- カスタムセットへの組み込み（**MVP-012** で対応。012 は 013 に依存）

## 受け入れ条件

- [ ] 公式単種目の後に保存済みカスタム種目がカルーセル表示される
- [ ] ＋（種目を追加）から種目名を入力して保存できる
- [ ] 保存した種目はベーシックプランクの絵で表示され、秒数 `− / +` で調整できる
- [ ] スタートで SC-07 実行でき、EXP は PK-01 相当（倍率 1.0）で計算される
- [ ] 記録タブの日別履歴にカスタム種目名が表示される
- [ ] 既存カスタム種目を編集・削除できる
- [ ] 種目名空・20件超では保存できない
- [ ] アプリ再起動後もカスタム種目が残る
- [ ] `flutter analyze` / 関連テストが通過する

## 実装メモ

### データモデル（案）

```dart
class CustomPlankType {
  final String id;        // CUST-{uuid}
  final String name;
  final DateTime createdAt;
}

// 表示・実行用に PlankType へ変換
PlankType toPlankType(CustomPlankType custom) => PlankType(
  id: custom.id,
  name: custom.name,
  difficulty: 1,
  expMultiplier: 1.0,
  defaultSeconds: 30,
  enabledInMvp: true,
  enabledInBeta: true,
  poseAssetId: 'basic_plank',
  formImageAsset: /* PK-01 と同じ */,
  recommendedSecondsMin: 30,
  recommendedSecondsMax: 60,
);
```

### 画面・Widget

- `CustomPlankTypeEditorScreen`（SC-12）
- `AddCustomPlankTypeTile`（カルーセル ＋種目）
- `home_screen.dart`：カルーセルにカスタム種目・＋種目を挿入
- カスタム種目選択時：`ExercisePanel` と同等 UI（単種目）

### リポジトリ

- Drift テーブル `custom_plank_types`
- `CustomPlankTypeRepository`：CRUD
- `CompositePlankTypeRepository` または既存 `plankTypesProvider` でマージ

### 履歴

- `WorkoutRecord.plankTypeId` に `CUST-*` を保存
- 種目削除後は ID から名前解決できない場合、記録表示用に名前スナップショットを検討（012 と同様の方針でよい）

## 備考

- MVP-012（カスタムセット）の種目候補にカスタム種目を含めるため、**012 は 013 完了後**に実装する
- 将来 PL-24 導入時は、既存 `CUST-*` をマイグレーションするか並存させるかを別途設計
