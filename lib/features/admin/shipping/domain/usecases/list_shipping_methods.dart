import '../entities/shipping_method.dart';
import '../repositories/shipping_repository.dart';

class ListShippingMethods {
  final ShippingRepository repo;
  ListShippingMethods(this.repo);

  Future<List<ShippingMethod>> call({
    required String authToken,
  }) {
    return repo.listMethods(authToken: authToken);
  }
}
