// lib/features/auth/domain/repository/auth_repository.dart
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

  /// Register step 2 (phone): verify phone code
  Future<Either<AuthFailure, int>> verifyPhoneCode({
    required String phoneNumber,
    required String code,
  });

  /// Login (identifier = email OR phone + password + ownerProjectLinkId)
  Future<Either<AuthFailure, UserEntity>> loginWithEmail({
    required String email, // this can be email OR phone from UI
    required String password,
    required int ownerProjectLinkId,
  });

  Future<Either<AuthFailure, UserEntity>> completeProfile({
    required int pendingId,
    required String username,
    required String firstName,
    required String lastName,
    required bool isPublicProfile,
    required int ownerProjectLinkId,
    String? profileImagePath, // optional local file path
  });
}
