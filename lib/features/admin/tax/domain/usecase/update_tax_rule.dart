import 'package:build4front/features/admin/tax/domain/entities/tax_rule.dart';
import 'package:build4front/features/admin/tax/domain/repositories/tax_repository.dart';



class UpdateTaxRule {
  final TaxRepository repo;
  UpdateTaxRule(this.repo);

  Future<TaxRule> call({
    required int id,
    required Map<String, dynamic> body,
    required String authToken,
  }) {
    return repo.updateRule(id: id, body: body, authToken: authToken);
  }
}
