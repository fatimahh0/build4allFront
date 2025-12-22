import '../entities/admin_order_entities.dart';
import '../repositories/admin_orders_repository.dart';

class GetAdminOrders {
  final AdminOrdersRepository repo;
  GetAdminOrders(this.repo);

  Future<List<OrderHeaderRow>> call({String? status}) {
    return repo.getOrders(status: status);
  }
}
