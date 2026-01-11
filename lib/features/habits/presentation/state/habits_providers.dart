import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_forge/features/habits/domain/entities/habit.dart';

import '../../data/datasources/habits_local_datasource.dart';
import '../../data/repositories/habits_repository_impl.dart';
import '../../domain/repositories/habits_repository.dart';
import 'habits_notifier.dart';

final habitsLocalDatasourceProvider = Provider<HabitsLocalDatasource>((ref) {
  return HabitsLocalDatasource();
});

final habitsRepositoryProvider = Provider<HabitsRepository>((ref) {
  final ds = ref.watch(habitsLocalDatasourceProvider);
  return HabitsRepositoryImpl(ds);
});

final habitsNotifierProvider =
    AsyncNotifierProvider<HabitsNotifier, List<Habit>>(HabitsNotifier.new);
