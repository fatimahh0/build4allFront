// lib/app/app_router.dart

import 'package:build4front/features/checkout/data/repositories/checkout_repository_impl.dart';
import 'package:build4front/features/checkout/data/services/checkout_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/config/app_config.dart';
import 'package:build4front/core/config/env.dart';

import 'package:build4front/features/auth/presentation/login/screens/user_login_screen.dart';
import 'package:build4front/features/shell/presentation/screens/main_shell.dart';
import 'package:build4front/features/explore/presentation/screens/explore_screen.dart';

import 'package:build4front/features/admin/product/presentation/widgets/admin_gate.dart';
import 'package:build4front/features/admin/product/presentation/screens/admin_dashboard_screen.dart';
import 'package:build4front/features/admin/product/presentation/screens/admin_products_list_screen.dart';

import 'package:build4front/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:build4front/features/checkout/presentation/bloc/checkout_bloc.dart';

import 'package:build4front/features/checkout/models/usecases/get_checkout_cart.dart';
import 'package:build4front/features/checkout/models/usecases/get_payment_methods.dart';
import 'package:build4front/features/checkout/models/usecases/get_shipping_quotes.dart';
import 'package:build4front/features/checkout/models/usecases/preview_tax.dart';
import 'package:build4front/features/checkout/models/usecases/place_order.dart';


class AppRouter {
  static const String initialRoute = '/login';

  static const String login = '/login';
  static const String main = '/main';

  static const String admin = '/admin';
  static const String adminProducts = '/admin/products';

  static const String explore = '/explore';
  static const String checkout = '/checkout';

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

      case explore:
        {
          final appConfig = AppConfig.fromEnv();
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

      case checkout:
        {
          final appConfig = AppConfig.fromEnv();
          final args = settings.arguments as Map<String, dynamic>?;

          final ownerProjectId =
              (args?['ownerProjectId'] as int?) ??
              (int.tryParse(Env.ownerProjectLinkId) ?? 0);

          final currencyId =
              (args?['currencyId'] as int?) ??
              (int.tryParse(Env.currencyId) ?? 1);

          final repo = CheckoutRepositoryImpl(CheckoutApiService());

          return MaterialPageRoute(
            builder: (_) => BlocProvider(
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
