import "package:flutter_riverpod/flutter_riverpod.dart";

import "../domain/models/game_constants.dart";
import "../domain/models/plank_type.dart";
import "../domain/models/streak_state.dart";
import "../domain/models/user_progress.dart";
import "../domain/repositories/game_constants_repository.dart";
import "../domain/repositories/plank_type_repository.dart";
import "../domain/repositories/streak_repository.dart";
import "../domain/repositories/user_progress_repository.dart";
import "../domain/repositories/workout_repository.dart";
import "../domain/services/exp_calculator.dart";
import "../domain/services/level_service.dart";
import "../domain/services/penalty_service.dart";
import "../domain/services/streak_service.dart";
import "../application/complete_plank_usecase.dart";
import "../infrastructure/local/app_database.dart";
import "../infrastructure/local/streak_repository.dart";
import "../infrastructure/local/user_progress_repository.dart";
import "../infrastructure/local/workout_repository.dart";
import "../infrastructure/master/plank_type_repository.dart";
import "../infrastructure/remote_config/remote_config_game_constants_repository.dart";

const betaMode = true;

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final gameConstantsRepositoryProvider = Provider<GameConstantsRepository>(
  (ref) => RemoteConfigGameConstantsRepository(
    fetchOverrides: () async => const {},
  ),
);

final gameConstantsProvider = FutureProvider<GameConstants>((ref) async {
  final repo = ref.watch(gameConstantsRepositoryProvider);
  return repo.load();
});

final expCalculatorProvider = Provider<ExpCalculator?>((ref) {
  final constants = ref.watch(gameConstantsProvider).valueOrNull;
  return constants == null ? null : ExpCalculator(constants);
});

final streakServiceProvider = Provider<StreakService?>((ref) {
  final constants = ref.watch(gameConstantsProvider).valueOrNull;
  return constants == null ? null : StreakService(constants);
});

final levelServiceProvider = Provider<LevelService?>((ref) {
  final constants = ref.watch(gameConstantsProvider).valueOrNull;
  return constants == null ? null : LevelService(constants);
});

final penaltyServiceProvider = Provider<PenaltyService?>((ref) {
  final constants = ref.watch(gameConstantsProvider).valueOrNull;
  final level = ref.watch(levelServiceProvider);
  if (constants == null || level == null) return null;
  return PenaltyService(constants, level);
});

final plankTypeRepositoryProvider = Provider<PlankTypeRepository>(
  (ref) => AssetPlankTypeRepository(),
);

final userProgressRepositoryProvider = Provider<UserProgressRepository>((ref) {
  return DriftUserProgressRepository(ref.watch(appDatabaseProvider));
});

final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  return DriftStreakRepository(ref.watch(appDatabaseProvider));
});

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return DriftWorkoutRepository(ref.watch(appDatabaseProvider));
});

final plankTypesProvider = FutureProvider<List<PlankType>>((ref) async {
  final repo = ref.watch(plankTypeRepositoryProvider);
  return repo.getAll(betaMode: betaMode);
});

final userProgressProvider = FutureProvider<UserProgress>((ref) async {
  return ref.watch(userProgressRepositoryProvider).get();
});

final streakStateProvider = FutureProvider<StreakState>((ref) async {
  return ref.watch(streakRepositoryProvider).get();
});

final completePlankUseCaseProvider = Provider<CompletePlankUseCase?>((ref) {
  final expCalculator = ref.watch(expCalculatorProvider);
  final streakService = ref.watch(streakServiceProvider);
  final levelService = ref.watch(levelServiceProvider);
  if (expCalculator == null || streakService == null || levelService == null) {
    return null;
  }

  return CompletePlankUseCase(
    plankTypeRepository: ref.watch(plankTypeRepositoryProvider),
    userProgressRepository: ref.watch(userProgressRepositoryProvider),
    streakRepository: ref.watch(streakRepositoryProvider),
    workoutRepository: ref.watch(workoutRepositoryProvider),
    expCalculator: expCalculator,
    streakService: streakService,
    levelService: levelService,
  );
});

final selectedPlankIndexProvider = StateProvider<int>((ref) => 0);

final targetSecondsProvider = StateProvider<int?>((ref) => null);
