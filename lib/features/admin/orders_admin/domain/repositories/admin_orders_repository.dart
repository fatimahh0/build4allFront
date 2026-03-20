import 'package:build4front/features/admin/orders_admin/data/models/cash_mark_paid_result_model.dart';

import '../entities/admin_order_entities.dart';

abstract class AdminOrdersRepository {
  Future<List<OrderHeaderRow>> getOrders({String? status});
  Future<OrderDetailsResponse> getOrderDetails({required int orderId});

  Future<void> updateOrderStatus({
    required int orderId,
    required String status,
  });

  
 Future<void> markCashPaid({required int orderId});
Future<void> resetCashToUnpaid({required int orderId});
Future<void> reopenOrder({required int orderId});
Future<void> editOrder({
  required int orderId,
  required Map<String, dynamic> body,
});
}
