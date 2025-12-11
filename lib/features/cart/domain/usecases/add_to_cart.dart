// lib/features/cart/domain/usecases/add_to_cart.dart
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class AddToCart {
  final CartRepository repo;

  AddToCart(this.repo);

  Future<Cart> call({required int itemId, int quantity = 1}) {
    return repo.addToCart(itemId: itemId, quantity: quantity);
  }
}
