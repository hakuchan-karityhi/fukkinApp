import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:fukkin/application/complete_plank_usecase.dart";
import "package:fukkin/domain/models/game_constants.dart";
import "package:fukkin/domain/services/exp_calculator.dart";
import "package:fukkin/domain/services/level_service.dart";
import "package:fukkin/domain/services/milestone_service.dart";
import "package:fukkin/domain/services/streak_service.dart";
import "package:fukkin/infrastructure/local/app_database.dart";
import "package:fukkin/infrastructure/local/milestone_repository.dart";
import "package:fukkin/infrastructure/local/streak_repository.dart";
import "package:fukkin/infrastructure/local/user_progress_repository.dart";
import "package:fukkin/infrastructure/local/workout_repository.dart";
import "package:fukkin/infrastructure/master/plank_set_defaults.dart";
import "package:fukkin/infrastructure/master/plank_type_repository.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late CompletePlankUseCase useCase;
  final constants = GameConstants.defaults();
  final now = DateTime(2026, 6, 12, 12);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    useCase = CompletePlankUseCase(
      plankTypeRepository: AssetPlankTypeRepository(),
      userProgressRepository: DriftUserProgressRepository(db),
      streakRepository: DriftStreakRepository(db),
      workoutRepository: DriftWorkoutRepository(db),
      milestoneRepository: DriftMilestoneRepository(db),
      expCalculator: ExpCalculator(constants),
      streakService: StreakService(constants),
      levelService: LevelService(constants),
      milestoneService: const MilestoneService(),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test("プランクセット3種は sessionIndexOfDay が順に加算されストリークは初回のみ", () async {
    final results = <dynamic>[];
    for (final plankTypeId in PlankSetDefaults.set01.plankTypeIds) {
      results.add(
        await useCase.execute(
          plankTypeId: plankTypeId,
          targetSeconds: 30,
          now: now.add(Duration(minutes: results.length)),
        ),
      );
    }

    expect(results[0].sessionIndexOfDay, 1);
    expect(results[1].sessionIndexOfDay, 2);
    expect(results[2].sessionIndexOfDay, 3);
    expect(results[0].streakIncreased, isTrue);
    expect(results[1].streakIncreased, isFalse);
    expect(results[2].streakIncreased, isFalse);
    expect(results[0].streakAfter, 1);
    expect(results[2].streakAfter, 1);

    final records = await DriftWorkoutRepository(db).getByDate(
      DateTime(now.year, now.month, now.day),
    );
    expect(records.length, 3);
    expect(records.map((record) => record.sessionIndexOfDay).toList(), [1, 2, 3]);
  });

  test("同日2セット目は再実施ボーナスが適用される", () async {
    for (var i = 0; i < PlankSetDefaults.set01.plankTypeIds.length; i++) {
      await useCase.execute(
        plankTypeId: PlankSetDefaults.set01.plankTypeIds[i],
        targetSeconds: 30,
        now: now.add(Duration(minutes: i)),
      );
    }

    final firstOfSecondSet = await useCase.execute(
      plankTypeId: "PK-01",
      targetSeconds: 30,
      now: now.add(const Duration(hours: 2)),
    );

    expect(firstOfSecondSet.sessionIndexOfDay, 4);
    expect(firstOfSecondSet.repeatSessionBonusPercent, 15);
    expect(firstOfSecondSet.streakIncreased, isFalse);
  });
}
