// lib/features/auth/domain/usecases/complete_user_profile.dart
import 'package:dartz/dartz.dart';

import '../entities/user_entity.dart';
import '../repository/auth_repository.dart';

class CompleteUserProfile {
  final AuthRepository repo;
  CompleteUserProfile(this.repo);

  Future<Either<AuthFailure, UserEntity>> call({
    required int pendingId,
    required String username,
    required String firstName,
    required String lastName,
    required bool isPublicProfile,
    required int ownerProjectLinkId,
    String? profileImagePath,
  }) {
    return repo.completeProfile(
      pendingId: pendingId,
      username: username,
      firstName: firstName,
      lastName: lastName,
      isPublicProfile: isPublicProfile,
      ownerProjectLinkId: ownerProjectLinkId,
      profileImagePath: profileImagePath,
    );
  }
}
