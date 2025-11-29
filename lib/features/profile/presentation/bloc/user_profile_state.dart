import 'package:build4front/features/auth/domain/entities/user_entity.dart';

abstract class UserProfileState {
  const UserProfileState();
}

class UserProfileLoading extends UserProfileState {
  const UserProfileLoading();
}

class UserProfileError extends UserProfileState {
  final String message;
  const UserProfileError(this.message);
}

class UserProfileLoaded extends UserProfileState {
  final UserEntity user;
  const UserProfileLoaded(this.user);

  UserProfileLoaded copyWith({UserEntity? user}) =>
      UserProfileLoaded(user ?? this.user);
}
