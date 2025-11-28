// lib/features/home/presentation/bloc/home_state.dart

import 'package:equatable/equatable.dart';
import '../../../items/domain/entities/item_summary.dart';

class HomeState extends Equatable {
  final bool isLoading;
  final bool hasLoaded;
  final String? errorMessage;

  /// dynamic list from backend
  final List<ItemSummary> popularItems;

  /// later: real interest-based; for now can mirror popular
  final List<ItemSummary> recommendedItems;

  /// category labels only → used by chips (strings, not ItemType)
  final List<String> categories;

  const HomeState({
    required this.isLoading,
    required this.hasLoaded,
    required this.errorMessage,
    required this.popularItems,
    required this.recommendedItems,
    required this.categories,
  });

  factory HomeState.initial() => const HomeState(
    isLoading: false,
    hasLoaded: false,
    errorMessage: null,
    popularItems: <ItemSummary>[],
    recommendedItems: <ItemSummary>[],
    categories: <String>[],
  );

  HomeState copyWith({
    bool? isLoading,
    bool? hasLoaded,
    String? errorMessage,
    List<ItemSummary>? popularItems,
    List<ItemSummary>? recommendedItems,
    List<String>? categories,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      errorMessage: errorMessage,
      popularItems: popularItems ?? this.popularItems,
      recommendedItems: recommendedItems ?? this.recommendedItems,
      categories: categories ?? this.categories,
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
  ];
}
