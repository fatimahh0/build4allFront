// lib/features/cart/domain/usecases/clear_cart.dart
import '../repositories/cart_repository.dart';

class ClearCart {
  final CartRepository repo;

  ClearCart(this.repo);

  Future<void> call() => repo.clearCart();
}
