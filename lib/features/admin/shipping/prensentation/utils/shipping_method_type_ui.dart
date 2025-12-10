import 'package:build4front/l10n/app_localizations.dart';

enum ShippingMethodTypeUi {
  flatRate('FLAT_RATE'),
  free('FREE'),
  weightBased('WEIGHT_BASED'),
  priceBased('PRICE_BASED'),
  pricePerKg('PRICE_PER_KG'),
  localPickup('LOCAL_PICKUP'),
  freeOverThreshold('FREE_OVER_THRESHOLD');

  final String apiName;
  const ShippingMethodTypeUi(this.apiName);

  String label(AppLocalizations l) {
    switch (this) {
      case ShippingMethodTypeUi.flatRate:
        return l.shippingTypeFlatRate ?? 'Flat rate';
      case ShippingMethodTypeUi.free:
        return l.shippingTypeFree ?? 'Free';
      case ShippingMethodTypeUi.weightBased:
        return l.shippingTypeWeightBased ?? 'Weight based';
      case ShippingMethodTypeUi.priceBased:
        return l.shippingTypePriceBased ?? 'Price based';
      case ShippingMethodTypeUi.pricePerKg:
        return l.shippingTypePricePerKg ?? 'Price per kg';
      case ShippingMethodTypeUi.localPickup:
        return l.shippingTypeLocalPickup ?? 'Local pickup';
      case ShippingMethodTypeUi.freeOverThreshold:
        return l.shippingTypeFreeOverThreshold ?? 'Free over threshold';
    }
  }

  static ShippingMethodTypeUi? fromApi(String? v) {
    if (v == null) return null;
    final upper = v.toUpperCase();
    for (final e in values) {
      if (e.apiName == upper) return e;
    }
    return null;
  }
}
