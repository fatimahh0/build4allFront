import 'package:dio/dio.dart';

import '../../domain/entities/order_entities.dart';
import '../../domain/repositories/orders_repository.dart';
import '../models/orders_models.dart';
import '../services/orders_api_service.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersApiService api;
  OrdersRepositoryImpl({required this.api});

  @override
  Future<List<OrderLine>> getMyOrders() async {
    try {
      final raw = await api.getMyOrdersRaw();
      return raw
          .whereType<Map>()
          .map((m) => OrderLineModel.fromJson(m.cast<String, dynamic>()))
          .map((m) => m.toEntity())
          .toList();
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['error'] != null) {
        throw Exception(data['error'].toString());
      }
      throw Exception(e.message ?? 'Failed to load orders');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
