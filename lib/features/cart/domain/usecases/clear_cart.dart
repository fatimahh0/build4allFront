import '../repositories/cart_repository.dart';

class ClearCart {
  final CartRepository repo;

  ClearCart(this.repo);

  Future<void> call() {
    return repo.clearCart();
  }
}
