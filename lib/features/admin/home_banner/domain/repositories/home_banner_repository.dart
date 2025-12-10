import '../entities/home_banner.dart';

abstract class HomeBannerRepository {
  Future<List<HomeBanner>> listActivePublic({
    required int ownerProjectId,
    required String token,
  });

  Future<List<HomeBanner>> listForAdmin({
    required int ownerProjectId,
    required String token,
  });

  Future<HomeBanner> createWithImage({
    required Map<String, dynamic> body,
    required String token,
    required String imagePath,
  });

  Future<HomeBanner> updateWithImage({
    required int id,
    required Map<String, dynamic> body,
    required String token,
    String? imagePath,
  });

  Future<void> delete({required int id, required String token});
}
