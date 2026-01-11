import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_forge/core/utils/date_key.dart';
import 'package:habit_forge/features/habits/domain/services/habit_stats.dart';
import 'package:habit_forge/features/habits/presentation/widgets/weekly_progress_bar.dart';

import '../../domain/entities/habit.dart';
import '../state/habits_providers.dart';
import '../screens/create_habit_screen.dart';

class HabitsListScreen extends ConsumerWidget {
  const HabitsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('HabitForge')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateHabitScreen()),
          );

          if (result is CreateHabitResult) {
            await ref
                .read(habitsNotifierProvider.notifier)
                .addHabit(
                  title: result.title,
                  activeWeekdays: result.activeWeekdays,
                );
          }
        },
        child: const Icon(Icons.add),
      ),
      body: habitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (habits) {
          if (habits.isEmpty) {
            return const Center(child: Text('Пока нет привычек'));
          }

          return ListView.separated(
            itemCount: habits.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final habit = habits[index];
              return _HabitTile(habit: habit);
            },
          );
        },
      ),
    );
  }
}

class _HabitTile extends ConsumerWidget {
  const _HabitTile({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayKey = dateKey(DateTime.now());
    final doneToday = habit.completedDays.contains(todayKey);
    final streak = currentStreak(habit);
    final weeklyDone = completionsLast7Days(habit);

    return ListTile(
      title: Text(habit.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Streak: $streak  •  7д: $weeklyDone/7'),
          const SizedBox(height: 6),
          WeeklyProgressBar(values: last7DaysBinary(habit)),
        ],
      ),
      leading: Checkbox(
        value: doneToday,
        onChanged: (_) {
          ref.read(habitsNotifierProvider.notifier).toggleToday(habit);
        },
      ),
      onTap: () => ref.read(habitsNotifierProvider.notifier).toggleToday(habit),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed:
            () =>
                ref.read(habitsNotifierProvider.notifier).deleteHabit(habit.id),
      ),
    );
  }
}
