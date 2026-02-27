// lib/features/profile_edit/domain/usecases/resend_email_change.dart
import '../repositories/user_profile_repository.dart';

class ResendEmailChange {
  final UserProfileRepository repo;
  ResendEmailChange(this.repo);

  Future<void> call({
    required String token,
    required int userId,
    required int ownerProjectLinkId,
  }) {
    return repo.resendEmailChange(
      token: token,
      userId: userId,
      ownerProjectLinkId: ownerProjectLinkId,
    );
  }
}