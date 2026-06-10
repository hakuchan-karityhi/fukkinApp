import "../models/streak_state.dart";

abstract class StreakRepository {
  Future<StreakState> get();
  Future<void> save(StreakState state);
}
