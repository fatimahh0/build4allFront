import '../entities/item_summary.dart';
import '../repositories/items_repository.dart';

/// Use case: fetch "new arrivals" items.
///
/// - E-commerce:
///     /api/products/new-arrivals (token required)
/// - Activities:
///     falls back to /api/items/guest/upcoming
class GetNewArrivalsItems {
  final ItemsRepository repo;

  GetNewArrivalsItems(this.repo);

  Future<List<ItemSummary>> call({int? categoryId, int? days, String? token}) {
    return repo.getNewArrivals(
        categoryId: categoryId, days: days, token: token);
  }
}
