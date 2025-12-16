// lib/app/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/config/env.dart';
import 'package:build4front/core/network/connecting(wifiORserver)/connection_cubit.dart';
import 'package:build4front/core/network/globals.dart' as g;
import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/core/config/app_config.dart';

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
import 'package:build4front/features/items/domain/usecases/get_new_arrivals_items.dart';
import 'package:build4front/features/items/domain/usecases/get_best_sellers_items.dart';
import 'package:build4front/features/items/domain/usecases/get_discounted_items.dart';

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

// ---------- CART ----------
import 'package:build4front/features/cart/data/services/cart_api_service.dart';
import 'package:build4front/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:build4front/features/cart/domain/repositories/cart_repository.dart';
import 'package:build4front/features/cart/domain/usecases/get_my_cart.dart';
import 'package:build4front/features/cart/domain/usecases/add_to_cart.dart';
import 'package:build4front/features/cart/domain/usecases/update_cart_item.dart';
import 'package:build4front/features/cart/domain/usecases/remove_cart_item.dart';
import 'package:build4front/features/cart/domain/usecases/clear_cart.dart';
import 'package:build4front/features/cart/presentation/bloc/cart_bloc.dart';

// ---------- CHECKOUT ----------
import 'package:build4front/features/checkout/data/services/checkout_api_service.dart';
import 'package:build4front/features/checkout/data/repositories/checkout_repository_impl.dart';
import 'package:build4front/features/checkout/domain/repositories/checkout_repository.dart';

// ---------- CURRENCY (GLOBAL) ----------
import 'package:build4front/features/catalog/cubit/currency_cubit.dart';
import 'package:build4front/features/catalog/data/services/currency_api_service.dart';
import 'package:build4front/features/catalog/data/repositories/currency_repository_impl.dart';
import 'package:build4front/features/catalog/domain/repositories/currency_repository.dart';
import 'package:build4front/features/catalog/domain/usecases/get_currency_by_id.dart';

import 'app_view.dart';

class Build4AllFrontApp extends StatelessWidget {
  const Build4AllFrontApp({super.key});

  @override
  Widget build(BuildContext context) {
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

    // ---------- CART LAYER ----------
    final cartApi = CartApiService();
    final cartRepo = CartRepositoryImpl(cartApi);

    // ---------- CHECKOUT LAYER (single instances) ----------
    final checkoutApi = CheckoutApiService();
    final checkoutRepo = CheckoutRepositoryImpl(checkoutApi);

    // ---------- CURRENCY LAYER (single instances) ----------
    final currencyApi = CurrencyApiService();
    final currencyRepo = CurrencyRepositoryImpl(api: currencyApi);

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

        // Cart
        RepositoryProvider<CartApiService>.value(value: cartApi),
        RepositoryProvider<CartRepository>.value(value: cartRepo),

        // Checkout
        RepositoryProvider<CheckoutApiService>.value(value: checkoutApi),
        RepositoryProvider<CheckoutRepository>.value(value: checkoutRepo),

        // Currency
        RepositoryProvider<CurrencyApiService>.value(value: currencyApi),
        RepositoryProvider<CurrencyRepository>.value(value: currencyRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          // ✅ ONE ThemeCubit globally (don’t create another one in main.dart)
          BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),

          BlocProvider<ConnectionCubit>(
            create: (_) {
              final cubit = ConnectionCubit();
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
              getCategoriesByProject: GetCategoriesByProject(
                ctx.read<CategoryRepository>(),
              ),

              getNewArrivalsItems: GetNewArrivalsItems(
                ctx.read<ItemsRepository>(),
              ),
              getBestSellersItems: GetBestSellersItems(
                ctx.read<ItemsRepository>(),
              ),
              getDiscountedItems: GetDiscountedItems(
                ctx.read<ItemsRepository>(),
              ),
            )..add(const HomeStarted()),
          ),

          BlocProvider<CartBloc>(
            create: (ctx) => CartBloc(
              getMyCart: GetMyCart(ctx.read<CartRepository>()),
              addToCartUc: AddToCart(ctx.read<CartRepository>()),
              updateCartItemUc: UpdateCartItem(ctx.read<CartRepository>()),
              removeCartItemUc: RemoveCartItem(ctx.read<CartRepository>()),
              clearCartUc: ClearCart(ctx.read<CartRepository>()),
            ),
          ),

          // ✅ Global CurrencyCubit (loads ONCE for the whole app)
          BlocProvider<CurrencyCubit>(
            create: (ctx) {
              final currencyId = int.tryParse(Env.currencyId) ?? 1;
              return CurrencyCubit(
                getCurrencyById: GetCurrencyById(
                  ctx.read<CurrencyRepository>(),
                ),
              )..load(currencyId);
            },
          ),
        ],
        child: AppView(appConfig: appConfig),
      ),
    );
  }
}
