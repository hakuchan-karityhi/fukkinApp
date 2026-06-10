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
        isSecondSessionToday: false,
      ),
      36,
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
    expect(loaded.levelThresholds, [150, 400, 800, 1400]);
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
