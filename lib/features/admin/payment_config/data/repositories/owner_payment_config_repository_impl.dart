import 'package:build4front/features/admin/payment_config/domain/entities/payment_method_config_item.dart';
import 'package:build4front/features/admin/payment_config/domain/repositories/owner_payment_config_repository.dart';
import 'package:dio/dio.dart';


import '../models/payment_method_config_item_model.dart';
import '../services/owner_payment_config_api_service.dart';

typedef TokenProvider = Future<String> Function();

class OwnerPaymentConfigRepositoryImpl implements OwnerPaymentConfigRepository {
  final OwnerPaymentConfigApiService api;
  final TokenProvider tokenProvider;

  OwnerPaymentConfigRepositoryImpl({
    required this.api,
    required this.tokenProvider,
  });

  @override
  Future<List<PaymentMethodConfigItem>> listMethods({
    required int ownerProjectId,
  }) async {
    final token = await tokenProvider();
    final list = await api.listMethods(
      token: token,
      ownerProjectId: ownerProjectId,
    );

    return list
        .whereType<Map>()
        .map(
          (e) => PaymentMethodConfigItemModel.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  @override
  Future<void> saveMethodConfig({
    required int ownerProjectId,
    required String methodName,
    required bool enabled,
    required Map<String, Object?> configValues,
  }) async {
    final token = await tokenProvider();
    await api.saveMethodConfig(
      token: token,
      ownerProjectId: ownerProjectId,
      methodName: methodName,
      enabled: enabled,
      configValues: configValues,
    );
  }
}
