import "package:drift/drift.dart";

import "../../domain/models/streak_state.dart";
import "../../domain/repositories/streak_repository.dart";
import "app_database.dart";

class DriftStreakRepository implements StreakRepository {
  DriftStreakRepository(this._db);

  final AppDatabase _db;

  @override
  Future<StreakState> get() async {
    final row = await (_db.select(_db.streakStateEntries)
          ..where((t) => t.id.equals(1)))
        .getSingleOrNull();

    if (row == null) {
      final initial = StreakState.initial();
      await save(initial);
      return initial;
    }

    return StreakState(
      currentStreak: row.currentStreak,
      longestStreak: row.longestStreak,
      lastWorkoutDate: row.lastWorkoutDate == null
          ? null
          : DateTime.parse(row.lastWorkoutDate!),
      todayCompleted: row.todayCompleted,
    );
  }

  @override
  Future<void> save(StreakState state) async {
    await _db.into(_db.streakStateEntries).insertOnConflictUpdate(
          StreakStateEntriesCompanion(
            id: const Value(1),
            currentStreak: Value(state.currentStreak),
            longestStreak: Value(state.longestStreak),
            lastWorkoutDate: Value(state.lastWorkoutDate?.toIso8601String()),
            todayCompleted: Value(state.todayCompleted),
          ),
        );
  }
}
