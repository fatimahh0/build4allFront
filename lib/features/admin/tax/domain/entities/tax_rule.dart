import 'package:equatable/equatable.dart';

class TaxRule extends Equatable {
  final int id;
  final int ownerProjectId;
  final String name;
  final double rate; // 11.0 means 11%
  final bool appliesToShipping;
  final int? countryId;
  final int? regionId;
  final bool enabled;

  const TaxRule({
    required this.id,
    required this.ownerProjectId,
    required this.name,
    required this.rate,
    required this.appliesToShipping,
    this.countryId,
    this.regionId,
    required this.enabled,
  });

  @override
  List<Object?> get props => [
    id,
    ownerProjectId,
    name,
    rate,
    appliesToShipping,
    countryId,
    regionId,
    enabled,
  ];
}
