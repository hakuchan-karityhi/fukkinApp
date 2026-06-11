import "../../domain/models/streak_state.dart";

enum StreakDebugMode {
  /// 次の筋トレ完了で X 日目になる（マイルストーン検証向け）
  nextCompletionReaches,

  /// ホーム等に「ストリーク X 日」と表示（今日は未実施）
  ongoingNotDoneToday,

  /// ホーム等に「ストリーク X 日」と表示（今日は実施済み）
  ongoingDoneToday,
}

class StreakDebugService {
  const StreakDebugService();

  StreakState buildFakeState({
    required int targetDays,
    required StreakDebugMode mode,
    required StreakState current,
    DateTime? now,
  }) {
    if (targetDays < 1 || targetDays > 999) {
      throw ArgumentError.value(targetDays, "targetDays", "1〜999の範囲で指定してください");
    }

    final today = _dateOnly(now ?? DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));

    return switch (mode) {
      StreakDebugMode.nextCompletionReaches => _nextCompletionReaches(
          targetDays: targetDays,
          current: current,
          yesterday: yesterday,
        ),
      StreakDebugMode.ongoingNotDoneToday => _ongoing(
          targetDays: targetDays,
          current: current,
          lastWorkoutDate: yesterday,
          todayCompleted: false,
        ),
      StreakDebugMode.ongoingDoneToday => _ongoing(
          targetDays: targetDays,
          current: current,
          lastWorkoutDate: today,
          todayCompleted: true,
        ),
    };
  }

  StreakState _nextCompletionReaches({
    required int targetDays,
    required StreakState current,
    required DateTime yesterday,
  }) {
    final streakBefore = targetDays - 1;

    return StreakState(
      currentStreak: streakBefore,
      longestStreak: _maxLongest(current.longestStreak, streakBefore),
      lastWorkoutDate: streakBefore <= 0 ? null : yesterday,
      todayCompleted: false,
    );
  }

  StreakState _ongoing({
    required int targetDays,
    required StreakState current,
    required DateTime lastWorkoutDate,
    required bool todayCompleted,
  }) {
    return StreakState(
      currentStreak: targetDays,
      longestStreak: _maxLongest(current.longestStreak, targetDays),
      lastWorkoutDate: lastWorkoutDate,
      todayCompleted: todayCompleted,
    );
  }

  int _maxLongest(int current, int candidate) {
    return current > candidate ? current : candidate;
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

String streakDebugModeLabel(StreakDebugMode mode) {
  return switch (mode) {
    StreakDebugMode.nextCompletionReaches => "次の筋トレ完了でX日目になる",
    StreakDebugMode.ongoingNotDoneToday => "現在X日継続中（今日未実施）",
    StreakDebugMode.ongoingDoneToday => "現在X日継続中（今日済み）",
  };
}
