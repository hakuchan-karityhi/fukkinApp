import "package:drift/drift.dart";

import "../../domain/models/workout_record.dart";
import "../../domain/repositories/workout_repository.dart";
import "app_database.dart";

class DriftWorkoutRepository implements WorkoutRepository {
  DriftWorkoutRepository(this._db);

  final AppDatabase _db;

  @override
  Future<void> add(WorkoutRecord record) async {
    await _db.into(_db.workoutRecordEntries).insert(
          WorkoutRecordEntriesCompanion(
            id: Value(record.id),
            date: Value(_dateKey(record.date)),
            plankTypeId: Value(record.plankTypeId),
            targetSeconds: Value(record.targetSeconds),
            earnedExp: Value(record.earnedExp),
            completedAt: Value(record.completedAt),
            sessionIndexOfDay: Value(record.sessionIndexOfDay),
          ),
        );
  }

  @override
  Future<List<WorkoutRecord>> getByDate(DateTime date) async {
    final key = _dateKey(date);
    final rows = await (_db.select(_db.workoutRecordEntries)
          ..where((t) => t.date.equals(key))
          ..orderBy([(t) => OrderingTerm.asc(t.completedAt)]))
        .get();

    return rows
        .map(
          (row) => WorkoutRecord(
            id: row.id,
            date: DateTime.parse(row.date),
            plankTypeId: row.plankTypeId,
            targetSeconds: row.targetSeconds,
            earnedExp: row.earnedExp,
            completedAt: row.completedAt,
            sessionIndexOfDay: row.sessionIndexOfDay,
          ),
        )
        .toList();
  }

  String _dateKey(DateTime date) =>
      DateTime(date.year, date.month, date.day).toIso8601String();
}
