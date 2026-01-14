import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_forge/core/settings/app_settings_hive_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'core/notifications/notifications_providers.dart';
import 'features/habits/data/models/habit_hive_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(HabitHiveModelAdapter());
  Hive.registerAdapter(AppSettingsHiveModelAdapter());

  final container = ProviderContainer();

  // ✅ инициализируем NotificationService один раз
  final notifications = container.read(notificationServiceProvider);
  await notifications.init(
    onTap: (payload) {
      debugPrint('🔔 Notification tapped. payload=$payload');
      if (payload == null || payload.isEmpty) return;
      container.read(notificationTapPayloadProvider.notifier).state = payload;
    },
  );

  runApp(UncontrolledProviderScope(container: container, child: const App()));
}
