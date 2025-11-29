// lib/app/app_router.dart

import 'package:flutter/material.dart';

import 'package:build4front/core/config/app_config.dart';
import 'package:build4front/features/auth/presentation/login/screens/user_login_screen.dart';
import 'package:build4front/features/shell/presentation/screens/main_shell.dart';

class AppRouter {
  // You can change this later to a splash or onboarding route
  static const String initialRoute = '/login';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        {
          // Read config here for the login screen
          final appConfig = AppConfig.fromEnv();
          return MaterialPageRoute(
            builder: (_) => UserLoginScreen(appConfig: appConfig),
            settings: settings,
          );
        }

      case '/main':
        {
          // MainShell (your bottom navigation shell)
          final appConfig = AppConfig.fromEnv();
          return MaterialPageRoute(
            builder: (_) => MainShell(appConfig: appConfig),
            settings: settings,
          );
        }

      default:
        {
          // Fallback: go to login
          final appConfig = AppConfig.fromEnv();
          return MaterialPageRoute(
            builder: (_) => UserLoginScreen(appConfig: appConfig),
            settings: settings,
          );
        }
    }
  }
}
