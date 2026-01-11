import '../entities/habit.dart';

abstract class HabitsRepository {
  Future<List<Habit>> getAll();
  Future<void> save(Habit habit);
  Future<void> delete(String id);
}
