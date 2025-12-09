import 'package:build4front/features/admin/tax/domain/repositories/tax_repository.dart';



class DeleteTaxRule {
  final TaxRepository repo;
  DeleteTaxRule(this.repo);

  Future<void> call({required int id, required String authToken}) {
    return repo.deleteRule(id: id, authToken: authToken);
  }
}
