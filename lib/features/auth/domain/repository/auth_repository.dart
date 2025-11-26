import 'package:dartz/dartz.dart';

import '../entities/user_entity.dart';


class AuthFailure {
  final String message;
  const AuthFailure(this.message);
}

abstract class AuthRepository {
  /// Register step 1: send verification code (email OR phone)
  Future<Either<AuthFailure, void>> sendVerificationCode({
    String? email,
    String? phoneNumber,
    required String password,
    required int ownerProjectLinkId,
  });


  Future<Either<AuthFailure, int>> verifyEmailCode({
    required String email,
    required String code,
  });

  /// Login (email + password + ownerProjectLinkId)
  Future<Either<AuthFailure, UserEntity>> loginWithEmail({
    required String email,
    required String password,
    required int ownerProjectLinkId,
  });
}
