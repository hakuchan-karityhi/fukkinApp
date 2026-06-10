import "dart:math";

import "../models/game_constants.dart";
import "level_service.dart";

class PenaltyResult {
  const PenaltyResult({required this.expLoss, required this.newAbsStage});

  final int expLoss;
  final int newAbsStage;
}

class PenaltyService {
  const PenaltyService(this._constants, this._levelService);

  final GameConstants _constants;
  final LevelService _levelService;

  int calculateExpLoss({
    required int daysMissed,
    required int lastWorkoutBaseExp,
  }) {
    if (daysMissed < 2) return 0;
    if (daysMissed == 2) {
      return max(
        _constants.penaltyMinExp,
        (lastWorkoutBaseExp * _constants.penaltySecondDayRate).floor(),
      );
    }
    return lastWorkoutBaseExp;
  }

  PenaltyResult applyPenalty({
    required int currentTotalExp,
    required int daysMissed,
    required int lastWorkoutBaseExp,
  }) {
    final loss = calculateExpLoss(
      daysMissed: daysMissed,
      lastWorkoutBaseExp: lastWorkoutBaseExp,
    );
    final newExp = max(0, currentTotalExp - loss);
    return PenaltyResult(
      expLoss: loss,
      newAbsStage: _levelService.getAbsStage(newExp),
    );
  }
}
