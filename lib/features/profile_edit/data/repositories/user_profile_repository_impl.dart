import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../models/user_profile_model.dart';
import '../services/user_profile_api_service.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileApiService api;
  UserProfileRepositoryImpl(this.api);

  @override
  Future<UserProfile> getById({
    required String token,
    required int userId,
    required int ownerProjectLinkId,
  }) async {
    final json = await api.getUserById(
      token: token,
      userId: userId,
      ownerProjectLinkId: ownerProjectLinkId,
    );
    return UserProfileModel.fromJson(json);
  }

  @override
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
  }) async {
    final json = await api.updateProfile(
      token: token,
      userId: userId,
      ownerProjectLinkId: ownerProjectLinkId,
      firstName: firstName,
      lastName: lastName,
      username: username,
      isPublicProfile: isPublicProfile,
      imageFilePath: imageFilePath,
      imageRemoved: imageRemoved,
    );

    final userJson = (json['user'] is Map)
        ? (json['user'] as Map).cast<String, dynamic>()
        : (json as Map).cast<String, dynamic>();

    return UserProfileModel.fromJson(userJson);
  }

  @override
  Future<void> deleteUser({
    required String token,
    required int userId,
    required String password,
  }) {
    return api.deleteUser(token: token, userId: userId, password: password);
  }
}
