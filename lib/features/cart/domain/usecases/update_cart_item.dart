// lib/features/cart/domain/usecases/update_cart_item.dart
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class UpdateCartItem {
  final CartRepository repo;

  UpdateCartItem(this.repo);

  Future<Cart> call({required int cartItemId, required int quantity}) {
    return repo.updateCartItem(cartItemId: cartItemId, quantity: quantity);
  }
}
