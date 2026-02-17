import '../../domain/entities/currency.dart';
import '../../domain/repositories/currency_repository.dart';
import '../models/currency_model.dart';
import '../services/currency_api_service.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final CurrencyApiService api;
  final Future<String?> Function() getToken;

  CurrencyRepositoryImpl({
    required this.api,
    required this.getToken,
  });

  @override
  Future<Currency> getById(int id) async {
    final token = (await getToken())?.trim();
    final json = await api.getCurrencyById(id, authToken: token);
    return CurrencyModel.fromJson(json).toEntity();
  }
}
