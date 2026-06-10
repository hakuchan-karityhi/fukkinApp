class WorkoutRecord {
  const WorkoutRecord({
    required this.id,
    required this.date,
    required this.plankTypeId,
    required this.targetSeconds,
    required this.earnedExp,
    required this.completedAt,
    required this.sessionIndexOfDay,
  });

  final String id;
  final DateTime date;
  final String plankTypeId;
  final int targetSeconds;
  final int earnedExp;
  final DateTime completedAt;
  final int sessionIndexOfDay;
}
