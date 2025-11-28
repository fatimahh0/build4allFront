import '../entities/item_summary.dart';
import '../repositories/items_repository.dart';

class GetGuestUpcomingItems {
  final ItemsRepository repo;

  GetGuestUpcomingItems(this.repo);

  Future<List<ItemSummary>> call({int? typeId}) {
    return repo.getGuestUpcoming(typeId: typeId);
  }
}
