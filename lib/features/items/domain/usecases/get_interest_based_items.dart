import '../entities/item_summary.dart';
import '../repositories/items_repository.dart';

class GetInterestBasedItems {
  final ItemsRepository repo;

  GetInterestBasedItems(this.repo);

  Future<List<ItemSummary>> call({required int userId, required String token}) {
    return repo.getInterestBased(userId: userId, token: token);
  }
}
