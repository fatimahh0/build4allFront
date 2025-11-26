import 'package:build4front/features/auth/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final UserEntity? user;
  final bool isLoggedIn;

  const AuthState({
    required this.isLoading,
    required this.errorMessage,
    required this.user,
    required this.isLoggedIn,
  });

  factory AuthState.initial() {
    return const AuthState(
      isLoading: false,
      errorMessage: null,
      user: null,
      isLoggedIn: false,
    );
  }

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    UserEntity? user,
    bool? isLoggedIn,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      user: user ?? this.user,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, user, isLoggedIn];
}
