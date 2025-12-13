import '../entities/checkout_entities.dart';
import '../repositories/checkout_repository.dart';

class PreviewTax {
  final CheckoutRepository repo;
  PreviewTax(this.repo);

  Future<TaxPreview> call({
    required int ownerProjectId,
    required ShippingAddress address,
    required List<CartLine> lines,
    required double shippingTotal,
  }) {
    return repo.previewTax(
      ownerProjectId: ownerProjectId,
      address: address,
      lines: lines,
      shippingTotal: shippingTotal,
    );
  }
}
