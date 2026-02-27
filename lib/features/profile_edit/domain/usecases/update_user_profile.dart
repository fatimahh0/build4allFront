import '../entities/user_profile.dart';
import '../repositories/user_profile_repository.dart';

class UpdateUserProfile {
  final UserProfileRepository repo;
  UpdateUserProfile(this.repo);

Future<UserProfile> call({
  required String token,
  required int userId,
  required int ownerProjectLinkId,
  required String firstName,
  required String lastName,
  String? username,
  String? email, // ✅ NEW
  bool? isPublicProfile,
  String? imageFilePath,
  bool imageRemoved = false,
}) {
  return repo.updateProfile(
    token: token,
    userId: userId,
    ownerProjectLinkId: ownerProjectLinkId,
    firstName: firstName,
    lastName: lastName,
    username: username,
    email: email, // ✅ NEW
    isPublicProfile: isPublicProfile,
    imageFilePath: imageFilePath,
    imageRemoved: imageRemoved,
  );
}
}
