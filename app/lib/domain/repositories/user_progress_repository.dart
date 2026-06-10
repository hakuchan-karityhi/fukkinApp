import "../models/user_progress.dart";

abstract class UserProgressRepository {
  Future<UserProgress> get();
  Future<void> save(UserProgress progress);
}
