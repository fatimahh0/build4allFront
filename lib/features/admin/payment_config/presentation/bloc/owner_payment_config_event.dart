abstract class OwnerPaymentConfigEvent {}

class OwnerPaymentConfigLoad extends OwnerPaymentConfigEvent {
  final int ownerProjectId;
  OwnerPaymentConfigLoad(this.ownerProjectId);
}

class OwnerPaymentConfigSave extends OwnerPaymentConfigEvent {
  final int ownerProjectId;
  final String methodName;
  final bool enabled;
  final Map<String, Object?> configValues;

  OwnerPaymentConfigSave({
    required this.ownerProjectId,
    required this.methodName,
    required this.enabled,
    required this.configValues,
  });
}
