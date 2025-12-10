import '../entities/shipping_method.dart';
import '../repositories/shipping_repository.dart';

class GetShippingMethod {
  final ShippingRepository repo;
  GetShippingMethod(this.repo);

  Future<ShippingMethod> call({required int id, required String authToken}) {
    return repo.getMethod(id: id, authToken: authToken);
  }
}
