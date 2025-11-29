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

// ---------- HOME ----------
import 'package:build4front/features/home/presentation/bloc/home_bloc.dart';
import 'package:build4front/features/home/presentation/bloc/home_event.dart';

import 'app_view.dart';

class Build4AllFrontApp extends StatelessWidget {
  const Build4AllFrontApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appConfig = AppConfig.fromEnv();

    // ---------- AUTH ----------
    final tokenStore = AuthTokenStore();
    final authApi = AuthApiService(tokenStore: tokenStore);
    final authRepo = AuthRepositoryImpl(api: authApi);

    // ---------- ITEMS ----------
    final itemsApi = ItemsApiService();
    final itemsRepo = ItemsRepositoryImpl(api: itemsApi);

    // ---------- ITEM TYPES ----------
    final itemTypeApi = ItemTypeApiService();
    final itemTypeRepo = ItemTypeRepositoryImpl(api: itemTypeApi);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthTokenStore>.value(value: tokenStore),
        RepositoryProvider<AuthApiService>.value(value: authApi),
        RepositoryProvider<AuthRepositoryImpl>.value(value: authRepo),

        RepositoryProvider<ItemsApiService>.value(value: itemsApi),
        RepositoryProvider<ItemsRepository>.value(value: itemsRepo),

        RepositoryProvider<ItemTypeApiService>.value(value: itemTypeApi),
        RepositoryProvider<ItemTypeRepository>.value(value: itemTypeRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),

          BlocProvider<ConnectionCubit>(
            create: (_) {
              final cubit = ConnectionCubit();
              // Register globally so network layer (if needed) can use it too
              g.registerConnectionCubit(cubit);
              return cubit;
            },
          ),

          BlocProvider<AuthBloc>(
            create: (ctx) => AuthBloc(
              loginWithEmail: LoginWithEmail(
                ctx.read<AuthRepositoryImpl>(),
                ctx.read<AuthApiService>(),
              ),
            ),
          ),

          BlocProvider<HomeBloc>(
            create: (ctx) => HomeBloc(
              getGuestUpcomingItems: GetGuestUpcomingItems(
                ctx.read<ItemsRepository>(),
              ),
              getInterestBasedItems: GetInterestBasedItems(
                ctx.read<ItemsRepository>(),
              ),
              getItemsByType: GetItemsByType(ctx.read<ItemsRepository>()),
              getItemTypesByProject: GetItemTypesByProject(
                ctx.read<ItemTypeRepository>(),
              ),
            )..add(const HomeStarted()),
          ),
        ],
        child: AppView(appConfig: appConfig),
      ),
    );
  }
}
