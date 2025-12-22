import 'package:build4front/features/admin/orders_admin/data/models/cash_mark_paid_result_model.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/admin_order_entities.dart';
import '../../domain/repositories/admin_orders_repository.dart';
import '../models/admin_orders_models.dart';
import '../services/admin_orders_api_service.dart';

class AdminOrdersRepositoryImpl implements AdminOrdersRepository {
  final AdminOrdersApiService api;
  AdminOrdersRepositoryImpl({required this.api});

  Never _throwNice(DioException e, {String fallback = 'Request failed'}) {
    final data = e.response?.data;
    if (data is Map && data['error'] != null) {
      throw Exception(data['error'].toString());
    }
    throw Exception(e.message ?? fallback);
  }

  @override
  Future<List<OrderHeaderRow>> getOrders({String? status}) async {
    try {
      final raw = await api.getOrdersRaw(status: status);
      return raw
          .whereType<Map>()
          .map((m) => OrderHeaderRowModel.fromJson(m.cast<String, dynamic>()))
          .map((m) => m.toEntity())
          .toList();
    } on DioException catch (e) {
      _throwNice(e, fallback: 'Failed to load orders');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<OrderDetailsResponse> getOrderDetails({required int orderId}) async {
    try {
      final raw = await api.getOrderDetailsRaw(orderId: orderId);
      return OrderDetailsResponseModel.fromJson(raw).toEntity();
    } on DioException catch (e) {
      _throwNice(e, fallback: 'Failed to load order details');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    try {
      await api.updateOrderStatusRaw(orderId: orderId, status: status);
    } on DioException catch (e) {
      _throwNice(e, fallback: 'Failed to update order status');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

   @override
  Future<void> updateOrderPaymentState({
    required int orderId,
    required String paymentState,
  }) async {
    try {
      await api.updateOrderPaymentStateRaw(
        orderId: orderId,
        paymentState: paymentState,
      );
    } on DioException catch (e) {
      _throwNice(e, fallback: 'Failed to update payment state');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
