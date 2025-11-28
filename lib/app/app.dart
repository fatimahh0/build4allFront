import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:build4front/l10n/app_localizations.dart';

import '../core/config/app_config.dart';
import '../core/theme/theme_cubit.dart';

// ---------- AUTH ----------
import 'package:build4front/features/auth/data/services/auth_token_store.dart';
import 'package:build4front/features/auth/data/services/auth_api_service.dart';
import 'package:build4front/features/auth/data/repository/auth_repository_impl.dart';
import 'package:build4front/features/auth/domain/usecases/login_with_email.dart';
import 'package:build4front/features/auth/presentation/login/bloc/auth_bloc.dart';
import 'package:build4front/features/auth/presentation/login/screens/user_login_screen.dart';

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

class Build4AllFrontApp extends StatelessWidget {
  const Build4AllFrontApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appConfig = AppConfig.fromEnv();

    // ===== AUTH =====
    final tokenStore = AuthTokenStore();
    final authApi = AuthApiService(tokenStore: tokenStore);
    final authRepo = AuthRepositoryImpl(api: authApi);

    // ===== ITEMS =====
    final itemsApi = ItemsApiService();
    final itemsRepo = ItemsRepositoryImpl(api: itemsApi);

    // ===== ITEM TYPES =====
    final itemTypeApi = ItemTypeApiService();
    final itemTypeRepo = ItemTypeRepositoryImpl(api: itemTypeApi);

    return MultiRepositoryProvider(
      providers: [
        // AUTH
        RepositoryProvider<AuthTokenStore>.value(value: tokenStore),
        RepositoryProvider<AuthApiService>.value(value: authApi),
        RepositoryProvider<AuthRepositoryImpl>.value(value: authRepo),

        // ITEMS
        RepositoryProvider<ItemsApiService>.value(value: itemsApi),
        RepositoryProvider<ItemsRepository>.value(value: itemsRepo),

        // ITEM TYPES
        RepositoryProvider<ItemTypeApiService>.value(value: itemTypeApi),
        RepositoryProvider<ItemTypeRepository>.value(value: itemTypeRepo),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MultiBlocProvider(
            providers: [
              // AUTH BLOC
              BlocProvider<AuthBloc>(
                create: (ctx) => AuthBloc(
                  loginWithEmail: LoginWithEmail(
                    ctx.read<AuthRepositoryImpl>(),
                  ),
                ),
              ),

              // HOME BLOC
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
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: appConfig.appName,
              theme: themeState.themeData,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              localeResolutionCallback: (locale, supported) {
                if (locale == null) return supported.first;
                for (final l in supported) {
                  if (l.languageCode == locale.languageCode) {
                    return l;
                  }
                }
                return supported.first;
              },
              home: UserLoginScreen(appConfig: appConfig),
            ),
          );
        },
      ),
    );
  }
}
