import "../models/workout_record.dart";

abstract class WorkoutRepository {
  Future<void> add(WorkoutRecord record);
  Future<List<WorkoutRecord>> getByDate(DateTime date);
  Future<Set<DateTime>> getWorkoutDatesInMonth(int year, int month);
}
