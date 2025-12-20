import '../entities/payment_method_config_item.dart';

abstract class OwnerPaymentConfigRepository {
  Future<List<PaymentMethodConfigItem>> listMethods({
    required int ownerProjectId,
  });

  Future<void> saveMethodConfig({
    required int ownerProjectId,
    required String methodName,
    required bool enabled,
    required Map<String, Object?> configValues,
  });
}
