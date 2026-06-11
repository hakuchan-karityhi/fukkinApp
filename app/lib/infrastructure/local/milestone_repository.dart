import "package:drift/drift.dart";

import "../../domain/models/milestone.dart";
import "../../domain/repositories/milestone_repository.dart";
import "../../domain/services/milestone_service.dart";
import "app_database.dart";

class DriftMilestoneRepository implements MilestoneRepository {
  DriftMilestoneRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<MilestoneTarget>> getTargets() async {
    final rows = await (_db.select(_db.milestoneTargetEntries)
          ..orderBy([(t) => OrderingTerm.asc(t.days)]))
        .get();

    if (rows.isEmpty) {
      for (final target in MilestoneDefaults.builtinTargets) {
        await addTarget(target);
      }
      return MilestoneDefaults.builtinTargets;
    }

    return rows
        .map(
          (row) => MilestoneTarget(
            days: row.days,
            title: row.title,
            isBuiltin: row.isBuiltin,
          ),
        )
        .toList();
  }

  @override
  Future<void> addTarget(MilestoneTarget target) async {
    await _db.into(_db.milestoneTargetEntries).insertOnConflictUpdate(
          MilestoneTargetEntriesCompanion(
            days: Value(target.days),
            title: Value(target.title),
            isBuiltin: Value(target.isBuiltin),
          ),
        );
  }

  @override
  Future<void> removeTarget(int days) async {
    await (_db.delete(_db.milestoneTargetEntries)
          ..where((t) => t.days.equals(days) & t.isBuiltin.equals(false)))
        .go();
  }

  @override
  Future<List<MilestoneAchievement>> getAchieved() async {
    final rows = await (_db.select(_db.milestoneAchievementEntries)
          ..orderBy([(t) => OrderingTerm.asc(t.days)]))
        .get();

    return rows
        .map(
          (row) => MilestoneAchievement(
            days: row.days,
            title: row.title,
            achievedAt: row.achievedAt,
          ),
        )
        .toList();
  }

  @override
  Future<void> addAchievement(MilestoneAchievement achievement) async {
    await _db.into(_db.milestoneAchievementEntries).insertOnConflictUpdate(
          MilestoneAchievementEntriesCompanion(
            days: Value(achievement.days),
            title: Value(achievement.title),
            achievedAt: Value(achievement.achievedAt),
          ),
        );
  }
}
