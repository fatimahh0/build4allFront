import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

/// Base class for all auth events.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Classic login event (email + password) when using the direct login usecase.
class AuthLoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginSubmitted({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Used when login has already been performed externally
/// (e.g. DualLoginOrchestrator) and we just want to
/// hydrate the AuthBloc with user + token + wasInactive flag.
class AuthLoginHydrated extends AuthEvent {
  final UserEntity? user;
  final String token;
  final bool wasInactive;

  const AuthLoginHydrated({
    required this.user,
    required this.token,
    required this.wasInactive,
  });

  @override
  List<Object?> get props => [user, token, wasInactive];
}

/// ✅ NEW: Patch current logged-in user info (for instant UI updates)
/// We use it after profile edit to update header name/avatar everywhere.
class AuthUserPatched extends AuthEvent {
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? profilePictureUrl;
  final bool? isPublicProfile;
  final String? status;

  const AuthUserPatched({
    this.firstName,
    this.lastName,
    this.username,
    this.profilePictureUrl,
    this.isPublicProfile,
    this.status,
  });

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    username,
    profilePictureUrl,
    isPublicProfile,
    status,
  ];
}

/// Clear the auth state (e.g. on logout, or when user cancels reactivation).
class AuthLoggedOut extends AuthEvent {
  const AuthLoggedOut();
}
