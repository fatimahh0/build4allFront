class ExcelImportResult {
  final bool success;
  final String message;

  final int projectId;
  final int ownerProjectId;
  final String slug;

  final int insertedCategories;
  final int insertedItemTypes;
  final int insertedProducts;
  final int insertedTaxRules;
  final int insertedShippingMethods;
  final int insertedCoupons;

  final List<String> errors;
  final List<String> warnings;

  const ExcelImportResult({
    required this.success,
    required this.message,
    required this.projectId,
    required this.ownerProjectId,
    required this.slug,
    required this.insertedCategories,
    required this.insertedItemTypes,
    required this.insertedProducts,
    required this.insertedTaxRules,
    required this.insertedShippingMethods,
    required this.insertedCoupons,
    required this.errors,
    required this.warnings,
  });
}
