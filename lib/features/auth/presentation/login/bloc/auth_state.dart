// lib/features/auth/presentation/bloc/auth_state.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

class AuthState extends Equatable {
  final bool isLoading;
  final Object? error; // <— store the object here
  final UserEntity? user;
  final bool isLoggedIn;
  final String? token;

  const AuthState({
    required this.isLoading,
    required this.error,
    required this.user,
    required this.isLoggedIn,
    required this.token,
  });

  factory AuthState.initial() => const AuthState(
    isLoading: false,
    error: null,
    user: null,
    isLoggedIn: false,
    token: null,
  );

  AuthState copyWith({
    bool? isLoading,
    Object? error, // pass null to clear
    UserEntity? user,
    bool? isLoggedIn,
    String? token,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // override explicitly
      user: user ?? this.user,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      token: token ?? this.token,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, user, isLoggedIn, token];
}
