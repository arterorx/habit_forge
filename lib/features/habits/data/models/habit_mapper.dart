import '../../domain/entities/habit.dart';
import 'habit_hive_model.dart';

class HabitMapper {
  static Habit fromHive(HabitHiveModel m) {
    return Habit(
      id: m.id,
      title: m.title,
      activeWeekdays: m.activeWeekdays,
      completedDays: m.completedDays.toSet(),
      createdAt: m.createdAt,
      remindersEnabled: m.remindersEnabled ?? false,
      reminderHour: m.reminderHour ?? 20,
      reminderMinute: m.reminderMinute ?? 0,
    );
  }

  static HabitHiveModel toHive(Habit e) {
    return HabitHiveModel(
      id: e.id,
      title: e.title,
      activeWeekdays: e.activeWeekdays,
      completedDays: e.completedDays.toList(),
      createdAt: e.createdAt,
      remindersEnabled: e.remindersEnabled,
      reminderHour: e.reminderHour,
      reminderMinute: e.reminderMinute,
    );
  }
}
