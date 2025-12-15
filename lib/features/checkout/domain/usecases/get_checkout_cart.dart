import '../entities/checkout_entities.dart';
import '../repositories/checkout_repository.dart';

class GetCheckoutCart {
  final CheckoutRepository repo;
  GetCheckoutCart(this.repo);

  Future<CheckoutCart> call() => repo.getMyCart();
}
