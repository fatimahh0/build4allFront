import 'package:build4front/core/config/env.dart';
import 'package:build4front/features/catalog/data/models/item_type_model.dart';
import 'package:build4front/features/catalog/data/services/item_type_api_service.dart';
import 'package:build4front/features/catalog/domain/entities/item_type.dart';
import 'package:build4front/features/catalog/domain/repositories/item_type_repository.dart';

class ItemTypeRepositoryImpl implements ItemTypeRepository {
  final ItemTypeApiService api;

  ItemTypeRepositoryImpl({required this.api});

  int _ownerProjectId() {
    final v = Env.ownerProjectLinkId;
    final parsed = int.tryParse('$v');
    if (parsed == null || parsed <= 0) {
      throw StateError('Env.ownerProjectLinkId is missing/invalid: $v');
    }
    return parsed;
  }

  @override
  Future<List<ItemType>> getByProject(int projectId) async {
    final list = await api.getItemTypesByProject(
      projectId,
      
      // authToken: optional (only pass if your ApiFetch doesn't attach it globally)
    );

    return list.map((m) => ItemTypeModel.fromJson(m).toEntity()).toList();
  }

  @override
  Future<List<ItemType>> getByCategory(int categoryId) async {
    final list = await api.getItemTypesByCategory(
      categoryId,
      
      // authToken: optional (only pass if your ApiFetch doesn't attach it globally)
    );

    return list.map((m) => ItemTypeModel.fromJson(m).toEntity()).toList();
  }
}
