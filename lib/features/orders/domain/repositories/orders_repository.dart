import '../entities/order_entities.dart';

abstract class OrdersRepository {
  Future<List<OrderLine>> getMyOrders();
}
