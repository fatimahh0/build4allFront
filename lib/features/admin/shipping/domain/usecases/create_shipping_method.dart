import '../entities/shipping_method.dart';
import '../repositories/shipping_repository.dart';

class CreateShippingMethod {
  final ShippingRepository repo;
  CreateShippingMethod(this.repo);

  Future<ShippingMethod> call({
    required Map<String, dynamic> body,
    required String authToken,
  }) {
    return repo.createMethod(body: body, authToken: authToken);
  }
}
