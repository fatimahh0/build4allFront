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

  static const Object _unset = Object();

  RegisterState copyWith({
    bool? isLoading,
    Object? errorCode = _unset,
    bool? codeSent,
    Object? contact = _unset,
    Object? method = _unset,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      errorCode: identical(errorCode, _unset) ? this.errorCode : errorCode as String?,
      codeSent: codeSent ?? this.codeSent,
      contact: identical(contact, _unset) ? this.contact : contact as String?,
      method: identical(method, _unset) ? this.method : method as RegisterMethod?,
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
