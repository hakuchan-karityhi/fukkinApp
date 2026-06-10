import "../models/game_constants.dart";

class StreakService {
  const StreakService(this._constants);

  final GameConstants _constants;

  double getMultiplier(int currentStreakDays) {
    for (final tier in _constants.streakMultipliers) {
      if (currentStreakDays >= tier.minDays &&
          currentStreakDays <= tier.maxDays) {
        return tier.multiplier;
      }
    }
    return 1.0;
  }
}
