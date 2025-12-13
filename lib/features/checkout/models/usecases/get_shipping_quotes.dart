import '../entities/checkout_entities.dart';
import '../repositories/checkout_repository.dart';

class GetShippingQuotes {
  final CheckoutRepository repo;
  GetShippingQuotes(this.repo);

  Future<List<ShippingQuote>> call({
    required int ownerProjectId,
    required ShippingAddress address,
    required List<CartLine> lines,
  }) {
    return repo.getShippingQuotes(
      ownerProjectId: ownerProjectId,
      address: address,
      lines: lines,
    );
  }
}
