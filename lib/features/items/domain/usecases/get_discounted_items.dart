// lib/features/items/domain/usecases/get_discounted_items.dart

import '../entities/item_summary.dart';
import '../repositories/items_repository.dart';

/// Use case: fetch "discounted / flash sale" items.
///
/// - E-commerce:
///     /api/products/discounted
/// - Activities:
///     falls back to /api/items/guest/upcoming
class GetDiscountedItems {
  final ItemsRepository repo;

  GetDiscountedItems(this.repo);

  Future<List<ItemSummary>> call({int? categoryId}) {
    return repo.getDiscounted(categoryId: categoryId);
  }
}
