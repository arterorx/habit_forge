import '../../domain/entities/habit.dart';
import 'habit_hive_model.dart';

class HabitMapper {
  static Habit fromHive(HabitHiveModel m) {
    return Habit(
      id: m.id,
      title: m.title,
      activeWeekdays: List<int>.from(m.activeWeekdays),
      completedDays: m.completedDays.toSet(),
      createdAt: m.createdAt,
    );
  }

  static HabitHiveModel toHive(Habit e) {
    return HabitHiveModel(
      id: e.id,
      title: e.title,
      activeWeekdays: List<int>.from(e.activeWeekdays),
      completedDays: e.completedDays.toList(),
      createdAt: e.createdAt,
    );
  }
}
