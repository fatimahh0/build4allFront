import '../entities/cart_entity.dart';
import '../repositories/cart_repository.dart';

class RemoveCartItem {
  final CartRepository repo;

  RemoveCartItem(this.repo);

  Future<CartEntity> call({required int cartItemId}) {
    return repo.removeItem(cartItemId: cartItemId);
  }
}
