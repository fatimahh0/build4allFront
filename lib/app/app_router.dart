import 'package:build4front/features/admin/presentation/wdigets/admin_gate.dart';
import 'package:flutter/material.dart';

import 'package:build4front/core/config/app_config.dart';
import 'package:build4front/features/auth/presentation/login/screens/user_login_screen.dart';
import 'package:build4front/features/shell/presentation/screens/main_shell.dart';


import 'package:build4front/features/admin/presentation/screens/admin_dashboard_screen.dart';

class AppRouter {
  static const String initialRoute = '/login';

  static const String login = '/login';
  static const String main = '/main';
  static const String admin = '/admin'; // unified route

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
            builder: (_) => AdminGate(
              // default allow all admin roles
              builder: (_) => const AdminDashboardScreen(),
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
