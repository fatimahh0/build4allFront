// lib/features/auth/domain/usecases/verify_phone_code.dart
import 'package:dartz/dartz.dart';

import '../repository/auth_repository.dart';

class VerifyPhoneCode {
  final AuthRepository repo;
  VerifyPhoneCode(this.repo);

  Future<Either<AuthFailure, int>> call({
    required String phoneNumber,
    required String code,
  }) {
    return repo.verifyPhoneCode(phoneNumber: phoneNumber, code: code);
  }
}
