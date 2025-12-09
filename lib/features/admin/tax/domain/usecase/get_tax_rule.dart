import 'package:build4front/features/admin/tax/domain/entities/tax_rule.dart';
import 'package:build4front/features/admin/tax/domain/repositories/tax_repository.dart';


class GetTaxRule {
  final TaxRepository repo;
  GetTaxRule(this.repo);

  Future<TaxRule> call({required int id, required String authToken}) {
    return repo.getRule(id: id, authToken: authToken);
  }
}
