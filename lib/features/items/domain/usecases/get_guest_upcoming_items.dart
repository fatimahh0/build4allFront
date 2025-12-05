import '../entities/item_summary.dart';
import '../repositories/items_repository.dart';

/// Use case: fetch guest upcoming / new items
/// (activities or products) optionally filtered by type.
///
/// For products:
///   - routes to /api/products/new-arrivals
/// For activities:
///   - routes to /api/items/guest/upcoming
class GetGuestUpcomingItems {
  final ItemsRepository repo;

  GetGuestUpcomingItems(this.repo);

  Future<List<ItemSummary>> call({int? typeId}) {
    return repo.getGuestUpcoming(typeId: typeId);
  }
}
