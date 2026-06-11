import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:fukkin/domain/models/milestone.dart";
import "package:fukkin/infrastructure/local/app_database.dart";
import "package:fukkin/infrastructure/local/milestone_repository.dart";

void main() {
  late AppDatabase db;
  late DriftMilestoneRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftMilestoneRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test("初回取得時にデフォルト目標をシードする", () async {
    final targets = await repository.getTargets();

    expect(targets.length, 6);
    expect(targets.map((item) => item.days), containsAll([3, 7, 14, 30, 60, 100]));
  });

  test("カスタム目標を追加・削除できる", () async {
    await repository.getTargets();
    await repository.addTarget(
      const MilestoneTarget(days: 45, title: "私の目標"),
    );

    var targets = await repository.getTargets();
    expect(targets.any((item) => item.days == 45), isTrue);

    await repository.removeTarget(45);
    targets = await repository.getTargets();
    expect(targets.any((item) => item.days == 45), isFalse);
  });

  test("達成記録が永続化される", () async {
    final achievement = MilestoneAchievement(
      days: 7,
      title: "1週間の相棒",
      achievedAt: DateTime(2026, 6, 11),
    );

    await repository.addAchievement(achievement);
    final achieved = await repository.getAchieved();

    expect(achieved.length, 1);
    expect(achieved.first.days, 7);
  });
}
