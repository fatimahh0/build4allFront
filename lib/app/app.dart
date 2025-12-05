// lib/app/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/network/connecting(wifiORserver)/connection_cubit.dart';
import 'package:build4front/core/network/globals.dart' as g;

import '../core/config/app_config.dart';
import '../core/theme/theme_cubit.dart';

// ---------- AUTH ----------
import 'package:build4front/features/auth/data/services/auth_token_store.dart';
import 'package:build4front/features/auth/data/services/auth_api_service.dart';
import 'package:build4front/features/auth/data/repository/auth_repository_impl.dart';
import 'package:build4front/features/auth/domain/usecases/login_with_email.dart';
import 'package:build4front/features/auth/presentation/login/bloc/auth_bloc.dart';

// ---------- ITEMS ----------
import 'package:build4front/features/items/data/services/items_api_service.dart';
import 'package:build4front/features/items/data/repositories/items_repository_impl.dart';
import 'package:build4front/features/items/domain/repositories/items_repository.dart';
import 'package:build4front/features/items/domain/usecases/get_guest_upcoming_items.dart';
import 'package:build4front/features/items/domain/usecases/get_interest_based_items.dart';
import 'package:build4front/features/items/domain/usecases/get_items_by_type.dart';

// ---------- ITEM TYPES ----------
import 'package:build4front/features/catalog/data/services/item_type_api_service.dart';
import 'package:build4front/features/catalog/data/repositories/item_type_repository_impl.dart';
import 'package:build4front/features/catalog/domain/repositories/item_type_repository.dart';
import 'package:build4front/features/catalog/domain/usecases/get_item_types_by_project.dart';

// ---------- CATEGORIES ----------
import 'package:build4front/features/catalog/data/services/category_api_service.dart';
import 'package:build4front/features/catalog/data/repositories/category_repository_impl.dart';
import 'package:build4front/features/catalog/domain/repositories/category_repository.dart';
import 'package:build4front/features/catalog/domain/usecases/get_categories_by_project.dart';

// ---------- HOME ----------
import 'package:build4front/features/home/presentation/bloc/home_bloc.dart';
import 'package:build4front/features/home/presentation/bloc/home_event.dart';

import 'app_view.dart';

class Build4AllFrontApp extends StatelessWidget {
  const Build4AllFrontApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Read static build-time config (owner/project/app type etc.)
    final appConfig = AppConfig.fromEnv();

    // ---------- AUTH LAYER ----------
    final tokenStore = AuthTokenStore();
    final authApi = AuthApiService(tokenStore: tokenStore);
    final authRepo = AuthRepositoryImpl(api: authApi);

    // ---------- ITEMS LAYER ----------
    final itemsApi = ItemsApiService();
    final itemsRepo = ItemsRepositoryImpl(api: itemsApi);

    // ---------- ITEM TYPES LAYER ----------
    final itemTypeApi = ItemTypeApiService();
    final itemTypeRepo = ItemTypeRepositoryImpl(api: itemTypeApi);

    // ---------- CATEGORIES LAYER ----------
    final categoryApi = CategoryApiService();
    final categoryRepo = CategoryRepositoryImpl(api: categoryApi);

    return MultiRepositoryProvider(
      providers: [
        // Auth
        RepositoryProvider<AuthTokenStore>.value(value: tokenStore),
        RepositoryProvider<AuthApiService>.value(value: authApi),
        RepositoryProvider<AuthRepositoryImpl>.value(value: authRepo),

        // Items
        RepositoryProvider<ItemsApiService>.value(value: itemsApi),
        RepositoryProvider<ItemsRepository>.value(value: itemsRepo),

        // Item types
        RepositoryProvider<ItemTypeApiService>.value(value: itemTypeApi),
        RepositoryProvider<ItemTypeRepository>.value(value: itemTypeRepo),

        // Categories
        RepositoryProvider<CategoryApiService>.value(value: categoryApi),
        RepositoryProvider<CategoryRepository>.value(value: categoryRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          // Global theme (design tokens, colors, typography...)
          BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),

          // Connectivity watcher (WiFi/server availability)
          BlocProvider<ConnectionCubit>(
            create: (_) {
              final cubit = ConnectionCubit();
              // Expose globally so network layer can use it
              g.registerConnectionCubit(cubit);
              return cubit;
            },
          ),

          // Auth bloc: handles login/logout, user session
          BlocProvider<AuthBloc>(
            create: (ctx) => AuthBloc(
              loginWithEmail: LoginWithEmail(
                ctx.read<AuthRepositoryImpl>(),
                ctx.read<AuthApiService>(),
              ),
            ),
          ),

          // Home bloc: items + types + categories for home screen
          BlocProvider<HomeBloc>(
            create: (ctx) => HomeBloc(
              // Popular / upcoming items (guest)
              getGuestUpcomingItems: GetGuestUpcomingItems(
                ctx.read<ItemsRepository>(),
              ),
              // Later: interest-based items when user logged-in
              getInterestBasedItems: GetInterestBasedItems(
                ctx.read<ItemsRepository>(),
              ),
              // Fetch items by type (for filters/sections)
              getItemsByType: GetItemsByType(ctx.read<ItemsRepository>()),
              // Load ItemTypes per project (types like: LAPTOP, HEADPHONES...)
              getItemTypesByProject: GetItemTypesByProject(
                ctx.read<ItemTypeRepository>(),
              ),
              // ✅ NEW: load Categories by project (ex: LAPTOPS, PHONES...)
              getCategoriesByProject: GetCategoriesByProject(
                ctx.read<CategoryRepository>(),
              ),
            )..add(const HomeStarted()), // initial load
          ),
        ],
        // Main app view (MaterialApp + navigation shell)
        child: AppView(appConfig: appConfig),
      ),
    );
  }
}
