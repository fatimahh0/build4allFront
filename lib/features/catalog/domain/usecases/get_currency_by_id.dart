import '../entities/currency.dart';
import '../repositories/currency_repository.dart';

class GetCurrencyById {
  final CurrencyRepository repo;

  GetCurrencyById(this.repo);

  Future<Currency> call(int id) {
    return repo.getById(id);
  }
}
