import "../domain/models/streak_state.dart";
import "../domain/models/user_progress.dart";
import "../domain/repositories/milestone_repository.dart";
import "../domain/repositories/streak_repository.dart";
import "../domain/repositories/user_progress_repository.dart";
import "../domain/repositories/workout_repository.dart";

class ResetProgressUseCase {
  const ResetProgressUseCase({
    required UserProgressRepository userProgressRepository,
    required StreakRepository streakRepository,
    required WorkoutRepository workoutRepository,
    required MilestoneRepository milestoneRepository,
  })  : _userProgressRepository = userProgressRepository,
        _streakRepository = streakRepository,
        _workoutRepository = workoutRepository,
        _milestoneRepository = milestoneRepository;

  final UserProgressRepository _userProgressRepository;
  final StreakRepository _streakRepository;
  final WorkoutRepository _workoutRepository;
  final MilestoneRepository _milestoneRepository;

  Future<void> execute() async {
    await _workoutRepository.deleteAll();
    await _milestoneRepository.deleteAllAchievements();
    await _milestoneRepository.resetTargetsToBuiltin();
    await _userProgressRepository.save(UserProgress.initial());
    await _streakRepository.save(StreakState.initial());
  }
}
