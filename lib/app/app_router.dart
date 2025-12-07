// lib/app/app_router.dart

import 'package:flutter/material.dart';

import 'package:build4front/core/config/app_config.dart';
import 'package:build4front/core/config/env.dart';

// Login + main shell
import 'package:build4front/features/auth/presentation/login/screens/user_login_screen.dart';
import 'package:build4front/features/shell/presentation/screens/main_shell.dart';

// Admin gate + dashboard + products
import 'package:build4front/features/admin/product/presentation/widgets/admin_gate.dart';
import 'package:build4front/features/admin/product/presentation/screens/admin_dashboard_screen.dart';
import 'package:build4front/features/admin/product/presentation/screens/admin_products_list_screen.dart';

// ✅ Explore screen (user-facing items search/list)
import 'package:build4front/features/explore/presentation/screens/explore_screen.dart';

class AppRouter {
  static const String initialRoute = '/login';

  static const String login = '/login';
  static const String main = '/main';

  static const String admin = '/admin'; // unified admin home
  static const String adminProducts = '/admin/products'; // products list

  // ✅ new constant for explore
  static const String explore = '/explore';

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

      // ✅ NEW: explore route used by HomeScreen (search, category chips, see all…)
      case explore:
        {
          final appConfig = AppConfig.fromEnv();
          final args = settings.arguments as Map<String, dynamic>?;

          // These match how you call Navigator in HomeScreen
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
