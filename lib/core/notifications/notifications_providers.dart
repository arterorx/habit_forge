import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Сюда кладём payload (habitId), когда пользователь тапнул уведомление.
/// App будет слушать и делать навигацию.
final notificationTapPayloadProvider = StateProvider<String?>((ref) => null);
