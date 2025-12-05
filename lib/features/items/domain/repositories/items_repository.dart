import '../entities/item_summary.dart';

/// Abstraction for items data source.
///
/// The UI and use cases depend on this interface,
/// not on the concrete implementation.
abstract class ItemsRepository {
  /// Upcoming / new items for guests (no auth).
  Future<List<ItemSummary>> getGuestUpcoming({int? typeId});

  /// Items filtered by type (for activities) or category (for products).
  Future<List<ItemSummary>> getByType(int typeId);

  /// Interest-based / recommended items for a specific user.
  Future<List<ItemSummary>> getInterestBased({
    required int userId,
    required String token,
  });
}
