import '../entities/shipping_method.dart';

abstract class ShippingRepository {
  Future<List<ShippingMethod>> listMethods({
    required int ownerProjectId,
    required String authToken,
  });

  Future<ShippingMethod> getMethod({
    required int id,
    required String authToken,
  });

  Future<ShippingMethod> createMethod({
    required Map<String, dynamic> body,
    required String authToken,
  });

  Future<ShippingMethod> updateMethod({
    required int id,
    required Map<String, dynamic> body,
    required String authToken,
  });

  Future<void> deleteMethod({required int id, required String authToken});
}
