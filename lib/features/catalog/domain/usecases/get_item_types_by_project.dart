// lib/features/catalog/domain/usecases/get_item_types_by_project.dart
import '../entities/item_type.dart';
import '../repositories/item_type_repository.dart';

class GetItemTypesByProject {
  final ItemTypeRepository repo;

  GetItemTypesByProject(this.repo);

  Future<List<ItemType>> call(int projectId) {
    return repo.getByProject(projectId);
  }
}
