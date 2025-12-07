import '../entities/cart_entity.dart';
import '../repositories/cart_repository.dart';

class GetCart {
  final CartRepository repo;

  GetCart(this.repo);

  Future<CartEntity> call() {
    return repo.getCart();
  }
}
