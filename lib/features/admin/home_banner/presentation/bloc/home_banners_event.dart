abstract class HomeBannersEvent {}

class LoadAdminBanners extends HomeBannersEvent {
  final int ownerProjectId;
  final String token;
  LoadAdminBanners({required this.ownerProjectId, required this.token});
}

class CreateBannerEvent extends HomeBannersEvent {
  final Map<String, dynamic> body;
  final String imagePath;
  final String token;
  final int ownerProjectId;

  CreateBannerEvent({
    required this.body,
    required this.imagePath,
    required this.token,
    required this.ownerProjectId,
  });
}

class UpdateBannerEvent extends HomeBannersEvent {
  final int id;
  final Map<String, dynamic> body;
  final String? imagePath;
  final String token;
  final int ownerProjectId;

  UpdateBannerEvent({
    required this.id,
    required this.body,
    required this.token,
    required this.ownerProjectId,
    this.imagePath,
  });
}

class DeleteBannerEvent extends HomeBannersEvent {
  final int id;
  final String token;
  final int ownerProjectId;

  DeleteBannerEvent({
    required this.id,
    required this.token,
    required this.ownerProjectId,
  });
}
