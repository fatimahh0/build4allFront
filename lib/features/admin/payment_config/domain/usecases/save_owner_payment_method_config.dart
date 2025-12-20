import '../repositories/owner_payment_config_repository.dart';

class SaveOwnerPaymentMethodConfig {
  final OwnerPaymentConfigRepository repo;
  SaveOwnerPaymentMethodConfig(this.repo);

  Future<void> call({
    required int ownerProjectId,
    required String methodName,
    required bool enabled,
    required Map<String, Object?> configValues,
  }) {
    return repo.saveMethodConfig(
      ownerProjectId: ownerProjectId,
      methodName: methodName,
      enabled: enabled,
      configValues: configValues,
    );
  }
}
