import '../../domain/entities/tax_rule.dart';

class TaxRuleModel {
  final int id;
  final int ownerProjectId;
  final String name;
  final double rate;
  final bool appliesToShipping;
  final int? countryId;
  final int? regionId;
  final bool enabled;

  TaxRuleModel({
    required this.id,
    required this.ownerProjectId,
    required this.name,
    required this.rate,
    required this.appliesToShipping,
    this.countryId,
    this.regionId,
    required this.enabled,
  });

  factory TaxRuleModel.fromJson(Map<String, dynamic> j) {
    int toInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;
    double toDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse('$v') ?? 0;

    // Support both possible response shapes:
    // 1) countryId/regionId
    // 2) nested country/region objects
    final nestedCountry = j['country'];
    final nestedRegion = j['region'];

    final countryId = j['countryId'] != null
        ? toInt(j['countryId'])
        : (nestedCountry is Map ? toInt(nestedCountry['id']) : null);

    final regionId = j['regionId'] != null
        ? toInt(j['regionId'])
        : (nestedRegion is Map ? toInt(nestedRegion['id']) : null);

    return TaxRuleModel(
      id: toInt(j['id']),
      ownerProjectId: toInt(j['ownerProjectId']),
      name: (j['name'] ?? '').toString(),
      rate: toDouble(j['rate']),
      appliesToShipping: (j['appliesToShipping'] ?? false) == true,
      countryId: countryId,
      regionId: regionId,
      enabled: (j['enabled'] ?? true) == true,
    );
  }

  TaxRule toEntity() => TaxRule(
    id: id,
    ownerProjectId: ownerProjectId,
    name: name,
    rate: rate,
    appliesToShipping: appliesToShipping,
    countryId: countryId,
    regionId: regionId,
    enabled: enabled,
  );
}
