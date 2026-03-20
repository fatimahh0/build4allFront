import 'package:build4front/features/admin/orders_admin/domain/repositories/admin_orders_repository.dart';

class EditOrderUc {
  final AdminOrdersRepository repo;
  EditOrderUc(this.repo);

  Future<void> call({
    required int orderId,
    required Map<String, dynamic> body,
  }) {
    return repo.editOrder(orderId: orderId, body: body);
  }
}