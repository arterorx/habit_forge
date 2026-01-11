import '../../domain/entities/habit.dart';
import '../../domain/repositories/habits_repository.dart';
import '../datasources/habits_local_datasource.dart';
import '../models/habit_mapper.dart';

class HabitsRepositoryImpl implements HabitsRepository {
  final HabitsLocalDatasource datasource;

  HabitsRepositoryImpl(this.datasource);

  @override
  Future<List<Habit>> getAll() async {
    final models = await datasource.getAll();
    return models.map(HabitMapper.fromHive).toList();
  }

  @override
  Future<void> save(Habit habit) async {
    final model = HabitMapper.toHive(habit);
    await datasource.upsert(model);
  }

  @override
  Future<void> delete(String id) async {
    await datasource.delete(id);
  }
}
