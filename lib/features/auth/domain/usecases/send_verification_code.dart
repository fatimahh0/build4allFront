import 'package:build4front/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';

class SendVerificationCode {
  final AuthRepository repo;
  SendVerificationCode(this.repo);

  Future<Either<AuthFailure, void>> call({
    String? email,
    String? phoneNumber,
    required String password,
    required int ownerProjectLinkId,
  }) {
    return repo.sendVerificationCode(
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      ownerProjectLinkId: ownerProjectLinkId,
    );
  }
}
