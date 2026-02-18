import '../entities/shipping_method.dart';

abstract class ShippingRepository {
  // ✅ ownerProjectId removed: derived from token now
  Future<List<ShippingMethod>> listMethods({
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

  // ✅ Keep public list (needs ownerProjectId)
  Future<List<ShippingMethod>> listPublicMethods({
    required int ownerProjectId,
    required String authToken,
  });
}
