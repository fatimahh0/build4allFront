// lib/features/catalog/data/repositories/item_type_repository_impl.dart

import '../../domain/entities/item_type.dart';
import '../../domain/repositories/item_type_repository.dart';
import '../models/item_type_model.dart';
import '../services/item_type_api_service.dart';

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
