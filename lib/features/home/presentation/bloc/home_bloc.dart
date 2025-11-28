// lib/features/home/presentation/bloc/home_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/env.dart';

import '../../../items/domain/entities/item_summary.dart';
import '../../../catalog/domain/entities/item_type.dart';

import '../../../items/domain/usecases/get_guest_upcoming_items.dart';
import '../../../items/domain/usecases/get_interest_based_items.dart';
import '../../../items/domain/usecases/get_items_by_type.dart';
import '../../../catalog/domain/usecases/get_item_types_by_project.dart';

import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetGuestUpcomingItems getGuestUpcomingItems;
  final GetInterestBasedItems getInterestBasedItems;
  final GetItemsByType getItemsByType;
  final GetItemTypesByProject getItemTypesByProject;

  HomeBloc({
    required this.getGuestUpcomingItems,
    required this.getInterestBasedItems,
    required this.getItemsByType,
    required this.getItemTypesByProject,
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

      // 1) Popular items = guest upcoming
      final List<ItemSummary> popularItems =
          await getGuestUpcomingItems(); // typeId optional later

      // 2) Item types by project → categories (string names)
      List<ItemType> types = <ItemType>[];
      if (projectId > 0) {
        types = await getItemTypesByProject(projectId);
      }

      final List<String> categories = types.map((t) => t.name).toList();

      // 3) Recommended items – later: interest-based with user+token
      final List<ItemSummary> recommendedItems = popularItems;

      emit(
        state.copyWith(
          isLoading: false,
          hasLoaded: true,
          errorMessage: null,
          popularItems: popularItems,
          recommendedItems: recommendedItems,
          categories: categories,
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
