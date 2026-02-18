import 'package:build4front/features/admin/tax/domain/entities/tax_rule.dart';
import 'package:build4front/features/admin/tax/domain/repositories/tax_repository.dart';

class ListTaxRules {
  final TaxRepository repo;
  ListTaxRules(this.repo);

  Future<List<TaxRule>> call({required String authToken}) {
    return repo.listRules(authToken: authToken);
  }
}
