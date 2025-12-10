class ShippingMethod {
  final int id;
  final int ownerProjectId;
  final String name;
  final String? description;
  final String methodType;

  final double flatRate;
  final double pricePerKg;
  final double? freeShippingThreshold;

  final bool enabled;

  final int? countryId;
  final int? regionId;

  const ShippingMethod({
    required this.id,
    required this.ownerProjectId,
    required this.name,
    required this.methodType,
    required this.flatRate,
    required this.pricePerKg,
    required this.enabled,
    this.description,
    this.freeShippingThreshold,
    this.countryId,
    this.regionId,
  });
}
