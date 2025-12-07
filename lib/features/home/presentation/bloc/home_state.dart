// lib/features/home/presentation/bloc/home_state.dart

import 'package:equatable/equatable.dart';
import '../../../items/domain/entities/item_summary.dart';

class HomeState extends Equatable {
  final bool isLoading;
  final bool hasLoaded;
  final String? errorMessage;

  /// "Popular" = generic main list (upcoming/new).
  final List<ItemSummary> popularItems;

  /// Later: real interest-based; for now can mirror popular.
  final List<ItemSummary> recommendedItems;

  /// Category labels used by chips.
  final List<String> categories;

  /// Flash sale / discounted items.
  final List<ItemSummary> flashSaleItems;

  /// New arrivals items.
  final List<ItemSummary> newArrivalsItems;

  /// Best sellers items.
  final List<ItemSummary> bestSellersItems;

  /// Top rated items (for now we can reuse best sellers).
  final List<ItemSummary> topRatedItems;

  const HomeState({
    required this.isLoading,
    required this.hasLoaded,
    required this.errorMessage,
    required this.popularItems,
    required this.recommendedItems,
    required this.categories,
    required this.flashSaleItems,
    required this.newArrivalsItems,
    required this.bestSellersItems,
    required this.topRatedItems,
  });

  factory HomeState.initial() => const HomeState(
    isLoading: false,
    hasLoaded: false,
    errorMessage: null,
    popularItems: <ItemSummary>[],
    recommendedItems: <ItemSummary>[],
    categories: <String>[],
    flashSaleItems: <ItemSummary>[],
    newArrivalsItems: <ItemSummary>[],
    bestSellersItems: <ItemSummary>[],
    topRatedItems: <ItemSummary>[],
  );

  HomeState copyWith({
    bool? isLoading,
    bool? hasLoaded,
    String? errorMessage,
    List<ItemSummary>? popularItems,
    List<ItemSummary>? recommendedItems,
    List<String>? categories,
    List<ItemSummary>? flashSaleItems,
    List<ItemSummary>? newArrivalsItems,
    List<ItemSummary>? bestSellersItems,
    List<ItemSummary>? topRatedItems,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      errorMessage: errorMessage,
      popularItems: popularItems ?? this.popularItems,
      recommendedItems: recommendedItems ?? this.recommendedItems,
      categories: categories ?? this.categories,
      flashSaleItems: flashSaleItems ?? this.flashSaleItems,
      newArrivalsItems: newArrivalsItems ?? this.newArrivalsItems,
      bestSellersItems: bestSellersItems ?? this.bestSellersItems,
      topRatedItems: topRatedItems ?? this.topRatedItems,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    hasLoaded,
    errorMessage,
    popularItems,
    recommendedItems,
    categories,
    flashSaleItems,
    newArrivalsItems,
    bestSellersItems,
    topRatedItems,
  ];
}
