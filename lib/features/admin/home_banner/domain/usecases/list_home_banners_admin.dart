import '../entities/home_banner.dart';
import '../repositories/home_banner_repository.dart';

class ListHomeBannersAdmin {
  final HomeBannerRepository repo;
  ListHomeBannersAdmin(this.repo);

  Future<List<HomeBanner>> call({
    required int ownerProjectId,
    required String token,
  }) {
    return repo.listForAdmin(ownerProjectId: ownerProjectId, token: token);
  }
}
