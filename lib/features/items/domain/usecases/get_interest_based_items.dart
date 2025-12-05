import '../entities/item_summary.dart';
import '../repositories/items_repository.dart';

/// Use case: fetch interest-based / recommended items
/// for a given user + token.
///
/// - Activities:
///     Backend uses user's categories to pick activities.
/// - E-commerce:
///     Currently mapped to "best-sellers" per app.
class GetInterestBasedItems {
  final ItemsRepository repo;

  GetInterestBasedItems(this.repo);

  Future<List<ItemSummary>> call({required int userId, required String token}) {
    return repo.getInterestBased(userId: userId, token: token);
  }
}
