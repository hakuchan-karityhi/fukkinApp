import "../models/game_constants.dart";

class LevelService {
  const LevelService(this._constants);

  final GameConstants _constants;

  int getLevel(int totalExp) {
    var level = 1;
    for (final threshold in _constants.levelThresholds) {
      if (totalExp >= threshold) {
        level++;
      }
    }
    return level;
  }

  int getAbsStage(int totalExp) {
    final thresholds = _constants.levelThresholds;
    if (totalExp < thresholds[0]) return 0;
    if (totalExp < thresholds[1]) return 1;
    if (totalExp < thresholds[2]) return 2;
    if (totalExp < thresholds[3]) return 3;
    return 4;
  }

  int expToNextLevel(int totalExp) {
    for (final threshold in _constants.levelThresholds) {
      if (totalExp < threshold) return threshold - totalExp;
    }
    return 100;
  }
}
