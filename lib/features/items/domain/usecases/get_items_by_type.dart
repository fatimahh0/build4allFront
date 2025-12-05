import '../entities/item_summary.dart';
import '../repositories/items_repository.dart';

/// Use case: fetch items by type/category.
///
/// - Activities:
///     typeId = itemTypeId
/// - E-commerce:
///     typeId = categoryId
class GetItemsByType {
  final ItemsRepository repo;

  GetItemsByType(this.repo);

  Future<List<ItemSummary>> call(int typeId) {
    return repo.getByType(typeId);
  }
}
