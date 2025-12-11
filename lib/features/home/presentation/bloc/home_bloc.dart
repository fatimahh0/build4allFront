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

// catalog (item types + categories)
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

  /// New use cases for e-commerce sections.
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
    await _loadHome(emit);
  }

  Future<void> _onRefresh(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    await _loadHome(emit);
  }

  Future<void> _loadHome(Emitter<HomeState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final projectId = int.tryParse(Env.projectId) ?? 0;

      // 1) Main "popular" list = upcoming/new items (works for both modes).
      final List<ItemSummary> popularItems = await getGuestUpcomingItems();

      // 2) Recommended: later we can use getInterestBased + userId + token.
      //    For now fallback to popular items to keep UI non-empty.
      final List<ItemSummary> recommendedItems = popularItems;

      // 3) Flash sale / discounted items.
      final List<ItemSummary> flashSaleItems = await getDiscountedItems.call();

      // 4) New arrivals items.
      final List<ItemSummary> newArrivalsItems = await getNewArrivalsItems
          .call();

      // 5) Best sellers items.
      final List<ItemSummary> bestSellersItems = await getBestSellersItems
          .call();

      // 6) Top rated: for now we simply reuse best sellers.
      final List<ItemSummary> topRatedItems = bestSellersItems;

      // 7) Build categories list (labels for chips + entities for filtering).
      List<String> categoryLabels = <String>[];
      List<Category> categoryEntities = <Category>[];

      if (projectId > 0) {
        // These are available if you need them later.
        final List<ItemType> types = await getItemTypesByProject(projectId);
        // ignore: unused_local_variable
        final _ = types;

        final List<Category> allCategories = await getCategoriesByProject(
          projectId,
        );

        // Collect categoryIds used in the popular items list.
        final Set<int> usedCategoryIds = <int>{};
        for (final item in popularItems) {
          final cid = item.categoryId;
          if (cid != null) {
            usedCategoryIds.add(cid);
          }
        }

        // Filter categories by those which are actually used.
        final List<Category> filteredCategories = usedCategoryIds.isEmpty
            ? allCategories
            : allCategories
                  .where((cat) => usedCategoryIds.contains(cat.id))
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
