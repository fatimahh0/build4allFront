import 'package:build4front/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';


class VerifyEmailCode {
  final AuthRepository repo;
  VerifyEmailCode(this.repo);

  Future<Either<AuthFailure, int>> call({
    required String email,
    required String code,
  }) {
    return repo.verifyEmailCode(email: email, code: code);
  }
}
