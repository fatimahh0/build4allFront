import '../entities/admin_order_entities.dart';
import '../repositories/admin_orders_repository.dart';

class GetAdminOrderDetails {
  final AdminOrdersRepository repo;
  GetAdminOrderDetails(this.repo);

  Future<OrderDetailsResponse> call({required int orderId}) {
    return repo.getOrderDetails(orderId: orderId);
  }
}
