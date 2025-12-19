import '../entities/order_entities.dart';
import '../repositories/orders_repository.dart';

class GetMyOrders {
  final OrdersRepository repo;
  GetMyOrders(this.repo);

  Future<List<OrderLine>> call() => repo.getMyOrders();
}
