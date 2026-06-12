class StreakState {
  const StreakState({
    required this.currentStreak,
    required this.longestStreak,
    this.lastWorkoutDate,
    required this.todayCompleted,
  });

  final int currentStreak;
  final int longestStreak;
  final DateTime? lastWorkoutDate;
  final bool todayCompleted;

  StreakState copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastWorkoutDate,
    bool? todayCompleted,
  }) {
    return StreakState(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
      todayCompleted: todayCompleted ?? this.todayCompleted,
    );
  }

  static StreakState initial() => const StreakState(
        currentStreak: 0,
        longestStreak: 0,
        todayCompleted: false,
      );
}
