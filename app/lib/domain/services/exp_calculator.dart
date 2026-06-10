import "../models/game_constants.dart";

class ExpCalculator {
  const ExpCalculator(this._constants);

  final GameConstants _constants;

  int calculate({
    required int baseExp,
    required double difficultyMultiplier,
    required double streakMultiplier,
    required bool isSecondSessionToday,
  }) {
    var exp = baseExp * difficultyMultiplier * streakMultiplier;
    if (isSecondSessionToday) {
      exp *= _constants.secondSessionExpRate;
    }
    return exp.round();
  }
}
