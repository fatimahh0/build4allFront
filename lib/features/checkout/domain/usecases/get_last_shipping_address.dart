import '../entities/checkout_entities.dart';
import '../repositories/checkout_repository.dart';

class GetLastShippingAddress {
  final CheckoutRepository repo;
  GetLastShippingAddress(this.repo);

  Future<ShippingAddress> call() => repo.getMyLastShippingAddress();
}
