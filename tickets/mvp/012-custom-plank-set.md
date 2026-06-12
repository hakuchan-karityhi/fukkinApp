# [MVP-012] カスタムプランクセットの作成・保存

## メタ情報

| 項目 | 値 |
|------|-----|
| フェーズ | MVP |
| 要件ID | PL-30 |
| 優先度 | Must |
| 依存 | 010（プランクセット連続実行・種目ごと秒数）, 011（プランク実行 UI）, **013（カスタム種目）** |
| 参照 | `02-youken.md` §3.1 PL-30, §3.3.5 / `04-basic-design.md` SC-03, SC-07b, SC-11 |

## 概要

カルーセル**末尾**に **＋（セットを作る）** を表示する。タップでセット編集画面（SC-11）を開き、利用可能な種目（**公式＋カスタム種目**）を好きな順で登録・**セット名を付けて保存**する。保存したセットはカルーセルに並び、SET-01 と同様に連続実行できる。

## カルーセル構成（左→右）

```
公式単種目 → カスタム種目 → ＋（種目） → SET-01 → カスタムセットA → … → ＋（セット）
```

※ カスタム種目・＋（種目）は **MVP-013** で実装。

## スコープ

### 含む

- カルーセル末尾の **＋（セットを作る）** タイル
- **SC-11** セット編集画面
  - セット名入力（必須）
  - 種目の追加（`PlankTypeRepository` で利用可能な**公式＋カスタム種目**）
  - 種目の並べ替え・削除
  - 種目ごとの目標秒数（`− / +`、5秒刻み・10〜120秒）
- `CustomPlankSet` のローカル永続化（`CustomPlankSetRepository` + Drift）
- 保存済みセットのカルーセル表示・選択時プレビュー（`PlankSetDetailPanel` 相当）
- 保存済みセットの**編集・削除**
- カスタムセットの実行（既存 `PlankSetSessionScreen` / SC-07b フローを再利用）
- 種目数制限：**2〜9種**、同一種目の重複不可

### 含まない

- 種目間休憩時間の設定（Pro / PL-22）
- セットのクラウド同期・共有（Pro / PL-23）
- 公式 SET-01 の編集・削除
- カスタム種目の新規作成 UI（MVP-013 / SC-12）
- マイ種目（PL-24）

## 受け入れ条件

- [ ] 種目カルーセルの最後（セット領域）に ＋（セット）が表示される
- [ ] ＋タップでセット編集画面が開き、セット名と種目を登録して保存できる
- [ ] 保存後、カルーセルにセット名付きで表示される
- [ ] 種目は利用可能な公式種目から選び、好きな順で並べ替えられる
- [ ] 種目ごとに秒数を `− / +` で設定できる
- [ ] 保存済みセットを選択してスタートすると連続実行でき、結果画面に各種目 EXP が表示される
- [ ] 保存済みセットを編集・削除できる
- [ ] 種目2未満・名前空・重複種目では保存できない
- [ ] アプリ再起動後もカスタムセットが残る
- [ ] `flutter analyze` / 関連テストが通過する

## 実装メモ

### データモデル（案）

```dart
class CustomPlankSet {
  final String id;           // UUID
  final String name;
  final List<CustomPlankSetItem> items; // 順序付き
  final DateTime updatedAt;
}

class CustomPlankSetItem {
  final String plankTypeId;
  final int targetSeconds;
}
```

### 画面・Widget

- `CustomPlankSetEditorScreen`（SC-11）
- `AddPlankSetTile`（カルーセル ＋）
- `home_screen.dart`：カルーセル項目を `単種目 | SET-01 | custom... | +` に拡張
- `PlankSetDetailPanel`：カスタムセット名・種目一覧・秒数ステッパー

### リポジトリ

- Drift テーブル `custom_plank_sets` + `custom_plank_set_items`（または JSON 列）
- `CustomPlankSetRepository`：CRUD

### 実行

- `PlankSetDefinition` を `id` + `name` + `plankTypeIds` で組み立て
- `targetSecondsList` は各 item から渡す（010 / 020 と同パス）

## 備考

- Pro のマイルーティン（PL-22/23）は「休憩カスタム・クラウド」と差別化。MVP カスタムセットは**端末ローカルのみ**
- SET-01（PL-28）は公式固定のまま変更しない
