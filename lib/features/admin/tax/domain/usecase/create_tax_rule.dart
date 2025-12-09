
import 'package:build4front/features/admin/tax/domain/entities/tax_rule.dart';
import 'package:build4front/features/admin/tax/domain/repositories/tax_repository.dart';

class CreateTaxRule {
  final TaxRepository repo;
  CreateTaxRule(this.repo);

  Future<TaxRule> call({
    required Map<String, dynamic> body,
    required String authToken,
  }) {
    return repo.createRule(body: body, authToken: authToken);
  }
}
