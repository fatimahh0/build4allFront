import '../entities/checkout_entities.dart';
import '../repositories/checkout_repository.dart';

class GetPaymentMethods {
  final CheckoutRepository repo;
  GetPaymentMethods(this.repo);

  Future<List<PaymentMethod>> call() => repo.getEnabledPaymentMethods();
}
