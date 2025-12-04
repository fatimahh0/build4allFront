import 'package:build4front/features/catalog/data/models/item_type_model.dart';
import 'package:build4front/features/catalog/data/services/item_type_api_service.dart';
import 'package:build4front/features/catalog/domain/entities/item_type.dart';
import 'package:build4front/features/catalog/domain/repositories/item_type_repository.dart';

class ItemTypeRepositoryImpl implements ItemTypeRepository {
  final ItemTypeApiService api;

  ItemTypeRepositoryImpl({required this.api});

  @override
  Future<List<ItemType>> getByProject(int projectId) async {
    final list = await api.getItemTypesByProject(projectId);
    return list.map((m) => ItemTypeModel.fromJson(m).toEntity()).toList();
  }

  @override
  Future<List<ItemType>> getByCategory(int categoryId) async {
    final list = await api.getItemTypesByCategory(categoryId);
    return list.map((m) => ItemTypeModel.fromJson(m).toEntity()).toList();
  }
}
