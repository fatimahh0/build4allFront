import '../entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<UserProfile> getById({
    required String token,
    required int userId,
    required int ownerProjectLinkId,
  });

  Future<UserProfile> updateProfile({
    required String token,
    required int userId,
    required int ownerProjectLinkId,
    required String firstName,
    required String lastName,
    String? username,
    bool? isPublicProfile,
    String? imageFilePath,
    bool imageRemoved = false,
  });

  Future<void> deleteUser({
    required String token,
    required int userId,
    required String password,
  });
}
