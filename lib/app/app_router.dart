import 'package:flutter/material.dart';

import 'package:build4front/core/config/app_config.dart';
import 'package:build4front/core/config/env.dart';

import 'package:build4front/features/auth/presentation/login/screens/user_login_screen.dart';
import 'package:build4front/features/shell/presentation/screens/main_shell.dart';

// Admin gate + dashboard + products
import 'package:build4front/features/admin/product/presentation/widgets/admin_gate.dart';
import 'package:build4front/features/admin/product/presentation/screens/admin_dashboard_screen.dart';
import 'package:build4front/features/admin/product/presentation/screens/admin_products_list_screen.dart';

class AppRouter {
  static const String initialRoute = '/login';

  static const String login = '/login';
  static const String main = '/main';

  static const String admin = '/admin'; // unified admin home
  static const String adminProducts = '/admin/products'; // products list

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        {
          final appConfig = AppConfig.fromEnv();
          return MaterialPageRoute(
            builder: (_) => UserLoginScreen(appConfig: appConfig),
            settings: settings,
          );
        }

      case main:
        {
          final appConfig = AppConfig.fromEnv();
          return MaterialPageRoute(
            builder: (_) => MainShell(appConfig: appConfig),
            settings: settings,
          );
        }

      case admin:
        {
          return MaterialPageRoute(
            builder: (_) =>
                AdminGate(builder: (_) => const AdminDashboardScreen()),
            settings: settings,
          );
        }

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

      default:
        {
          final appConfig = AppConfig.fromEnv();
          return MaterialPageRoute(
            builder: (_) => UserLoginScreen(appConfig: appConfig),
            settings: settings,
          );
        }
    }
  }
}
