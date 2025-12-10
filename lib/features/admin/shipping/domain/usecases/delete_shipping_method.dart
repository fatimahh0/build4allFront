import '../repositories/shipping_repository.dart';

class DeleteShippingMethod {
  final ShippingRepository repo;
  DeleteShippingMethod(this.repo);

  Future<void> call({required int id, required String authToken}) {
    return repo.deleteMethod(id: id, authToken: authToken);
  }
}
