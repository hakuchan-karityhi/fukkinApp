import "../models/workout_record.dart";

abstract class WorkoutRepository {
  Future<void> add(WorkoutRecord record);
  Future<List<WorkoutRecord>> getByDate(DateTime date);
  Future<List<WorkoutRecord>> getInMonth(int year, int month);
}
