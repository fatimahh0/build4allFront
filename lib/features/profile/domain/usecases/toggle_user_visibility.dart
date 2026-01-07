import '../repositories/user_profile_repository.dart';

class ToggleUserVisibility {
  final UserProfileRepository repo;
  ToggleUserVisibility(this.repo);

  Future<void> call({
    required String token,
    required int userId,
    required bool isPublic,
    required int ownerProjectLinkId,
  }) {
    return repo.setVisibility(
      token: token,
      userId: userId,
      isPublic: isPublic,
      ownerProjectLinkId: ownerProjectLinkId,
    );
  }
}
