import "dart:io";

import "package:drift/drift.dart";
import "package:drift/native.dart";
import "package:path/path.dart" as p;
import "package:path_provider/path_provider.dart";

part "app_database.g.dart";

class UserProgressEntries extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get totalExp => integer().withDefault(const Constant(0))();
  IntColumn get level => integer().withDefault(const Constant(1))();
  IntColumn get absStage => integer().withDefault(const Constant(0))();
  TextColumn get lastPenaltyCheckDate => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class StreakStateEntries extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
  IntColumn get longestStreak => integer().withDefault(const Constant(0))();
  TextColumn get lastWorkoutDate => text().nullable()();
  BoolColumn get todayCompleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class WorkoutRecordEntries extends Table {
  TextColumn get id => text()();
  TextColumn get date => text()();
  TextColumn get plankTypeId => text()();
  IntColumn get targetSeconds => integer()();
  IntColumn get earnedExp => integer()();
  DateTimeColumn get completedAt => dateTime()();
  IntColumn get sessionIndexOfDay => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class MilestoneTargetEntries extends Table {
  IntColumn get days => integer()();
  TextColumn get title => text()();
  BoolColumn get isBuiltin => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {days};
}

class MilestoneAchievementEntries extends Table {
  IntColumn get days => integer()();
  TextColumn get title => text()();
  DateTimeColumn get achievedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {days};
}

class CustomPlankTypeEntries extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    UserProgressEntries,
    StreakStateEntries,
    WorkoutRecordEntries,
    MilestoneTargetEntries,
    MilestoneAchievementEntries,
    CustomPlankTypeEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(milestoneTargetEntries);
            await m.createTable(milestoneAchievementEntries);
          }
          if (from < 3) {
            await m.createTable(customPlankTypeEntries);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, "fukkin.sqlite"));
    return NativeDatabase.createInBackground(file);
  });
}
