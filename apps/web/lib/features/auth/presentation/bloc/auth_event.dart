import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.email, required this.password});
  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.role,
    required this.acceptTerms,
    this.fullName,
  });

  final String email;
  final String password;
  final String role;
  final bool acceptTerms;
  final String? fullName;

  @override
  List<Object?> get props => [email, password, role, acceptTerms, fullName];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthVerifyEmailRequested extends AuthEvent {
  const AuthVerifyEmailRequested(this.token);
  final String token;

  @override
  List<Object?> get props => [token];
}

class AuthForgotPasswordRequested extends AuthEvent {
  const AuthForgotPasswordRequested(this.email);
  final String email;

  @override
  List<Object?> get props => [email];
}

class AuthResetPasswordRequested extends AuthEvent {
  const AuthResetPasswordRequested({
    required this.token,
    required this.password,
  });
  final String token;
  final String password;

  @override
  List<Object?> get props => [token, password];
}

class AuthSessionCleared extends AuthEvent {
  const AuthSessionCleared();
}

class AuthRestoreRequested extends AuthEvent {
  const AuthRestoreRequested();
}
