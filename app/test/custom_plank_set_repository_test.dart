import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:fukkin/domain/models/custom_plank_set.dart";
import "package:fukkin/infrastructure/local/app_database.dart";
import "package:fukkin/infrastructure/local/custom_plank_set_repository.dart";

void main() {
  late AppDatabase db;
  late DriftCustomPlankSetRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftCustomPlankSetRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test("カスタムセットを保存・取得できる", () async {
    final set = CustomPlankSet(
      id: "CSET-test1",
      name: "朝セット",
      updatedAt: DateTime(2026, 6, 12),
      items: const [
        CustomPlankSetItem(plankTypeId: "PK-01", targetSeconds: 30),
        CustomPlankSetItem(plankTypeId: "PK-02", targetSeconds: 25),
      ],
    );

    await repository.save(set);

    final loaded = await repository.getById("CSET-test1");
    expect(loaded, isNotNull);
    expect(loaded!.name, "朝セット");
    expect(loaded.items, hasLength(2));
    expect(loaded.items[0].plankTypeId, "PK-01");
    expect(loaded.items[1].targetSeconds, 25);
  });

  test("種目順を更新して保存できる", () async {
    await repository.save(
      CustomPlankSet(
        id: "CSET-test2",
        name: "旧順序",
        updatedAt: DateTime(2026, 6, 12),
        items: const [
          CustomPlankSetItem(plankTypeId: "PK-01", targetSeconds: 30),
          CustomPlankSetItem(plankTypeId: "PK-02", targetSeconds: 30),
        ],
      ),
    );

    await repository.save(
      CustomPlankSet(
        id: "CSET-test2",
        name: "新順序",
        updatedAt: DateTime(2026, 6, 13),
        items: const [
          CustomPlankSetItem(plankTypeId: "PK-02", targetSeconds: 40),
          CustomPlankSetItem(plankTypeId: "PK-01", targetSeconds: 20),
        ],
      ),
    );

    final loaded = await repository.getById("CSET-test2");
    expect(loaded!.name, "新順序");
    expect(loaded.items.map((item) => item.plankTypeId), ["PK-02", "PK-01"]);
    expect(loaded.items.first.targetSeconds, 40);
  });

  test("削除後は getById が null を返す", () async {
    await repository.save(
      CustomPlankSet(
        id: "CSET-delete",
        name: "削除対象",
        updatedAt: DateTime(2026, 6, 12),
        items: const [
          CustomPlankSetItem(plankTypeId: "PK-01", targetSeconds: 30),
          CustomPlankSetItem(plankTypeId: "PK-02", targetSeconds: 30),
        ],
      ),
    );

    await repository.delete("CSET-delete");

    expect(await repository.getById("CSET-delete"), isNull);
  });
}
