// lib/features/items/domain/repositories/items_repository.dart

import '../entities/item_summary.dart';

/// Abstraction for items data source.
///
/// The UI and use cases depend on this interface,
/// not on the concrete implementation.
abstract class ItemsRepository {
  /// Upcoming / new items for guests (no auth).
  ///
  /// - Activities: /api/items/guest/upcoming
  /// - E-commerce: /api/products/new-arrivals
  Future<List<ItemSummary>> getGuestUpcoming({int? typeId});

  /// Items filtered by type (for activities) or category (for products).
  ///
  /// - Activities: /api/items/by-type/{typeId}
  /// - E-commerce: /api/products?ownerProjectId=...&categoryId=...
  Future<List<ItemSummary>> getByType(int typeId);

  /// Interest-based / recommended items for a specific user.
  ///
  /// - Activities: /api/items/category-based/{userId}
  /// - E-commerce: /api/products/best-sellers (used as recommendation)
  Future<List<ItemSummary>> getInterestBased({
    required int userId,
    required String token,
  });

  /// New arrivals list (e-commerce) with safe fallback for activities.
  ///
  /// - E-commerce: /api/products/new-arrivals
  /// - Activities: /api/items/guest/upcoming (fallback)
  Future<List<ItemSummary>> getNewArrivals({int? categoryId, int? days});

  /// Best sellers list (e-commerce) with safe fallback for activities.
  ///
  /// - E-commerce: /api/products/best-sellers
  /// - Activities: /api/items/guest/upcoming (fallback)
  Future<List<ItemSummary>> getBestSellers({int? categoryId, int limit});

  /// Discounted / on-sale list (e-commerce) with safe fallback for activities.
  ///
  /// - E-commerce: /api/products/discounted
  /// - Activities: /api/items/guest/upcoming (fallback)
  Future<List<ItemSummary>> getDiscounted({int? categoryId});
}
