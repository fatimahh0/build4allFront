// lib/features/notifications/presentation/screens/notifications_page.dart

import 'package:build4front/features/notifications/data/services/notifications_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/notifications_repository_impl.dart';
import '../../domain/usecases/delete_notification.dart';
import '../../domain/usecases/get_unread_count.dart';
import '../../domain/usecases/get_user_notifications.dart';
import '../../domain/usecases/mark_notification_read.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import 'notifications_screen.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final api = NotificationsApiService();
    final repo = NotificationsRepositoryImpl(api);

    return BlocProvider(
      create: (_) => NotificationsBloc(
        getNotifications: GetUserNotifications(repo),
        getUnreadCount: GetUnreadCount(repo),
        markRead: MarkNotificationRead(repo),
        deleteNotif: DeleteNotification(repo),
      )..add(const NotificationsStarted()),
      child: const NotificationsScreen(),
    );
  }
}
