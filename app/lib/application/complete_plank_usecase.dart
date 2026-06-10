import "../domain/models/plank_result.dart";
import "../domain/models/streak_state.dart";
import "../domain/models/workout_record.dart";
import "../domain/repositories/milestone_repository.dart";
import "../domain/repositories/plank_type_repository.dart";
import "../domain/repositories/streak_repository.dart";
import "../domain/repositories/user_progress_repository.dart";
import "../domain/repositories/workout_repository.dart";
import "../domain/services/exp_calculator.dart";
import "../domain/services/level_service.dart";
import "../domain/services/milestone_service.dart";
import "../domain/services/streak_service.dart";

class CompletePlankUseCase {
  CompletePlankUseCase({
    required PlankTypeRepository plankTypeRepository,
    required UserProgressRepository userProgressRepository,
    required StreakRepository streakRepository,
    required WorkoutRepository workoutRepository,
    required MilestoneRepository milestoneRepository,
    required ExpCalculator expCalculator,
    required StreakService streakService,
    required LevelService levelService,
    required MilestoneService milestoneService,
  })  : _plankTypeRepository = plankTypeRepository,
        _userProgressRepository = userProgressRepository,
        _streakRepository = streakRepository,
        _workoutRepository = workoutRepository,
        _milestoneRepository = milestoneRepository,
        _expCalculator = expCalculator,
        _streakService = streakService,
        _levelService = levelService,
        _milestoneService = milestoneService;

  final PlankTypeRepository _plankTypeRepository;
  final UserProgressRepository _userProgressRepository;
  final StreakRepository _streakRepository;
  final WorkoutRepository _workoutRepository;
  final MilestoneRepository _milestoneRepository;
  final ExpCalculator _expCalculator;
  final StreakService _streakService;
  final LevelService _levelService;
  final MilestoneService _milestoneService;

  Future<PlankResult> execute({
    required String plankTypeId,
    required int targetSeconds,
    DateTime? now,
  }) async {
    final plankType = await _plankTypeRepository.getById(plankTypeId);
    if (plankType == null) {
      throw StateError("Unknown plank type: $plankTypeId");
    }

    final completedAt = now ?? DateTime.now();
    final today = DateTime(
      completedAt.year,
      completedAt.month,
      completedAt.day,
    );

    final progress = await _userProgressRepository.get();
    var streak = await _streakRepository.get();
    streak = _normalizeStreakForToday(streak, today);

    final todayRecords = await _workoutRepository.getByDate(today);
    final isSecondSessionToday = todayRecords.isNotEmpty;

    final streakMultiplier = _streakService.getMultiplier(streak.currentStreak);
    final baseExp = targetSeconds;
    final earnedExp = _expCalculator.calculate(
      baseExp: baseExp,
      difficultyMultiplier: plankType.expMultiplier,
      streakMultiplier: streakMultiplier,
      isSecondSessionToday: isSecondSessionToday,
    );

    final previousLevel = progress.level;
    final newTotalExp = progress.totalExp + earnedExp;
    final newLevel = _levelService.getLevel(newTotalExp);
    final newAbsStage = _levelService.getAbsStage(newTotalExp);

    var streakIncreased = false;
    if (!streak.todayCompleted) {
      final newStreak = streak.currentStreak + 1;
      streak = streak.copyWith(
        currentStreak: newStreak,
        longestStreak: newStreak > streak.longestStreak
            ? newStreak
            : streak.longestStreak,
        lastWorkoutDate: today,
        todayCompleted: true,
      );
      streakIncreased = true;
    } else {
      streak = streak.copyWith(lastWorkoutDate: today);
    }

    final record = WorkoutRecord(
      id: "${completedAt.millisecondsSinceEpoch}",
      date: today,
      plankTypeId: plankTypeId,
      targetSeconds: targetSeconds,
      earnedExp: earnedExp,
      completedAt: completedAt,
      sessionIndexOfDay: todayRecords.length + 1,
    );

    await _workoutRepository.add(record);
    await _streakRepository.save(streak);
    await _userProgressRepository.save(
      progress.copyWith(
        totalExp: newTotalExp,
        level: newLevel,
        absStage: newAbsStage,
      ),
    );

    final targets = await _milestoneRepository.getTargets();
    final achieved = await _milestoneRepository.getAchieved();
    final milestoneReached = _milestoneService.detectAchievement(
      streakAfter: streak.currentStreak,
      streakIncreased: streakIncreased,
      targets: targets,
      achieved: achieved,
      achievedAt: completedAt,
    );
    if (milestoneReached != null) {
      await _milestoneRepository.addAchievement(milestoneReached);
    }

    return PlankResult(
      earnedExp: earnedExp,
      baseExp: baseExp,
      plankTypeId: plankTypeId,
      plankTypeName: plankType.name,
      targetSeconds: targetSeconds,
      streakAfter: streak.currentStreak,
      streakIncreased: streakIncreased,
      totalExpAfter: newTotalExp,
      levelAfter: newLevel,
      levelUp: newLevel > previousLevel,
      absStageAfter: newAbsStage,
      milestoneReached: milestoneReached,
    );
  }

  StreakState _normalizeStreakForToday(StreakState streak, DateTime today) {
    if (streak.lastWorkoutDate == null) {
      return streak.copyWith(todayCompleted: false);
    }

    final last = DateTime(
      streak.lastWorkoutDate!.year,
      streak.lastWorkoutDate!.month,
      streak.lastWorkoutDate!.day,
    );

    if (last == today) {
      return streak;
    }

    if (last == today.subtract(const Duration(days: 1))) {
      return streak.copyWith(todayCompleted: false);
    }

    return streak.copyWith(
      currentStreak: 0,
      todayCompleted: false,
    );
  }
}
