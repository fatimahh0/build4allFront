import '../../domain/entities/tax_rule.dart';
import '../../domain/repositories/tax_repository.dart';
import '../models/tax_rule_model.dart';
import '../services/tax_api_service.dart';

class TaxRepositoryImpl implements TaxRepository {
  final TaxApiService api;
  TaxRepositoryImpl(this.api);

  @override
  Future<List<TaxRule>> listRules({required String authToken}) async {
    final data = await api.listRules(authToken: authToken);
    return data
        .map((e) => TaxRuleModel.fromJson((e as Map).cast<String, dynamic>()))
        .map((m) => m.toEntity())
        .toList();
  }

  @override
  Future<TaxRule> getRule({required int id, required String authToken}) async {
    final data = await api.getRule(id: id, authToken: authToken);
    return TaxRuleModel.fromJson(data).toEntity();
  }

  @override
  Future<TaxRule> createRule({
    required Map<String, dynamic> body,
    required String authToken,
  }) async {
    final data = await api.createRule(body: body, authToken: authToken);
    return TaxRuleModel.fromJson(data).toEntity();
  }

  @override
  Future<TaxRule> updateRule({
    required int id,
    required Map<String, dynamic> body,
    required String authToken,
  }) async {
    final data = await api.updateRule(id: id, body: body, authToken: authToken);
    return TaxRuleModel.fromJson(data).toEntity();
  }

  @override
  Future<void> deleteRule({required int id, required String authToken}) async {
    await api.deleteRule(id: id, authToken: authToken);
  }
}
