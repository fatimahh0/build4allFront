// lib/features/items/data/repositories/items_repository_impl.dart

import '../../domain/entities/item_summary.dart';
import '../../domain/repositories/items_repository.dart';
import '../models/item_summary_model.dart';
import '../services/items_api_service.dart';

class ItemsRepositoryImpl implements ItemsRepository {
  final ItemsApiService api;

  ItemsRepositoryImpl({required this.api});

  List<ItemSummary> _mapList(List<dynamic> list) {
    return list
        .map(
          (e) => ItemSummaryModel.fromJson(
            Map<String, dynamic>.from(e as Map),
          ).toEntity(),
        )
        .toList();
  }

  @override
  Future<List<ItemSummary>> getGuestUpcoming({int? typeId}) async {
    final data = await api.getUpcomingGuest(typeId: typeId);
    return _mapList(data);
  }

  @override
  Future<List<ItemSummary>> getByType(int typeId) async {
    final data = await api.getByType(typeId);
    return _mapList(data);
  }

  @override
  Future<List<ItemSummary>> getInterestBased({
    required int userId,
    required String token,
  }) async {
    final data = await api.getInterestBased(userId: userId, token: token);
    return _mapList(data);
  }
}
