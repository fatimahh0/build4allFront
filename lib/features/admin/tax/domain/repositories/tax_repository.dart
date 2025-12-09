import '../entities/tax_rule.dart';

abstract class TaxRepository {
  Future<List<TaxRule>> listRules({
    required int ownerProjectId,
    required String authToken,
  });

  Future<TaxRule> getRule({required int id, required String authToken});

  Future<TaxRule> createRule({
    required Map<String, dynamic> body,
    required String authToken,
  });

  Future<TaxRule> updateRule({
    required int id,
    required Map<String, dynamic> body,
    required String authToken,
  });

  Future<void> deleteRule({required int id, required String authToken});
}
