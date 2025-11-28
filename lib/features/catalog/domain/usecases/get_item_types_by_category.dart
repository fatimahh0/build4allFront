// lib/features/catalog/domain/usecases/get_item_types_by_category.dart
import '../entities/item_type.dart';
import '../repositories/item_type_repository.dart';

class GetItemTypesByCategory {
  final ItemTypeRepository repo;

  GetItemTypesByCategory(this.repo);

  Future<List<ItemType>> call(int categoryId) {
    return repo.getByCategory(categoryId);
  }
}
