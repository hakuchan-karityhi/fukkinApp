import "milestone.dart";
import "plank_result.dart";

class PlankSetDefinition {
  const PlankSetDefinition({
    required this.id,
    required this.name,
    required this.plankTypeIds,
  });

  final String id;
  final String name;
  final List<String> plankTypeIds;
}

class PlankSetResult {
  const PlankSetResult({
    required this.setId,
    required this.setName,
    required this.targetSeconds,
    required this.plankResults,
    required this.totalEarnedExp,
    required this.totalExpAfter,
    required this.levelAfter,
    required this.levelUp,
    required this.streakAfter,
    required this.streakIncreased,
    this.milestoneReached,
  });

  final String setId;
  final String setName;
  final int targetSeconds;
  final List<PlankResult> plankResults;
  final int totalEarnedExp;
  final int totalExpAfter;
  final int levelAfter;
  final bool levelUp;
  final int streakAfter;
  final bool streakIncreased;
  final MilestoneAchievement? milestoneReached;
}
