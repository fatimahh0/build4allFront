import '../entities/item_summary.dart';
import '../entities/item_details.dart';

abstract class ItemsRepository {
  Future<List<ItemSummary>> getGuestUpcoming({int? typeId});
  Future<List<ItemSummary>> getByType(int typeId);
  Future<List<ItemSummary>> getInterestBased({
    required int userId,
    required String token,
  });
  Future<List<ItemSummary>> getNewArrivals({int? categoryId, int? days});
  Future<List<ItemSummary>> getBestSellers({int? categoryId, int limit});
  Future<List<ItemSummary>> getDiscounted({int? categoryId});


  Future<ItemDetails> getById(int id);
  Future<ItemDetails> getDetails(int id, {String? token});
}
