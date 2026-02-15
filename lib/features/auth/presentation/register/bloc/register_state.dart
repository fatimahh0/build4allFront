import 'package:equatable/equatable.dart';
import 'register_event.dart';

class RegisterState extends Equatable {
  final bool isLoading;

  /// ✅ UI will localize this via l10n (NO raw messages shown to user)
  final String? errorCode;

  final bool codeSent;
  final String? contact; // email OR phone
  final RegisterMethod? method;

  const RegisterState({
    required this.isLoading,
    required this.errorCode,
    required this.codeSent,
    required this.contact,
    required this.method,
  });

  factory RegisterState.initial() {
    return const RegisterState(
      isLoading: false,
      errorCode: null,
      codeSent: false,
      contact: null,
      method: null,
    );
  }

  RegisterState copyWith({
    bool? isLoading,
    String? errorCode,
    bool clearErrorCode = false,
    bool? codeSent,
    String? contact,
    RegisterMethod? method,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      errorCode: clearErrorCode ? null : (errorCode ?? this.errorCode),
      codeSent: codeSent ?? this.codeSent,
      contact: contact ?? this.contact,
      method: method ?? this.method,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorCode,
        codeSent,
        contact,
        method,
      ];
}
