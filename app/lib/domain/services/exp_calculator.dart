import "../models/game_constants.dart";

class ExpCalculator {
  const ExpCalculator(this._constants);

  final GameConstants _constants;

  double repeatSessionMultiplier(int sessionIndexOfDay) {
    if (sessionIndexOfDay <= 1) {
      return 1.0;
    }

    final multiplier = 1.0 +
        _constants.repeatSessionBonusStep * (sessionIndexOfDay - 1);
    return multiplier > _constants.repeatSessionBonusCap
        ? _constants.repeatSessionBonusCap
        : multiplier;
  }

  int repeatSessionBonusPercent(int sessionIndexOfDay) {
    final multiplier = repeatSessionMultiplier(sessionIndexOfDay);
    return ((multiplier - 1.0) * 100).round();
  }

  int calculateRaw({
    required int baseExp,
    required double difficultyMultiplier,
    required double streakMultiplier,
    required int sessionIndexOfDay,
  }) {
    final repeatMultiplier = repeatSessionMultiplier(sessionIndexOfDay);
    return (baseExp *
            difficultyMultiplier *
            streakMultiplier *
            repeatMultiplier)
        .round();
  }

  int calculate({
    required int baseExp,
    required double difficultyMultiplier,
    required double streakMultiplier,
    required int sessionIndexOfDay,
    int todayEarnedExp = 0,
  }) {
    final rawExp = calculateRaw(
      baseExp: baseExp,
      difficultyMultiplier: difficultyMultiplier,
      streakMultiplier: streakMultiplier,
      sessionIndexOfDay: sessionIndexOfDay,
    );

    final remaining = _constants.dailyExpCap - todayEarnedExp;
    if (remaining <= 0) {
      return 0;
    }

    return rawExp > remaining ? remaining : rawExp;
  }
}
