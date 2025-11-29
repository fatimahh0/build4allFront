// lib/features/auth/domain/usecases/login_with_email.dart
import 'package:build4front/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';
import '../../data/services/auth_api_service.dart';

import '../entities/user_entity.dart';

class LoginWithEmail {
  final AuthRepository repository;
  final AuthApiService authApi;

  LoginWithEmail(this.repository, this.authApi);

  Future<UserEntity> call({
    required String email,
    required String password,
    required int ownerProjectLinkId,
  }) {
    return repository.loginWithEmail(
      email: email,
      password: password,
      ownerProjectLinkId: ownerProjectLinkId,
    );
  }
}

