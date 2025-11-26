import 'package:build4front/features/auth/data/services/auth_api_service.dart';
import 'package:build4front/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/user_entity.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService api;

  AuthRepositoryImpl({required this.api});

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
      return Left(AuthFailure(e.toString()));
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
      return Left(AuthFailure(e.toString()));
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
      return Left(AuthFailure(e.toString()));
    }
  }
}
