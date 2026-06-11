import "../models/milestone.dart";

abstract class MilestoneRepository {
  Future<List<MilestoneTarget>> getTargets();

  Future<void> addTarget(MilestoneTarget target);

  Future<void> removeTarget(int days);

  Future<List<MilestoneAchievement>> getAchieved();

  Future<void> addAchievement(MilestoneAchievement achievement);
}
