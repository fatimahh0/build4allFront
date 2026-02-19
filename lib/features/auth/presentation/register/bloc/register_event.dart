import 'package:equatable/equatable.dart';

enum RegisterMethod { email, phone }

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

class RegisterSendCodeSubmitted extends RegisterEvent {
  final RegisterMethod method;
  final String? email;
  final String? phoneNumber;
  final String password;

  const RegisterSendCodeSubmitted({
    required this.method,
    this.email,
    this.phoneNumber,
    required this.password,
  });

  @override
  List<Object?> get props => [method, email, phoneNumber, password];
}
