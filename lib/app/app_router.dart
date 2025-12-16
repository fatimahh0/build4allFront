// lib/app/app_router.dart

import 'package:build4front/features/auth/presentation/gate/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/config/app_config.dart';
import 'package:build4front/core/config/env.dart';


import 'package:build4front/features/auth/presentation/login/screens/user_login_screen.dart';

import 'package:build4front/features/shell/presentation/screens/main_shell.dart';
import 'package:build4front/features/explore/presentation/screens/explore_screen.dart';

// Admin
import 'package:build4front/features/admin/product/presentation/widgets/admin_gate.dart';
import 'package:build4front/features/admin/product/presentation/screens/admin_dashboard_screen.dart';
import 'package:build4front/features/admin/product/presentation/screens/admin_products_list_screen.dart';

// Checkout
import 'package:build4front/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:build4front/features/checkout/presentation/bloc/checkout_bloc.dart';

import 'package:build4front/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:build4front/features/checkout/domain/usecases/get_checkout_cart.dart';
import 'package:build4front/features/checkout/domain/usecases/get_payment_methods.dart';
import 'package:build4front/features/checkout/domain/usecases/get_shipping_quotes.dart';
import 'package:build4front/features/checkout/domain/usecases/preview_tax.dart';
import 'package:build4front/features/checkout/domain/usecases/place_order.dart';

class AppRouter {
  // ✅ IMPORTANT: start from AuthGate so tokens can auto-route
  static const String initialRoute = '/';

  static const String startup = '/';
  static const String login = '/login';
  static const String main = '/main';

  static const String admin = '/admin';
  static const String adminProducts = '/admin/products';

  static const String explore = '/explore';
  static const String checkout = '/checkout';

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

      case admin:
        return MaterialPageRoute(
          builder: (_) =>
              AdminGate(builder: (_) => const AdminDashboardScreen()),
          settings: settings,
        );

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
              // ✅ use the repo from MultiRepositoryProvider (DON’T create new one here)
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

      default:
        // if route unknown → go login
        return MaterialPageRoute(
          builder: (_) => UserLoginScreen(appConfig: appConfig),
          settings: settings,
        );
    }
  }
}
