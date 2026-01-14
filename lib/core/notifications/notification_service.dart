import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init({required void Function(String? payload) onTap}) async {
    tz.initializeTimeZones();
    final String tzName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzName));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit, // ✅ важно для macOS
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        // ✅ тут мы получаем payload
        onTap(response.payload);
      },
    );

    // Android channel (как у тебя уже есть)
    const androidChannel = AndroidNotificationChannel(
      'habits_channel',
      'Habits',
      description: 'Reminders for habits',
      importance: Importance.max,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  Future<bool> requestPermissions() async {
    final ios = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    final mac = await _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    final android =
        await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();

    return (ios ?? true) && (mac ?? true) && (android ?? true);
  }

  Future<void> scheduleWeeklyHabit({
    required String habitId,
    required String title,
    required List<int> activeWeekdays, // 0..6 (пн..вс)
    required int hour,
    required int minute,
  }) async {
    await cancelHabit(habitId);

    for (final weekday0 in activeWeekdays) {
      final id = _notificationId(habitId, weekday0);

      final scheduled = _nextInstanceOfWeekdayTime(
        weekday0: weekday0,
        hour: hour,
        minute: minute,
      );

      await _plugin.zonedSchedule(
        id,
        'HabitForge',
        'Пора: $title',
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'habits_channel',
            'Habits',
            channelDescription: 'Reminders for habits',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
        payload: habitId, // ✅ вот это главное
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> cancelHabit(String habitId) async {
    for (int weekday0 = 0; weekday0 < 7; weekday0++) {
      await _plugin.cancel(_notificationId(habitId, weekday0));
    }
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  int _notificationId(String habitId, int weekday0) {
    final base = habitId.hashCode & 0x7fffffff;
    return base + weekday0 + 1;
  }

  tz.TZDateTime _nextInstanceOfWeekdayTime({
    required int weekday0,
    required int hour,
    required int minute,
  }) {
    final now = tz.TZDateTime.now(tz.local);
    final targetWeekday = weekday0 + 1; // tz weekday: 1..7

    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (scheduled.weekday != targetWeekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
      scheduled = tz.TZDateTime(
        tz.local,
        scheduled.year,
        scheduled.month,
        scheduled.day,
        hour,
        minute,
      );
    }

    return scheduled;
  }
}
