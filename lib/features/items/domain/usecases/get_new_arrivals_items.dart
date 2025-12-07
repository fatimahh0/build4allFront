// lib/features/items/domain/usecases/get_new_arrivals_items.dart

import '../entities/item_summary.dart';
import '../repositories/items_repository.dart';

/// Use case: fetch "new arrivals" items.
///
/// - E-commerce:
///     /api/products/new-arrivals
/// - Activities:
///     falls back to /api/items/guest/upcoming
class GetNewArrivalsItems {
  final ItemsRepository repo;

  GetNewArrivalsItems(this.repo);

  Future<List<ItemSummary>> call({int? categoryId, int? days}) {
    return repo.getNewArrivals(categoryId: categoryId, days: days);
  }
}
