import "package:flutter_riverpod/flutter_riverpod.dart";

import "../domain/models/game_constants.dart";
import "../domain/repositories/game_constants_repository.dart";
import "../domain/services/exp_calculator.dart";
import "../domain/services/level_service.dart";
import "../domain/services/penalty_service.dart";
import "../domain/services/streak_service.dart";
import "../infrastructure/remote_config/remote_config_game_constants_repository.dart";

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
