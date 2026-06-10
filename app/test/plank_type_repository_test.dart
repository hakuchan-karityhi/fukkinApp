import "package:flutter_test/flutter_test.dart";
import "package:fukkin/infrastructure/master/plank_type_repository.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test("plank_types.json から9種目を読み込める", () async {
    final repo = AssetPlankTypeRepository();
    final betaTypes = await repo.getAll(betaMode: true);
    final mvpTypes = await repo.getAll(betaMode: false);

    expect(betaTypes.length, 9);
    expect(mvpTypes.length, 2);
    expect(betaTypes.map((t) => t.id), [
      "PK-01",
      "PK-02",
      "PK-03",
      "PK-04",
      "PK-05",
      "PK-06",
      "PK-07",
      "PK-08",
      "PK-09",
    ]);
  });

  test("PK-05 は isPerSide=true", () async {
    final repo = AssetPlankTypeRepository();
    final sidePlank = await repo.getById("PK-05");

    expect(sidePlank, isNotNull);
    expect(sidePlank!.isPerSide, isTrue);
    expect(sidePlank.expMultiplier, 1.3);
  });

  test("PK-08, PK-09 が β で読み込める", () async {
    final repo = AssetPlankTypeRepository();
    final legLift = await repo.getById("PK-08");
    final shoulderTap = await repo.getById("PK-09");

    expect(legLift, isNotNull);
    expect(legLift!.name, "レッグリフトプランク");
    expect(legLift.expMultiplier, 1.4);

    expect(shoulderTap, isNotNull);
    expect(shoulderTap!.name, "ショルダータッププランク");
    expect(shoulderTap.expMultiplier, 1.5);
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
