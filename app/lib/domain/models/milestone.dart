class MilestoneTarget {
  const MilestoneTarget({
    required this.days,
    required this.title,
    this.isBuiltin = false,
  });

  final int days;
  final String title;
  final bool isBuiltin;

  MilestoneTarget copyWith({
    int? days,
    String? title,
    bool? isBuiltin,
  }) {
    return MilestoneTarget(
      days: days ?? this.days,
      title: title ?? this.title,
      isBuiltin: isBuiltin ?? this.isBuiltin,
    );
  }
}

class MilestoneAchievement {
  const MilestoneAchievement({
    required this.days,
    required this.title,
    required this.achievedAt,
  });

  final int days;
  final String title;
  final DateTime achievedAt;
}

enum MilestoneCelebrationTier {
  small,
  medium,
  large,
}
