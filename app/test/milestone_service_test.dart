import "package:flutter_test/flutter_test.dart";
import "package:fukkin/domain/models/milestone.dart";
import "package:fukkin/domain/services/milestone_service.dart";

void main() {
  const service = MilestoneService();
  final targets = [
    const MilestoneTarget(days: 3, title: "習慣の芽", isBuiltin: true),
    const MilestoneTarget(days: 60, title: "習慣の達人", isBuiltin: true),
    const MilestoneTarget(days: 45, title: "私の目標"),
  ];

  test("ストリーク増加時に設定済みマイルストーンを検出する", () {
    final result = service.detectAchievement(
      streakAfter: 3,
      streakIncreased: true,
      targets: targets,
      achieved: const [],
      achievedAt: DateTime(2026, 6, 11),
    );

    expect(result?.days, 3);
    expect(result?.title, "習慣の芽");
  });

  test("カスタム目標日数でも達成を記録する", () {
    final result = service.detectAchievement(
      streakAfter: 45,
      streakIncreased: true,
      targets: targets,
      achieved: const [],
      achievedAt: DateTime(2026, 7, 1),
    );

    expect(result?.days, 45);
    expect(result?.title, "私の目標");
  });

  test("同日2回目はマイルストーンを発火しない", () {
    final result = service.detectAchievement(
      streakAfter: 3,
      streakIncreased: false,
      targets: targets,
      achieved: const [],
      achievedAt: DateTime(2026, 6, 11),
    );

    expect(result, isNull);
  });

  test("既に達成済みの日数は再発火しない", () {
    final result = service.detectAchievement(
      streakAfter: 3,
      streakIncreased: true,
      targets: targets,
      achieved: [
        MilestoneAchievement(
          days: 3,
          title: "習慣の芽",
          achievedAt: DateTime(2026, 6, 9),
        ),
      ],
      achievedAt: DateTime(2026, 6, 11),
    );

    expect(result, isNull);
  });

  test("60日以上は大型演出ティア", () {
    expect(service.celebrationTier(60), MilestoneCelebrationTier.large);
    expect(service.celebrationTier(100), MilestoneCelebrationTier.large);
    expect(service.celebrationTier(7), MilestoneCelebrationTier.small);
  });
}
