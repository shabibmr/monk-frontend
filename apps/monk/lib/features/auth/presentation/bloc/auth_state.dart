import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
  loading,
  failure,
  message,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.failure,
    this.infoMessage,
  });

  final AuthStatus status;
  final User? user;
  final Failure? failure;
  final String? infoMessage;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    Failure? failure,
    String? infoMessage,
    bool clearFailure = false,
    bool clearUser = false,
    bool clearMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      failure: clearFailure ? null : (failure ?? this.failure),
      infoMessage: clearMessage ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props => [status, user, failure, infoMessage];
}
