class GameConstants {
  const GameConstants({
    required this.streakMultipliers,
    required this.levelThresholds,
    required this.repeatSessionBonusStep,
    required this.repeatSessionBonusCap,
    required this.dailyExpCap,
    required this.penaltyMinExp,
    required this.penaltySecondDayRate,
  });

  final List<StreakMultiplierTier> streakMultipliers;
  final List<int> levelThresholds;
  final double repeatSessionBonusStep;
  final double repeatSessionBonusCap;
  final int dailyExpCap;
  final int penaltyMinExp;
  final double penaltySecondDayRate;

  static GameConstants defaults() => const GameConstants(
        streakMultipliers: [
          StreakMultiplierTier(minDays: 1, maxDays: 2, multiplier: 1.0),
          StreakMultiplierTier(minDays: 3, maxDays: 6, multiplier: 1.1),
          StreakMultiplierTier(minDays: 7, maxDays: 13, multiplier: 1.2),
          StreakMultiplierTier(minDays: 14, maxDays: 29, multiplier: 1.3),
          StreakMultiplierTier(minDays: 30, maxDays: 9999, multiplier: 1.5),
        ],
        levelThresholds: [150, 400, 800, 1400],
        repeatSessionBonusStep: 0.05,
        repeatSessionBonusCap: 1.15,
        dailyExpCap: 150,
        penaltyMinExp: 10,
        penaltySecondDayRate: 0.5,
      );
}

class StreakMultiplierTier {
  const StreakMultiplierTier({
    required this.minDays,
    required this.maxDays,
    required this.multiplier,
  });

  final int minDays;
  final int maxDays;
  final double multiplier;
}
