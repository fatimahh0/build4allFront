import '../entities/currency.dart';

abstract class CurrencyRepository {
  Future<Currency> getById(int id);
}
