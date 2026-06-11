import "../models/milestone.dart";

class MilestoneDefaults {
  static const builtinTargets = <MilestoneTarget>[
    MilestoneTarget(days: 3, title: "習慣の芽", isBuiltin: true),
    MilestoneTarget(days: 7, title: "1週間の相棒", isBuiltin: true),
    MilestoneTarget(days: 14, title: "2週間マスター", isBuiltin: true),
    MilestoneTarget(days: 30, title: "継続の証", isBuiltin: true),
    MilestoneTarget(days: 60, title: "習慣の達人", isBuiltin: true),
    MilestoneTarget(days: 100, title: "レジェンド", isBuiltin: true),
  ];
}

class MilestoneService {
  const MilestoneService();

  MilestoneAchievement? detectAchievement({
    required int streakAfter,
    required bool streakIncreased,
    required List<MilestoneTarget> targets,
    required List<MilestoneAchievement> achieved,
    required DateTime achievedAt,
  }) {
    if (!streakIncreased) return null;

    final target = _targetForDays(targets, streakAfter);
    if (target == null) return null;
    if (achieved.any((item) => item.days == streakAfter)) return null;

    return MilestoneAchievement(
      days: target.days,
      title: target.title,
      achievedAt: achievedAt,
    );
  }

  MilestoneTarget? _targetForDays(List<MilestoneTarget> targets, int days) {
    for (final target in targets) {
      if (target.days == days) return target;
    }
    return null;
  }

  MilestoneCelebrationTier celebrationTier(int days) {
    if (days >= 60) return MilestoneCelebrationTier.large;
    if (days >= 14) return MilestoneCelebrationTier.medium;
    return MilestoneCelebrationTier.small;
  }

  List<MilestoneTarget> sortedTargets(List<MilestoneTarget> targets) {
    final copy = List<MilestoneTarget>.from(targets);
    copy.sort((a, b) => a.days.compareTo(b.days));
    return copy;
  }
}
