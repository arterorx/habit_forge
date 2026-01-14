import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_forge/core/notifications/notifications_providers.dart';
import 'package:habit_forge/core/settings/app_settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (settings) {
          return ListView(
            children: [
              SwitchListTile(
                title: const Text('Уведомления для приложения'),
                subtitle: Text(
                  settings.notificationsEnabled
                      ? 'Включены'
                      : 'Выключены (новые не будут ставиться)',
                ),
                value: settings.notificationsEnabled,
                onChanged: (v) async {
                  await ref
                      .read(appSettingsNotifierProvider.notifier)
                      .setNotificationsEnabled(v);

                  // опционально: если выключили — сразу отменяем ВСЕ уведомления
                  if (!v) {
                    await ref.read(notificationServiceProvider).cancelAll();
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
