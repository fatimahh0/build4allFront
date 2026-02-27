// lib/features/profile_edit/domain/usecases/verify_email_change.dart
import '../repositories/user_profile_repository.dart';

class VerifyEmailChange {
  final UserProfileRepository repo;
  VerifyEmailChange(this.repo);

  Future<void> call({
    required String token,
    required int userId,
    required int ownerProjectLinkId,
    required String code,
  }) {
    return repo.verifyEmailChange(
      token: token,
      userId: userId,
      ownerProjectLinkId: ownerProjectLinkId,
      code: code,
    );
  }
}