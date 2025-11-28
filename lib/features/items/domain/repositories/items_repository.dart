// lib/features/items/domain/repositories/items_repository.dart

import '../entities/item_summary.dart';

abstract class ItemsRepository {
  Future<List<ItemSummary>> getGuestUpcoming({int? typeId});
  Future<List<ItemSummary>> getByType(int typeId);
  Future<List<ItemSummary>> getInterestBased({
    required int userId,
    required String token,
  });
}
