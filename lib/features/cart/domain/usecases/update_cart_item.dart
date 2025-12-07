import '../entities/cart_entity.dart';
import '../repositories/cart_repository.dart';

class UpdateCartItem {
  final CartRepository repo;

  UpdateCartItem(this.repo);

  Future<CartEntity> call({required int cartItemId, required int quantity}) {
    return repo.updateItemQuantity(cartItemId: cartItemId, quantity: quantity);
  }
}
