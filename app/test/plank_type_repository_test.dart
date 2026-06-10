import "package:flutter_test/flutter_test.dart";
import "package:fukkin/infrastructure/master/plank_type_repository.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test("plank_types.json から7種目を読み込める", () async {
    final repo = AssetPlankTypeRepository();
    final betaTypes = await repo.getAll(betaMode: true);
    final mvpTypes = await repo.getAll(betaMode: false);

    expect(betaTypes.length, 7);
    expect(mvpTypes.length, 2);
    expect(betaTypes.map((t) => t.id), [
      "PK-01",
      "PK-02",
      "PK-03",
      "PK-04",
      "PK-05",
      "PK-06",
      "PK-07",
    ]);
  });

  test("PK-05 は isPerSide=true", () async {
    final repo = AssetPlankTypeRepository();
    final sidePlank = await repo.getById("PK-05");

    expect(sidePlank, isNotNull);
    expect(sidePlank!.isPerSide, isTrue);
    expect(sidePlank.expMultiplier, 1.3);
  });

  test("PK-03 の倍率と難易度", () async {
    final repo = AssetPlankTypeRepository();
    final highPlank = await repo.getById("PK-03");

    expect(highPlank, isNotNull);
    expect(highPlank!.name, "ハイプランク");
    expect(highPlank.difficulty, 2);
    expect(highPlank.expMultiplier, 1.2);
    expect(highPlank.enabledInMvp, isFalse);
    expect(highPlank.enabledInBeta, isTrue);
  });
}
