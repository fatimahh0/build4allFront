import '../entities/item_summary.dart';
import '../repositories/items_repository.dart';

/// Use case: fetch "best sellers" items.
///
/// - E-commerce:
///     /api/products/best-sellers (token required)
/// - Activities:
///     falls back to /api/items/guest/upcoming
class GetBestSellersItems {
  final ItemsRepository repo;

  GetBestSellersItems(this.repo);

  Future<List<ItemSummary>> call(
      {int? categoryId, int limit = 20, String? token}) {
    return repo.getBestSellers(
        categoryId: categoryId, limit: limit, token: token);
  }
}
