import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final todayKey = _toDayKey(DateTime.now());
    final doneToday = habit.completedDays.contains(todayKey);

    return ListTile(
      title: Text(habit.title),
      subtitle: Text('Активные дни: ${habit.activeWeekdays.join(", ")}'),
      leading: Icon(doneToday ? Icons.check_circle : Icons.circle_outlined),
      onTap: () => ref.read(habitsNotifierProvider.notifier).toggleToday(habit),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed:
            () =>
                ref.read(habitsNotifierProvider.notifier).deleteHabit(habit.id),
      ),
    );
  }

  String _toDayKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
