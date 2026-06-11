import "package:flutter_test/flutter_test.dart";
import "package:fukkin/domain/models/game_constants.dart";
import "package:fukkin/domain/services/exp_calculator.dart";
import "package:fukkin/domain/services/level_service.dart";
import "package:fukkin/domain/services/penalty_service.dart";
import "package:fukkin/domain/services/streak_service.dart";
import "package:fukkin/infrastructure/remote_config/remote_config_game_constants_repository.dart";

void main() {
  final constants = GameConstants.defaults();
  late ExpCalculator expCalculator;
  late StreakService streakService;
  late LevelService levelService;
  late PenaltyService penaltyService;

  setUp(() {
    expCalculator = ExpCalculator(constants);
    streakService = StreakService(constants);
    levelService = LevelService(constants);
    penaltyService = PenaltyService(constants, levelService);
  });

  test("ストリーク7日で倍率1.2", () {
    expect(streakService.getMultiplier(7), 1.2);
  });

  test("EXP計算: 30秒 x1.0 x1.2 = 36", () {
    expect(
      expCalculator.calculate(
        baseExp: 30,
        difficultyMultiplier: 1.0,
        streakMultiplier: 1.2,
        sessionIndexOfDay: 1,
      ),
      36,
    );
  });

  test("再実施ボーナス倍率: 2回目+5%, 3回目+10%, 4回目以降+15%", () {
    expect(expCalculator.repeatSessionMultiplier(1), 1.0);
    expect(expCalculator.repeatSessionMultiplier(2), 1.05);
    expect(expCalculator.repeatSessionMultiplier(3), 1.10);
    expect(expCalculator.repeatSessionMultiplier(4), 1.15);
    expect(expCalculator.repeatSessionMultiplier(5), 1.15);
  });

  test("同日2回目: 30秒 x1.5 x1.2 x1.05 = 57", () {
    expect(
      expCalculator.calculate(
        baseExp: 30,
        difficultyMultiplier: 1.5,
        streakMultiplier: 1.2,
        sessionIndexOfDay: 2,
      ),
      57,
    );
  });

  test("日次上限150で超過分を切り捨て", () {
    expect(
      expCalculator.calculate(
        baseExp: 120,
        difficultyMultiplier: 1.5,
        streakMultiplier: 1.5,
        sessionIndexOfDay: 1,
        todayEarnedExp: 140,
      ),
      10,
    );
    expect(
      expCalculator.calculate(
        baseExp: 30,
        difficultyMultiplier: 1.0,
        streakMultiplier: 1.0,
        sessionIndexOfDay: 1,
        todayEarnedExp: 150,
      ),
      0,
    );
  });

  test("2日目ペナルティは max(10, floor(基本EXP x 0.5))", () {
    expect(
      penaltyService.calculateExpLoss(daysMissed: 2, lastWorkoutBaseExp: 30),
      15,
    );
  });

  test("Remote Config 未取得時はデフォルト値", () async {
    final repo = RemoteConfigGameConstantsRepository(
      fetchOverrides: () async => throw Exception("offline"),
    );
    final loaded = await repo.load();
    expect(loaded.dailyExpCap, 150);
    expect(loaded.repeatSessionBonusStep, 0.05);
    expect(loaded.repeatSessionBonusCap, 1.15);
    expect(loaded.levelThresholds, [150, 400, 800, 1400]);
  });

  test("Remote Config で repeat_session_bonus_cap を上書き", () async {
    final repo = RemoteConfigGameConstantsRepository(
      fetchOverrides: () async => {
        "repeat_session_bonus_cap": 1.2,
      },
    );
    final loaded = await repo.load();
    expect(loaded.repeatSessionBonusCap, 1.2);
  });

  test("Remote Config で level_thresholds を上書き", () async {
    final repo = RemoteConfigGameConstantsRepository(
      fetchOverrides: () async => {
        "level_thresholds": [100, 300, 600, 1000],
      },
    );
    final loaded = await repo.load();
    expect(loaded.levelThresholds, [100, 300, 600, 1000]);
  });
}
