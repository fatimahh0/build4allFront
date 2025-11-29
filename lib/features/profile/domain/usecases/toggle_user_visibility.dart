import '../repositories/user_profile_repository.dart';

class ToggleUserVisibility {
  final UserProfileRepository repo;
  ToggleUserVisibility(this.repo);

  Future<void> call(String token, bool isPublic) =>
      repo.setVisibility(token: token, isPublic: isPublic);
}
