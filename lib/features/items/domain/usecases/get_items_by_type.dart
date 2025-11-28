import '../entities/item_summary.dart';
import '../repositories/items_repository.dart';

class GetItemsByType {
  final ItemsRepository repo;

  GetItemsByType(this.repo);

  Future<List<ItemSummary>> call(int typeId) {
    return repo.getByType(typeId);
  }
}
