import 'package:build4front/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';


class LoginWithEmail {
  final AuthRepository repo;
  LoginWithEmail(this.repo);

  Future<Either<AuthFailure, UserEntity>> call({
    required String email,
    required String password,
    required int ownerProjectLinkId,
  }) {
    return repo.loginWithEmail(
      email: email,
      password: password,
      ownerProjectLinkId: ownerProjectLinkId,
    );
  }
}
