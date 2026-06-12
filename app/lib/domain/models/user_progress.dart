class UserProgress {
  const UserProgress({
    required this.totalExp,
    required this.level,
    required this.absStage,
    this.lastPenaltyCheckDate,
  });

  final int totalExp;
  final int level;
  final int absStage;
  final DateTime? lastPenaltyCheckDate;

  UserProgress copyWith({
    int? totalExp,
    int? level,
    int? absStage,
    DateTime? lastPenaltyCheckDate,
  }) {
    return UserProgress(
      totalExp: totalExp ?? this.totalExp,
      level: level ?? this.level,
      absStage: absStage ?? this.absStage,
      lastPenaltyCheckDate: lastPenaltyCheckDate ?? this.lastPenaltyCheckDate,
    );
  }

  static UserProgress initial() => const UserProgress(
        totalExp: 0,
        level: 1,
        absStage: 0,
      );
}
