class ExcelValidationResult {
  final bool valid;
  final List<String> errors;
  final List<String> warnings;

  final int categories;
  final int itemTypes;
  final int products;
  final int taxRules;
  final int shippingMethods;
  final int coupons;

  const ExcelValidationResult({
    required this.valid,
    required this.errors,
    required this.warnings,
    required this.categories,
    required this.itemTypes,
    required this.products,
    required this.taxRules,
    required this.shippingMethods,
    required this.coupons,
  });
}
