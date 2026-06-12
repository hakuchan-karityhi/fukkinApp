import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:fukkin/domain/models/custom_plank_type.dart";
import "package:fukkin/infrastructure/local/app_database.dart";
import "package:fukkin/infrastructure/local/custom_plank_type_repository.dart";
import "package:fukkin/infrastructure/master/composite_plank_type_repository.dart";
import "package:fukkin/infrastructure/master/plank_type_repository.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DriftCustomPlankTypeRepository customRepo;
  late CompositePlankTypeRepository compositeRepo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    customRepo = DriftCustomPlankTypeRepository(db);
    compositeRepo = CompositePlankTypeRepository(
      assetRepository: AssetPlankTypeRepository(),
      customPlankTypeRepository: customRepo,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test("カスタム種目を保存・取得できる", () async {
    final type = CustomPlankType(
      id: "CUST-test1",
      name: "朝のプランク",
      createdAt: DateTime(2026, 6, 12),
    );

    await customRepo.save(type);

    final loaded = await customRepo.getById("CUST-test1");
    expect(loaded, isNotNull);
    expect(loaded!.name, "朝のプランク");
    expect(await customRepo.count(), 1);
  });

  test("CompositePlankTypeRepository が公式の後にカスタム種目を返す", () async {
    await customRepo.save(
      CustomPlankType(
        id: "CUST-test2",
        name: "夜のプランク",
        createdAt: DateTime(2026, 6, 12),
      ),
    );

    final types = await compositeRepo.getAll(betaMode: true);
    final custom = types.where((t) => t.id == "CUST-test2").toList();

    expect(custom, hasLength(1));
    expect(custom.first.name, "夜のプランク");
    expect(custom.first.expMultiplier, 1.0);
    expect(custom.first.poseAssetId, "basic_plank");
    expect(types.indexOf(custom.first), greaterThan(0));
  });

  test("getById でカスタム種目を解決できる", () async {
    await customRepo.save(
      CustomPlankType(
        id: "CUST-test3",
        name: "テスト種目",
        createdAt: DateTime(2026, 6, 12),
      ),
    );

    final plank = await compositeRepo.getById("CUST-test3");
    expect(plank, isNotNull);
    expect(plank!.name, "テスト種目");
    expect(plank.difficulty, 1);
  });

  test("削除後は getById が null を返す", () async {
    await customRepo.save(
      CustomPlankType(
        id: "CUST-delete",
        name: "削除対象",
        createdAt: DateTime(2026, 6, 12),
      ),
    );

    await customRepo.delete("CUST-delete");

    expect(await customRepo.getById("CUST-delete"), isNull);
    expect(await compositeRepo.getById("CUST-delete"), isNull);
  });
}
