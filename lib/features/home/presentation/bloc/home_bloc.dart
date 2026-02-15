import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/env.dart';

// items
import '../../../items/domain/entities/item_summary.dart';
import '../../../items/domain/usecases/get_guest_upcoming_items.dart';
import '../../../items/domain/usecases/get_interest_based_items.dart';
import '../../../items/domain/usecases/get_items_by_type.dart';
import '../../../items/domain/usecases/get_new_arrivals_items.dart';
import '../../../items/domain/usecases/get_best_sellers_items.dart';
import '../../../items/domain/usecases/get_discounted_items.dart';

// catalog
import '../../../catalog/domain/entities/item_type.dart';
import '../../../catalog/domain/entities/category.dart';
import '../../../catalog/domain/usecases/get_item_types_by_project.dart';
import '../../../catalog/domain/usecases/get_categories_by_project.dart';

import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetGuestUpcomingItems getGuestUpcomingItems;
  final GetInterestBasedItems getInterestBasedItems;
  final GetItemsByType getItemsByType;
  final GetItemTypesByProject getItemTypesByProject;
  final GetCategoriesByProject getCategoriesByProject;

  final GetNewArrivalsItems getNewArrivalsItems;
  final GetBestSellersItems getBestSellersItems;
  final GetDiscountedItems getDiscountedItems;

  HomeBloc({
    required this.getGuestUpcomingItems,
    required this.getInterestBasedItems,
    required this.getItemsByType,
    required this.getItemTypesByProject,
    required this.getCategoriesByProject,
    required this.getNewArrivalsItems,
    required this.getBestSellersItems,
    required this.getDiscountedItems,
  }) : super(HomeState.initial()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefreshRequested>(_onRefresh);
  }

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    await _loadHome(emit, token: event.token);
  }

  Future<void> _onRefresh(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    await _loadHome(emit, token: event.token);
  }

  Set<int> _collectUsedCategoryIds(List<List<ItemSummary>> lists) {
    final set = <int>{};
    for (final list in lists) {
      for (final item in list) {
        final cid = item.categoryId;
        if (cid != null) set.add(cid);
      }
    }
    return set;
  }

  Future<void> _loadHome(Emitter<HomeState> emit, {String? token}) async {
    // ✅ Prevent duplicate requests if HomeStarted fired twice by mistake.
    if (state.isLoading) return;

    // ✅ Keep old lists while loading (nice UX)
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final projectId = int.tryParse(Env.projectId) ?? 0;

      // ✅ Start everything ASAP (parallel)
      final popularF = getGuestUpcomingItems(token: token);
      final flashF = getDiscountedItems.call(token: token);
      final newF = getNewArrivalsItems.call(days: 3650, token: token);
      final bestF = getBestSellersItems.call(limit: 20, token: token);

      final typesF = projectId > 0
          ? getItemTypesByProject(projectId)
          : Future.value(<ItemType>[]);

      final catsF = projectId > 0
          ? getCategoriesByProject(projectId)
          : Future.value(<Category>[]);

      // ✅ Await (already running in parallel)
      final popularItems = await popularF;
      final flashSaleItems = await flashF;
      final newArrivalsItems = await newF;
      final bestSellersItems = await bestF;

      // Recommended (temporary)
      final recommendedItems = popularItems;

      // Top rated (temporary)
      final topRatedItems = bestSellersItems;

      // ✅ Fetch types/categories (also already running)
      final types = await typesF;
      // ignore: unused_local_variable
      final _ = types;

      final allCategories = await catsF;

      // categories
      List<String> categoryLabels = <String>[];
      List<Category> categoryEntities = <Category>[];

      if (projectId > 0) {
        final usedCategoryIds = _collectUsedCategoryIds([
          popularItems,
          recommendedItems,
          flashSaleItems,
          newArrivalsItems,
          bestSellersItems,
          topRatedItems,
        ]);

        final filteredCategories = usedCategoryIds.isEmpty
            ? allCategories
            : allCategories
                .where((c) => usedCategoryIds.contains(c.id))
                .toList();

        categoryLabels = filteredCategories.map((c) => c.name).toList();
        categoryEntities = filteredCategories;
      }

      emit(
        state.copyWith(
          isLoading: false,
          hasLoaded: true,
          errorMessage: null,
          popularItems: popularItems,
          recommendedItems: recommendedItems,
          categories: categoryLabels,
          categoryEntities: categoryEntities,
          flashSaleItems: flashSaleItems,
          newArrivalsItems: newArrivalsItems,
          bestSellersItems: bestSellersItems,
          topRatedItems: topRatedItems,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          hasLoaded: true,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
