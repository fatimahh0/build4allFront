import '../../domain/entities/shipping_method.dart';

class ShippingMethodModel extends ShippingMethod {
  const ShippingMethodModel({
    required super.id,
    required super.ownerProjectId,
    required super.name,
    required super.methodType,
    required super.flatRate,
    required super.pricePerKg,
    required super.enabled,
    super.description,
    super.freeShippingThreshold,
    super.countryId,
    super.regionId,
  });

  factory ShippingMethodModel.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return ShippingMethodModel(
      id: (json['id'] ?? 0) as int,
      ownerProjectId: (json['ownerProjectId'] ?? 0) as int,
      name: (json['name'] ?? '') as String,
      description: json['description'] as String?,
      methodType: (json['methodType'] ?? 'FLAT_RATE') as String,
      flatRate: _toDouble(json['flatRate']),
      pricePerKg: _toDouble(json['pricePerKg']),
      freeShippingThreshold: json['freeShippingThreshold'] == null
          ? null
          : _toDouble(json['freeShippingThreshold']),
      enabled: (json['enabled'] ?? true) as bool,
      countryId: json['countryId'] as int?,
      regionId: json['regionId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerProjectId': ownerProjectId,
      'name': name,
      'description': description,
      'methodType': methodType,
      'flatRate': flatRate,
      'pricePerKg': pricePerKg,
      'freeShippingThreshold': freeShippingThreshold,
      'enabled': enabled,
      'countryId': countryId,
      'regionId': regionId,
    };
  }
}
