import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/habit.dart';
import 'habits_providers.dart';

final habitByIdProvider = Provider.family<Habit?, String>((ref, habitId) {
  final habitsAsync = ref.watch(habitsNotifierProvider);

  return habitsAsync.maybeWhen(
    data: (habits) {
      try {
        return habits.firstWhere((h) => h.id == habitId);
      } catch (_) {
        return null;
      }
    },
    orElse: () => null,
  );
});
