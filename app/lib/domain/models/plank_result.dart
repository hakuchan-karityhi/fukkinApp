import "milestone.dart";

class PlankResult {
  const PlankResult({
    required this.earnedExp,
    required this.baseExp,
    required this.plankTypeId,
    required this.plankTypeName,
    required this.targetSeconds,
    required this.streakAfter,
    required this.streakIncreased,
    required this.totalExpAfter,
    required this.levelAfter,
    required this.levelUp,
    required this.absStageAfter,
    required this.sessionIndexOfDay,
    required this.repeatSessionBonusPercent,
    required this.dailyCapReached,
    required this.streakMultiplier,
    required this.difficultyMultiplier,
    this.milestoneReached,
  });

  final int earnedExp;
  final int baseExp;
  final String plankTypeId;
  final String plankTypeName;
  final int targetSeconds;
  final int streakAfter;
  final bool streakIncreased;
  final int totalExpAfter;
  final int levelAfter;
  final bool levelUp;
  final int absStageAfter;
  final int sessionIndexOfDay;
  final int repeatSessionBonusPercent;
  final bool dailyCapReached;
  final double streakMultiplier;
  final double difficultyMultiplier;
  final MilestoneAchievement? milestoneReached;
}
