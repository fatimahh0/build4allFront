class CountryModel {
  final int id;
  final String iso2Code;
  final String? iso3Code;
  final String name;
  final bool active;

  CountryModel({
    required this.id,
    required this.iso2Code,
    required this.name,
    required this.active,
    this.iso3Code,
  });

  factory CountryModel.fromJson(Map<String, dynamic> j) {
    int toInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

    return CountryModel(
      id: toInt(j['id']),
      iso2Code: (j['iso2Code'] ?? '').toString(),
      iso3Code: j['iso3Code']?.toString(),
      name: (j['name'] ?? '').toString(),
      active: (j['active'] ?? true) == true,
    );
  }
}
