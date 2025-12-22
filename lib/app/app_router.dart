// lib/app/app_router.dart

import 'package:build4front/features/auth/data/services/admin_token_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/config/app_config.dart';
import 'package:build4front/core/config/env.dart';

import 'package:build4front/features/auth/presentation/gate/auth_gate.dart';
import 'package:build4front/features/auth/presentation/login/screens/user_login_screen.dart';

import 'package:build4front/features/shell/presentation/screens/main_shell.dart';
import 'package:build4front/features/explore/presentation/screens/explore_screen.dart';

// Admin
import 'package:build4front/features/admin/product/presentation/widgets/admin_gate.dart';
import 'package:build4front/features/admin/dashboard/screen/admin_dashboard_screen.dart';
import 'package:build4front/features/admin/product/presentation/screens/admin_products_list_screen.dart';

// ✅ Orders Admin Feature
import 'package:build4front/features/admin/orders_admin/orders_admin_feature.dart';

// Checkout
import 'package:build4front/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:build4front/features/checkout/presentation/bloc/checkout_bloc.dart';

import 'package:build4front/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:build4front/features/checkout/domain/usecases/get_checkout_cart.dart';
import 'package:build4front/features/checkout/domain/usecases/get_payment_methods.dart';
import 'package:build4front/features/checkout/domain/usecases/get_shipping_quotes.dart';
import 'package:build4front/features/checkout/domain/usecases/preview_tax.dart';
import 'package:build4front/features/checkout/domain/usecases/place_order.dart';

// Orders (USER)
import 'package:build4front/features/orders/orders_feature.dart';

// ✅ Notifications (USER)
import 'package:build4front/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:build4front/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:build4front/features/notifications/presentation/bloc/notifications_event.dart';

import 'package:build4front/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:build4front/features/notifications/domain/usecases/get_user_notifications.dart';
import 'package:build4front/features/notifications/domain/usecases/get_unread_count.dart';
import 'package:build4front/features/notifications/domain/usecases/mark_notification_read.dart';
import 'package:build4front/features/notifications/domain/usecases/delete_notification.dart';

class AppRouter {
  static const String initialRoute = '/';

  static const String startup = '/';
  static const String login = '/login';
  static const String main = '/main';

  static const String admin = '/admin';
  static const String adminProducts = '/admin/products';
  static const String adminOrders = '/admin/orders';

  static const String explore = '/explore';
  static const String checkout = '/checkout';

  static const String myOrders = '/my-orders';

  static const String notifications = '/notifications';

  static Route<dynamic> onGenerateRoute(
    RouteSettings settings,
    AppConfig appConfig,
  ) {
    switch (settings.name) {
      // ✅ Startup → AuthGate decides where to go based on token(s)
      case startup:
        return MaterialPageRoute(
          builder: (_) => AuthGate(appConfig: appConfig),
          settings: settings,
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => UserLoginScreen(appConfig: appConfig),
          settings: settings,
        );

      case main:
        return MaterialPageRoute(
          builder: (_) => MainShell(appConfig: appConfig),
          settings: settings,
        );

      case explore:
        {
          final args = settings.arguments as Map<String, dynamic>?;

          final String? initialQuery = args?['query'] as String?;
          final String? initialCategoryLabel = args?['category'] as String?;
          final String? initialSectionId = args?['sectionId'] as String?;
          final int? initialCategoryId = args?['categoryId'] as int?;

          return MaterialPageRoute(
            builder: (_) => ExploreScreen(
              appConfig: appConfig,
              initialQuery: initialQuery,
              initialCategoryLabel: initialCategoryLabel,
              initialSectionId: initialSectionId,
              initialCategoryId: initialCategoryId,
            ),
            settings: settings,
          );
        }

      // ✅ Admin Dashboard
      case admin:
        return MaterialPageRoute(
          builder: (_) =>
              AdminGate(builder: (_) => const AdminDashboardScreen()),
          settings: settings,
        );

      // ✅ Admin Products
      case adminProducts:
        {
          final ownerId = int.tryParse(Env.ownerProjectLinkId) ?? 0;

          return MaterialPageRoute(
            builder: (_) => AdminGate(
              builder: (_) => AdminProductsListScreen(ownerProjectId: ownerId),
            ),
            settings: settings,
          );
        }

      // ✅ OWNER Orders Admin (NO SUPER ADMIN in your app)
      case adminOrders:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => AdminGate(
            builder: (ctx) {
              final store = ctx.read<AdminTokenStore>();

              return OrdersAdminFeature(getToken: () => store.getToken());
            },
          ),
        );

      // ✅ USER Orders
      case myOrders:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OrdersFeature(appConfig: appConfig),
        );

      // ✅ Checkout
      case checkout:
        {
          final args = settings.arguments as Map<String, dynamic>?;

          final ownerProjectId =
              (args?['ownerProjectId'] as int?) ??
              (int.tryParse(Env.ownerProjectLinkId) ?? 0);

          final currencyId =
              (args?['currencyId'] as int?) ??
              (int.tryParse(Env.currencyId) ?? 1);

          return MaterialPageRoute(
            settings: settings,
            builder: (context) {
              final repo = context.read<CheckoutRepository>();

              return BlocProvider(
                create: (_) => CheckoutBloc(
                  getCart: GetCheckoutCart(repo),
                  getPaymentMethods: GetPaymentMethods(repo),
                  getShippingQuotes: GetShippingQuotes(repo),
                  previewTax: PreviewTax(repo),
                  placeOrder: PlaceOrder(repo),
                  ownerProjectId: ownerProjectId,
                  currencyId: currencyId,
                ),
                child: CheckoutScreen(
                  appConfig: appConfig,
                  ownerProjectId: ownerProjectId,
                ),
              );
            },
          );
        }

      // ✅ Notifications
      case notifications:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            final repo = context.read<NotificationsRepository>();

            return BlocProvider(
              create: (_) => NotificationsBloc(
                getNotifications: GetUserNotifications(repo),
                getUnreadCount: GetUnreadCount(repo),
                markRead: MarkNotificationRead(repo),
                deleteNotif: DeleteNotification(repo),
              )..add(const NotificationsStarted()),
              child: const NotificationsScreen(),
            );
          },
        );

      default:
        return MaterialPageRoute(
          builder: (_) => UserLoginScreen(appConfig: appConfig),
          settings: settings,
        );
    }
  }
}
