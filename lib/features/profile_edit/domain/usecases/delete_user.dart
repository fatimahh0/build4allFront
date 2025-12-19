import '../repositories/user_profile_repository.dart';

class DeleteUser {
  final UserProfileRepository repo;
  DeleteUser(this.repo);

  Future<void> call({
    required String token,
    required int userId,
    required String password,
  }) {
    return repo.deleteUser(token: token, userId: userId, password: password);
  }
}
