import 'package:build4front/features/auth/data/services/auth_api_service.dart';
import 'package:build4front/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/user_entity.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService api;

  AuthRepositoryImpl({required this.api});

  /// Normalize error messages coming from Exceptions so the UI
  /// doesn't show "Exception: <message>" but only "<message>".
  String _cleanError(Object e) {
    final raw = e.toString();
    const prefix = 'Exception: ';
    if (raw.startsWith(prefix)) {
      return raw.substring(prefix.length);
    }
    return raw;
  }

  @override
  Future<Either<AuthFailure, void>> sendVerificationCode({
    String? email,
    String? phoneNumber,
    required String password,
    required int ownerProjectLinkId,
  }) async {
    try {
      await api.sendVerificationCode(
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        ownerProjectLinkId: ownerProjectLinkId,
      );
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(_cleanError(e)));
    }
  }

  @override
  Future<Either<AuthFailure, int>> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    try {
      final id = await api.verifyEmailCode(email: email, code: code);
      return Right(id);
    } catch (e) {
      return Left(AuthFailure(_cleanError(e)));
    }
  }

  @override
  Future<Either<AuthFailure, int>> verifyPhoneCode({
    required String phoneNumber,
    required String code,
  }) async {
    try {
      final id = await api.verifyPhoneCode(
        phoneNumber: phoneNumber,
        code: code,
      );
      return Right(id);
    } catch (e) {
      return Left(AuthFailure(_cleanError(e)));
    }
  }

  @override
  Future<Either<AuthFailure, UserEntity>> loginWithEmail({
    required String email,
    required String password,
    required int ownerProjectLinkId,
  }) async {
    try {
      final user = await api.loginWithEmail(
        email: email,
        password: password,
        ownerProjectLinkId: ownerProjectLinkId,
      );
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(_cleanError(e)));
    }
  }

  @override
  Future<Either<AuthFailure, UserEntity>> completeProfile({
    required int pendingId,
    required String username,
    required String firstName,
    required String lastName,
    required bool isPublicProfile,
    required int ownerProjectLinkId,
    String? profileImagePath,
  }) async {
    try {
      final user = await api.completeUserProfile(
        pendingId: pendingId,
        username: username,
        firstName: firstName,
        lastName: lastName,
        isPublicProfile: isPublicProfile,
        ownerProjectLinkId: ownerProjectLinkId,
        profileImagePath: profileImagePath,
      );
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(_cleanError(e)));
    }
  }
}
