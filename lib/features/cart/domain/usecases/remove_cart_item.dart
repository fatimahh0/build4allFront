// lib/features/cart/domain/usecases/remove_cart_item.dart
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class RemoveCartItem {
  final CartRepository repo;

  RemoveCartItem(this.repo);

  Future<Cart> call({required int cartItemId}) {
    return repo.removeCartItem(cartItemId: cartItemId);
  }
}
