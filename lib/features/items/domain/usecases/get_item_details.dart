import '../entities/item_details.dart';
import '../repositories/items_repository.dart';

class GetItemDetails {
  final ItemsRepository repo;
  GetItemDetails(this.repo);

  Future<ItemDetails> call(int id, {String? token}) {
    return repo.getDetails(id, token: token);
  }
}
