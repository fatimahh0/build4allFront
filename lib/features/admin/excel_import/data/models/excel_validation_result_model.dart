class ExcelValidationResultModel {
  final bool valid;
  final List<String> errors;
  final List<String> warnings;

  final int categories;
  final int itemTypes;
  final int products;
  final int taxRules;
  final int shippingMethods;
  final int coupons;

  ExcelValidationResultModel({
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

  factory ExcelValidationResultModel.fromJson(Map<String, dynamic> json) {
    List<String> _list(String k) {
      final v = json[k];
      if (v is List) return v.map((e) => e.toString()).toList();
      return const [];
    }

    int _i(String k) => (json[k] is num) ? (json[k] as num).toInt() : 0;

    return ExcelValidationResultModel(
      valid: json['valid'] == true,
      errors: _list('errors'),
      warnings: _list('warnings'),
      categories: _i('categories'),
      itemTypes: _i('itemTypes'),
      products: _i('products'),
      taxRules: _i('taxRules'),
      shippingMethods: _i('shippingMethods'),
      coupons: _i('coupons'),
    );
  }
}
