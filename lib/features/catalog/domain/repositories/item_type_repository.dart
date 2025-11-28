// lib/features/catalog/domain/repositories/item_type_repository.dart

import '../entities/item_type.dart';

abstract class ItemTypeRepository {
  Future<List<ItemType>> getByProject(int projectId);
  Future<List<ItemType>> getByCategory(int categoryId);
}
