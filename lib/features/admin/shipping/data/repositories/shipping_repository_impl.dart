import '../../domain/entities/shipping_method.dart';
import '../../domain/repositories/shipping_repository.dart';
import '../models/shipping_method_model.dart';
import '../services/shipping_api_service.dart';

class ShippingRepositoryImpl implements ShippingRepository {
  final ShippingApiService api;
  ShippingRepositoryImpl(this.api);

  @override
  Future<List<ShippingMethod>> listMethods({
    required int ownerProjectId,
    required String authToken,
  }) async {
    final list = await api.listMethods(
      ownerProjectId: ownerProjectId,
      authToken: authToken,
    );
    return list
        .map(
          (e) =>
              ShippingMethodModel.fromJson((e as Map).cast<String, dynamic>()),
        )
        .toList();
  }

  @override
  Future<ShippingMethod> getMethod({
    required int id,
    required String authToken,
  }) async {
    final json = await api.getMethod(id: id, authToken: authToken);
    return ShippingMethodModel.fromJson(json);
  }

  @override
  Future<ShippingMethod> createMethod({
    required Map<String, dynamic> body,
    required String authToken,
  }) async {
    final json = await api.createMethod(body: body, authToken: authToken);
    return ShippingMethodModel.fromJson(json);
  }

  @override
  Future<ShippingMethod> updateMethod({
    required int id,
    required Map<String, dynamic> body,
    required String authToken,
  }) async {
    final json = await api.updateMethod(
      id: id,
      body: body,
      authToken: authToken,
    );
    return ShippingMethodModel.fromJson(json);
  }

  @override
  Future<void> deleteMethod({required int id, required String authToken}) {
    return api.deleteMethod(id: id, authToken: authToken);
  }
}
