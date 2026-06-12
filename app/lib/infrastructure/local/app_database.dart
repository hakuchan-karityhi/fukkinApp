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

class CustomPlankSetEntries extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CustomPlankSetItemEntries extends Table {
  TextColumn get setId =>
      text().references(CustomPlankSetEntries, #id, onDelete: KeyAction.cascade)();
  IntColumn get sortOrder => integer()();
  TextColumn get plankTypeId => text()();
  IntColumn get targetSeconds => integer()();

  @override
  Set<Column<Object>> get primaryKey => {setId, sortOrder};
}

@DriftDatabase(
  tables: [
    UserProgressEntries,
    StreakStateEntries,
    WorkoutRecordEntries,
    MilestoneTargetEntries,
    MilestoneAchievementEntries,
    CustomPlankTypeEntries,
    CustomPlankSetEntries,
    CustomPlankSetItemEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 5;

  static const _createCustomPlankTypeTableSql = """
CREATE TABLE IF NOT EXISTS custom_plank_type_entries (
  id TEXT NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  created_at INTEGER NOT NULL
)
""";

  static const _createCustomPlankSetTableSql = """
CREATE TABLE IF NOT EXISTS custom_plank_set_entries (
  id TEXT NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  updated_at INTEGER NOT NULL
)
""";

  static const _createCustomPlankSetItemTableSql = """
CREATE TABLE IF NOT EXISTS custom_plank_set_item_entries (
  set_id TEXT NOT NULL,
  sort_order INTEGER NOT NULL,
  plank_type_id TEXT NOT NULL,
  target_seconds INTEGER NOT NULL,
  PRIMARY KEY (set_id, sort_order),
  FOREIGN KEY (set_id) REFERENCES custom_plank_set_entries(id) ON DELETE CASCADE
)
""";

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement(_createCustomPlankTypeTableSql);
          await customStatement(_createCustomPlankSetTableSql);
          await customStatement(_createCustomPlankSetItemTableSql);
        },
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
          if (from < 4) {
            await customStatement(_createCustomPlankTypeTableSql);
          }
          if (from < 5) {
            await m.createTable(customPlankSetEntries);
            await m.createTable(customPlankSetItemEntries);
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
