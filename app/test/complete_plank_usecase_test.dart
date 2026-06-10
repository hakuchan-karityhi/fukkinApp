import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:fukkin/application/complete_plank_usecase.dart";
import "package:fukkin/domain/models/game_constants.dart";
import "package:fukkin/domain/services/exp_calculator.dart";
import "package:fukkin/domain/services/level_service.dart";
import "package:fukkin/domain/services/streak_service.dart";
import "package:fukkin/infrastructure/local/app_database.dart";
import "package:fukkin/infrastructure/local/streak_repository.dart";
import "package:fukkin/infrastructure/local/user_progress_repository.dart";
import "package:fukkin/infrastructure/local/workout_repository.dart";
import "package:fukkin/infrastructure/master/plank_type_repository.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late CompletePlankUseCase useCase;
  final constants = GameConstants.defaults();

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    useCase = CompletePlankUseCase(
      plankTypeRepository: AssetPlankTypeRepository(),
      userProgressRepository: DriftUserProgressRepository(db),
      streakRepository: DriftStreakRepository(db),
      workoutRepository: DriftWorkoutRepository(db),
      expCalculator: ExpCalculator(constants),
      streakService: StreakService(constants),
      levelService: LevelService(constants),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test("ベーシック30秒 x1.0 xストリーク1.0 = 30 EXP", () async {
    final result = await useCase.execute(
      plankTypeId: "PK-01",
      targetSeconds: 30,
      now: DateTime(2026, 6, 11, 12),
    );

    expect(result.earnedExp, 30);
    expect(result.baseExp, 30);
    expect(result.streakAfter, 1);
    expect(result.streakIncreased, isTrue);
    expect(result.totalExpAfter, 30);
  });

  test("ハイプランク30秒 x1.2 xストリーク7日1.2 = 43 EXP", () async {
    await useCase.execute(
      plankTypeId: "PK-01",
      targetSeconds: 30,
      now: DateTime(2026, 6, 4, 12),
    );

    for (var day = 5; day <= 10; day++) {
      await useCase.execute(
        plankTypeId: "PK-01",
        targetSeconds: 30,
        now: DateTime(2026, 6, day, 12),
      );
    }

    final result = await useCase.execute(
      plankTypeId: "PK-03",
      targetSeconds: 30,
      now: DateTime(2026, 6, 11, 12),
    );

    expect(result.earnedExp, 43);
    expect(result.streakAfter, 8);
  });

  test("サイドプランクは1側の秒数が基本EXP", () async {
    final result = await useCase.execute(
      plankTypeId: "PK-05",
      targetSeconds: 20,
      now: DateTime(2026, 6, 11, 12),
    );

    expect(result.baseExp, 20);
    expect(result.earnedExp, 26);
  });

  test("実施履歴に種目IDが保存される", () async {
    await useCase.execute(
      plankTypeId: "PK-04",
      targetSeconds: 25,
      now: DateTime(2026, 6, 11, 12),
    );

    final records = await DriftWorkoutRepository(db).getByDate(
      DateTime(2026, 6, 11),
    );

    expect(records.length, 1);
    expect(records.first.plankTypeId, "PK-04");
    expect(records.first.targetSeconds, 25);
  });
}
