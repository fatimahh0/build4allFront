// lib/features/auth/presentation/bloc/auth_state.dart

import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

/// Global authentication state used by the app.
///
/// - [isLoading]: true while a login / auth action is in progress.
/// - [error]: last error thrown (exception or message).
/// - [user]: currently authenticated user (for user-side login).
/// - [isLoggedIn]: true if we have a logged-in user.
/// - [token]: current JWT token for the user.
/// - [wasInactive]: true if the last login response came from an INACTIVE account
///   (backend returned wasInactive = true).
class AuthState extends Equatable {
  final bool isLoading;
  final Object? error;
  final UserEntity? user;
  final bool isLoggedIn;
  final String? token;
  final bool wasInactive;

  const AuthState({
    required this.isLoading,
    required this.error,
    required this.user,
    required this.isLoggedIn,
    required this.token,
    required this.wasInactive,
  });

  factory AuthState.initial() => const AuthState(
    isLoading: false,
    error: null,
    user: null,
    isLoggedIn: false,
    token: null,
    wasInactive: false,
  );

  AuthState copyWith({
    bool? isLoading,
    Object? error, // pass null to clear
    UserEntity? user,
    bool? isLoggedIn,
    String? token,
    bool? wasInactive,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      // error is overridden directly, so passing null clears it
      error: error,
      user: user ?? this.user,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      token: token ?? this.token,
      wasInactive: wasInactive ?? this.wasInactive,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    error,
    user,
    isLoggedIn,
    token,
    wasInactive,
  ];
}
