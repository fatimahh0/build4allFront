import 'package:build4front/features/auth/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final UserEntity? user;
  final bool isLoggedIn;
  final String? token; // NEW

  const AuthState({
    required this.isLoading,
    required this.errorMessage,
    required this.user,
    required this.isLoggedIn,
    required this.token,
  });

  factory AuthState.initial() {
    return const AuthState(
      isLoading: false,
      errorMessage: null,
      user: null,
      isLoggedIn: false,
      token: null,
    );
  }

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    UserEntity? user,
    bool? isLoggedIn,
    String? token, // NEW
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      user: user ?? this.user,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      token: token ?? this.token,
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, user, isLoggedIn, token];
}
