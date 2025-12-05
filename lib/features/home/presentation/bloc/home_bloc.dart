// lib/features/home/presentation/bloc/home_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/env.dart';

// items
import '../../../items/domain/entities/item_summary.dart';
import '../../../items/domain/usecases/get_guest_upcoming_items.dart';
import '../../../items/domain/usecases/get_interest_based_items.dart';
import '../../../items/domain/usecases/get_items_by_type.dart';

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
  final GetCategoriesByProject getCategoriesByProject; // ✅ NEW

  HomeBloc({
    required this.getGuestUpcomingItems,
    required this.getInterestBasedItems,
    required this.getItemsByType,
    required this.getItemTypesByProject,
    required this.getCategoriesByProject,
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

      // 1) Popular items = guest upcoming / new arrivals (dynamic by appType)
      final List<ItemSummary> popularItems = await getGuestUpcomingItems();


      final List<ItemSummary> recommendedItems = popularItems;


      List<String> categoryLabels = <String>[];

      if (projectId > 0) {
  
        final List<ItemType> types = await getItemTypesByProject(
          projectId,
        ); // ignore: unused_local_variable

      
        final List<Category> allCategories = await getCategoriesByProject(
          projectId,
        );

        final Set<int> usedCategoryIds = <int>{};
        for (final item in popularItems) {
          final cid = item.categoryId;
          if (cid != null) {
            usedCategoryIds.add(cid);
          }
        }

    
        final List<Category> filteredCategories = usedCategoryIds.isEmpty
            ? allCategories
            : allCategories
                  .where((cat) => usedCategoryIds.contains(cat.id))
                  .toList();

        categoryLabels = filteredCategories.map((c) => c.name).toList();
      }

      emit(
        state.copyWith(
          isLoading: false,
          hasLoaded: true,
          errorMessage: null,
          popularItems: popularItems,
          recommendedItems: recommendedItems,
          categories: categoryLabels,
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
