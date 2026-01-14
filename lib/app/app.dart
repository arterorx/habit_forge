import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/notifications/notifications_providers.dart';
import '../features/habits/presentation/screens/habits_list_screen.dart';
import '../features/habits/presentation/screens/habit_details_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ слушаем: если появился payload -> навигация на details
    ref.listen<String?>(notificationTapPayloadProvider, (prev, next) {
      if (next == null || next.isEmpty) return;

      rootNavigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => HabitDetailsScreen(habitId: next)),
      );

      // ✅ сбрасываем, чтобы не открыть повторно при rebuild
      ref.read(notificationTapPayloadProvider.notifier).state = null;
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: rootNavigatorKey,
      home: const HabitsListScreen(),
    );
  }
}
