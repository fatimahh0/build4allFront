import 'package:build4front/features/auth/domain/entities/user_entity.dart';

abstract class UserProfileRepository {
  Future<UserEntity> getProfile({
    required String token,
    required int userId,
    required int ownerProjectLinkId,
  });

  Future<void> setVisibility({
    required String token,
    required int userId,
    required bool isPublic,
    required int ownerProjectLinkId,
  });

  Future<void> setStatus({
    required String token,
    required int userId,
    required String status,
    required int ownerProjectLinkId,
    String? password,
  });
}
