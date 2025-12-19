// lib/features/notifications/domain/usecases/get_unread_count.dart

import '../repositories/notifications_repository.dart';

class GetUnreadCount {
  final NotificationsRepository repo;
  GetUnreadCount(this.repo);

  Future<int> call() => repo.getUnreadCount();
}
