import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.message, {this.errorCode, this.details});

  final String message;
  final String? errorCode;
  final Object? details;

  @override
  List<Object?> get props => [message, errorCode, details];
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.errorCode, super.details});
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.errorCode, super.details});
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.errorCode, super.details});
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure(super.message, {super.errorCode, super.details});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.errorCode, super.details});
}

class ConflictFailure extends Failure {
  const ConflictFailure(super.message, {super.errorCode, super.details});
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.errorCode, super.details});
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message, {super.errorCode, super.details});
}
