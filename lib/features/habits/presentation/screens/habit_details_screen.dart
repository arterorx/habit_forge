import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_forge/core/notifications/notifications_providers.dart';

import '../state/habit_details_provider.dart';
import '../state/habits_providers.dart';

class HabitDetailsScreen extends ConsumerWidget {
  const HabitDetailsScreen({super.key, required this.habitId});

  final String habitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habit = ref.watch(habitByIdProvider(habitId));

    if (habit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Habit details')),
        body: const Center(child: Text('Привычка не найдена')),
      );
    }

    final timeText = _formatTime(habit.reminderHour, habit.reminderMinute);

    return Scaffold(
      appBar: AppBar(title: Text(habit.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Reminders on/off ---
          SwitchListTile(
            title: const Text('Напоминания'),
            subtitle: Text(
              habit.remindersEnabled ? 'Включены ($timeText)' : 'Выключены',
            ),
            value: habit.remindersEnabled,
            onChanged: (v) async {
              final updated = habit.copyWith(remindersEnabled: v);
              await ref
                  .read(habitsNotifierProvider.notifier)
                  .updateReminders(updated);
            },
          ),

          const SizedBox(height: 12),

          // --- Time picker ---
          ListTile(
            title: const Text('Время напоминания'),
            subtitle: Text(timeText),
            enabled: habit.remindersEnabled,
            trailing: const Icon(Icons.chevron_right),
            onTap:
                habit.remindersEnabled
                    ? () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: habit.reminderHour,
                          minute: habit.reminderMinute,
                        ),
                      );
                      if (picked == null) return;

                      final updated = habit.copyWith(
                        reminderHour: picked.hour,
                        reminderMinute: picked.minute,
                      );

                      await ref
                          .read(habitsNotifierProvider.notifier)
                          .updateReminders(updated);
                    }
                    : null,
          ),

          const Divider(height: 32),

          ListTile(
            title: const Text('🧪 Debug: отменить уведомления этой привычки'),
            subtitle: const Text('Удалит 7 повторяющихся уведомлений (Пн..Вс)'),
            trailing: const Icon(Icons.notifications_off),
            onTap: () async {
              await ref.read(notificationServiceProvider).cancelHabit(habit.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Уведомления привычки отменены'),
                  ),
                );
              }
            },
          ),

          ListTile(
            title: const Text('🧨 Debug: отменить ВСЕ уведомления'),
            subtitle: const Text(
              'Полностью очищает все локальные уведомления приложения',
            ),
            trailing: const Icon(Icons.delete_forever),
            onTap: () async {
              await ref.read(notificationServiceProvider).cancelAll();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Все уведомления отменены')),
                );
              }
            },
          ),

          const Divider(height: 32),

          // --- Weekdays selection ---
          const Text(
            'Дни напоминания',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            children: List.generate(7, (i) {
              final selected = habit.activeWeekdays.contains(i);

              return FilterChip(
                label: Text(_weekdayLabel(i)),
                selected: selected,
                onSelected: (v) async {
                  final set = {...habit.activeWeekdays};
                  if (v) {
                    set.add(i);
                  } else {
                    set.remove(i);
                  }

                  final updatedDays = set.toList()..sort();
                  final updated = habit.copyWith(activeWeekdays: updatedDays);

                  // важный момент:
                  // 1) сохраняем habit
                  // 2) обновляем уведомления (cancel + schedule)
                  await ref
                      .read(habitsNotifierProvider.notifier)
                      .updateReminders(updated);
                },
              );
            }),
          ),

          const SizedBox(height: 24),

          Text(
            'Подсказка: тап по дням меняет расписание уведомлений. ',
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  static String _weekdayLabel(int i) {
    const labels = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return labels[i];
  }

  static String _formatTime(int h, int m) {
    final hh = h.toString().padLeft(2, '0');
    final mm = m.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
