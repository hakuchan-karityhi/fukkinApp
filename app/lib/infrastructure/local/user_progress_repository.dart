import "package:drift/drift.dart";

import "../../domain/models/user_progress.dart";
import "../../domain/repositories/user_progress_repository.dart";
import "app_database.dart";

class DriftUserProgressRepository implements UserProgressRepository {
  DriftUserProgressRepository(this._db);

  final AppDatabase _db;

  @override
  Future<UserProgress> get() async {
    final row = await (_db.select(_db.userProgressEntries)
          ..where((t) => t.id.equals(1)))
        .getSingleOrNull();

    if (row == null) {
      final initial = UserProgress.initial();
      await save(initial);
      return initial;
    }

    return UserProgress(
      totalExp: row.totalExp,
      level: row.level,
      absStage: row.absStage,
      lastPenaltyCheckDate: row.lastPenaltyCheckDate == null
          ? null
          : DateTime.parse(row.lastPenaltyCheckDate!),
    );
  }

  @override
  Future<void> save(UserProgress progress) async {
    await _db.into(_db.userProgressEntries).insertOnConflictUpdate(
          UserProgressEntriesCompanion(
            id: const Value(1),
            totalExp: Value(progress.totalExp),
            level: Value(progress.level),
            absStage: Value(progress.absStage),
            lastPenaltyCheckDate: Value(
              progress.lastPenaltyCheckDate?.toIso8601String(),
            ),
          ),
        );
  }
}
