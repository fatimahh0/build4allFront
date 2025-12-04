import '../../domain/entities/currency.dart';
import '../../domain/repositories/currency_repository.dart';
import '../models/currency_model.dart';
import '../services/currency_api_service.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final CurrencyApiService api;

  CurrencyRepositoryImpl({required this.api});

  @override
  Future<Currency> getById(int id) async {
    final json = await api.getCurrencyById(id);
    return CurrencyModel.fromJson(json).toEntity();
  }
}
