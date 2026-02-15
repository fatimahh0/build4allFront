import '../entities/item_summary.dart';
import '../entities/item_details.dart';

abstract class ItemsRepository {
  Future<List<ItemSummary>> getGuestUpcoming({int? typeId, String? token});

  Future<List<ItemSummary>> getByType(int typeId, {String? token});

  Future<List<ItemSummary>> getInterestBased({
    required int userId,
    required String token,
  });

  Future<List<ItemSummary>> getNewArrivals({
    int? categoryId,
    int? days,
    String? token,
  });

  Future<List<ItemSummary>> getBestSellers({
    int? categoryId,
    int limit,
    String? token,
  });

  Future<List<ItemSummary>> getDiscounted({int? categoryId, String? token});

  Future<ItemDetails> getById(int id, {String? token});
  Future<ItemDetails> getDetails(int id, {String? token});
}
