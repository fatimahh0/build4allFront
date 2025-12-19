// lib/features/notifications/domain/usecases/get_user_notifications.dart

import '../entities/app_notification.dart';
import '../repositories/notifications_repository.dart';

class GetUserNotifications {
  final NotificationsRepository repo;
  GetUserNotifications(this.repo);

  Future<List<AppNotification>> call() => repo.getMyNotifications();
}
