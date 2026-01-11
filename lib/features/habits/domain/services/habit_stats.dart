import 'package:habit_forge/core/utils/date_key.dart';

import '../entities/habit.dart';

/// Возвращает список ключей дней за последние [days] (включая сегодня),
/// например: [2026-01-12, 2026-01-11, ...]
List<String> lastNDaysKeys(int days) {
  final now = DateTime.now();
  return List.generate(days, (i) {
    final dt = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: i));
    return dateKey(dt);
  });
}

/// Сколько из последних 7 дней привычка была выполнена
int completionsLast7Days(Habit habit) {
  final keys = lastNDaysKeys(7);
  return keys.where(habit.completedDays.contains).length;
}

/// Streak = сколько подряд "нужных" дней (активных по расписанию) привычка выполнялась
/// Считаем назад от сегодняшнего дня.
int currentStreak(Habit habit) {
  int streak = 0;
  final now = DateTime.now();

  // идём назад по дням
  for (int i = 0; i < 365; i++) {
    final dt = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: i));

    // 0..6 (пн..вс). В Dart weekday: пн=1..вс=7 -> приводим к 0..6
    final weekdayIndex = dt.weekday - 1;

    final isActiveDay = habit.activeWeekdays.contains(weekdayIndex);
    if (!isActiveDay) {
      // если день не активный — пропускаем (он не ломает streak)
      continue;
    }

    final key = dateKey(dt);
    final done = habit.completedDays.contains(key);

    if (done) {
      streak++;
    } else {
      break; // первый активный день без выполнения — streak заканчивается
    }
  }

  return streak;
}

/// Данные для графика: последние 7 дней -> 1 если done, 0 если нет
List<int> last7DaysBinary(Habit habit) {
  final keys =
      lastNDaysKeys(7).reversed.toList(); // слева старые, справа сегодня
  return keys.map((k) => habit.completedDays.contains(k) ? 1 : 0).toList();
}
