import '../../domain/entities/item_details.dart';
import '../../domain/entities/item_summary.dart';
import '../../domain/repositories/items_repository.dart';
import '../models/item_details_model.dart';
import '../models/item_summary_model.dart';
import '../services/items_api_service.dart';

/// Concrete implementation of [ItemsRepository] that uses
/// [ItemsApiService] to talk to the backend.
class ItemsRepositoryImpl implements ItemsRepository {
  final ItemsApiService api;

  ItemsRepositoryImpl({required this.api});

  /// Helper: map a list of dynamic JSON objects into
  /// a list of [ItemSummary] domain entities.
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
  Future<List<ItemSummary>> getGuestUpcoming(
      {int? typeId, String? token}) async {
    final data = await api.getUpcomingGuest(typeId: typeId, token: token);
    return _mapList(data);
  }

  @override
  Future<List<ItemSummary>> getByType(int typeId, {String? token}) async {
    final data = await api.getByType(typeId, token: token);
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

  @override
  Future<ItemDetails> getById(int id, {String? token}) async {
    final data = await api.getById(id, token: token);
    return ItemDetailsModel.fromJson(data).toEntity();
  }

  @override
  Future<ItemDetails> getDetails(int id, {String? token}) async {
    final json = await api.getDetails(id, token: token);
    return ItemDetailsModel.fromJson(json).toEntity();
  }

  @override
  Future<List<ItemSummary>> getNewArrivals({
    int? categoryId,
    int? days,
    String? token,
  }) async {
    final data = await api.getNewArrivals(
      categoryId: categoryId,
      days: days,
      token: token,
    );
    return _mapList(data);
  }

  @override
  Future<List<ItemSummary>> getBestSellers({
    int? categoryId,
    int limit = 20,
    String? token,
  }) async {
    final data = await api.getBestSellers(
      categoryId: categoryId,
      limit: limit,
      token: token,
    );
    return _mapList(data);
  }

  @override
  Future<List<ItemSummary>> getDiscounted(
      {int? categoryId, String? token}) async {
    final data = await api.getDiscounted(categoryId: categoryId, token: token);
    return _mapList(data);
  }
}
