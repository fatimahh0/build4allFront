import '../entities/cart_entity.dart';
import '../repositories/cart_repository.dart';

class AddToCart {
  final CartRepository repo;

  AddToCart(this.repo);

  Future<CartEntity> call({required int itemId, int quantity = 1}) {
    return repo.addItem(itemId: itemId, quantity: quantity);
  }
}
