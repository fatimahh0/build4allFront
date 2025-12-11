// lib/features/cart/domain/usecases/get_my_cart.dart
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class GetMyCart {
  final CartRepository repo;

  GetMyCart(this.repo);

  Future<Cart> call() => repo.getMyCart();
}
