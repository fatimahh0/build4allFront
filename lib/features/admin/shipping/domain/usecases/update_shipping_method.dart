import '../entities/shipping_method.dart';
import '../repositories/shipping_repository.dart';

class UpdateShippingMethod {
  final ShippingRepository repo;
  UpdateShippingMethod(this.repo);

  Future<ShippingMethod> call({
    required int id,
    required Map<String, dynamic> body,
    required String authToken,
  }) {
    return repo.updateMethod(id: id, body: body, authToken: authToken);
  }
}
