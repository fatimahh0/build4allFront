class RegionModel {
  final int id;
  final String code;
  final String name;
  final bool active;

  final int countryId;
  final String? countryIso2Code;
  final String? countryIso3Code;
  final String? countryName;

  RegionModel({
    required this.id,
    required this.code,
    required this.name,
    required this.active,
    required this.countryId,
    this.countryIso2Code,
    this.countryIso3Code,
    this.countryName,
  });

  factory RegionModel.fromJson(Map<String, dynamic> j) {
    int toInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

    return RegionModel(
      id: toInt(j['id']),
      code: (j['code'] ?? '').toString(),
      name: (j['name'] ?? '').toString(),
      active: (j['active'] ?? true) == true,
      countryId: toInt(j['countryId']),
      countryIso2Code: j['countryIso2Code']?.toString(),
      countryIso3Code: j['countryIso3Code']?.toString(),
      countryName: j['countryName']?.toString(),
    );
  }
}
