// lib/features/auth/presentation/bloc/register_state.dart
import 'package:equatable/equatable.dart';

import 'register_event.dart';

class RegisterState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final bool codeSent;
  final String? contact; // email OR phone
  final RegisterMethod? method;

  const RegisterState({
    required this.isLoading,
    required this.errorMessage,
    required this.codeSent,
    required this.contact,
    required this.method,
  });

  factory RegisterState.initial() {
    return const RegisterState(
      isLoading: false,
      errorMessage: null,
      codeSent: false,
      contact: null,
      method: null,
    );
  }

  RegisterState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? codeSent,
    String? contact,
    RegisterMethod? method,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      codeSent: codeSent ?? this.codeSent,
      contact: contact ?? this.contact,
      method: method ?? this.method,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    codeSent,
    contact,
    method,
  ];
}
