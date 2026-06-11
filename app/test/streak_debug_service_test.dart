import "package:flutter_test/flutter_test.dart";
import "package:fukkin/domain/models/streak_state.dart";
import "package:fukkin/presentation/debug/streak_debug_service.dart";

void main() {
  const service = StreakDebugService();
  const current = StreakState(
    currentStreak: 2,
    longestStreak: 5,
    todayCompleted: true,
  );
  final now = DateTime(2026, 6, 11, 12);

  test("次の完了で7日目になるよう偽装する", () {
    final fake = service.buildFakeState(
      targetDays: 7,
      mode: StreakDebugMode.nextCompletionReaches,
      current: current,
      now: now,
    );

    expect(fake.currentStreak, 6);
    expect(fake.todayCompleted, isFalse);
    expect(fake.lastWorkoutDate, DateTime(2026, 6, 10));
  });

  test("現在30日継続中（今日未実施）を偽装する", () {
    final fake = service.buildFakeState(
      targetDays: 30,
      mode: StreakDebugMode.ongoingNotDoneToday,
      current: current,
      now: now,
    );

    expect(fake.currentStreak, 30);
    expect(fake.todayCompleted, isFalse);
    expect(fake.lastWorkoutDate, DateTime(2026, 6, 10));
    expect(fake.longestStreak, 30);
  });

  test("現在100日継続中（今日済み）を偽装する", () {
    final fake = service.buildFakeState(
      targetDays: 100,
      mode: StreakDebugMode.ongoingDoneToday,
      current: current,
      now: now,
    );

    expect(fake.currentStreak, 100);
    expect(fake.todayCompleted, isTrue);
    expect(fake.lastWorkoutDate, DateTime(2026, 6, 11));
  });

  test("1日目は最終実施日なしで次の完了待ちになる", () {
    final fake = service.buildFakeState(
      targetDays: 1,
      mode: StreakDebugMode.nextCompletionReaches,
      current: StreakState.initial(),
      now: now,
    );

    expect(fake.currentStreak, 0);
    expect(fake.lastWorkoutDate, isNull);
    expect(fake.todayCompleted, isFalse);
  });
}
