import 'package:api_client/api_client.dart';
import 'package:dio/dio.dart';
import 'package:monk_shared/monk_shared.dart';

import '../errors/failures.dart';

Failure mapError(Object error) {
  if (error is Failure) return error;

  if (error is DioException) {
    final api = error.error;
    if (api is ApiException) {
      return _fromEnvelope(api.envelope);
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const NetworkFailure(
        'Could not reach the server. Check your connection and try again.',
      );
    }
    final status = error.response?.statusCode;
    if (status == 429) {
      return const NetworkFailure(
        'Too many attempts — wait a moment and try again.',
        errorCode: ErrorCode.rateLimited,
      );
    }
    final data = error.response?.data;
    if (data is Map<String, dynamic> && data['errorCode'] != null) {
      return _fromEnvelope(ErrorEnvelope.fromJson(data));
    }
    if (status != null && status >= 500) {
      return ServerFailure(
        error.message ?? 'Server error',
        errorCode: ErrorCode.internalError,
      );
    }
    return NetworkFailure(
      error.message ?? 'Network error',
      errorCode: ErrorCode.serviceUnavailable,
    );
  }

  if (error is ApiException) {
    return _fromEnvelope(error.envelope);
  }

  return UnexpectedFailure(error.toString());
}

Failure _fromEnvelope(ErrorEnvelope e) {
  switch (e.errorCode) {
    case ErrorCode.unauthorized:
    case ErrorCode.invalidCredentials:
    case ErrorCode.tokenInvalid:
    case ErrorCode.tokenExpired:
    case ErrorCode.tokenReuseDetected:
    case ErrorCode.emailNotVerified:
    case ErrorCode.accountSuspended:
      return AuthFailure(e.message, errorCode: e.errorCode, details: e.details);
    case ErrorCode.validationError:
    case ErrorCode.badRequest:
    case ErrorCode.tcRequired:
      return ValidationFailure(
        e.message,
        errorCode: e.errorCode,
        details: e.details,
      );
    case ErrorCode.forbidden:
      return ForbiddenFailure(
        e.message,
        errorCode: e.errorCode,
        details: e.details,
      );
    case ErrorCode.notFound:
      return NotFoundFailure(
        e.message,
        errorCode: e.errorCode,
        details: e.details,
      );
    case ErrorCode.conflict:
      return ConflictFailure(
        e.message,
        errorCode: e.errorCode,
        details: e.details,
      );
    case ErrorCode.rateLimited:
      return const NetworkFailure(
        'Too many attempts — try again later.',
        errorCode: ErrorCode.rateLimited,
      );
    default:
      if (e.statusCode >= 500) {
        return ServerFailure(
          e.message,
          errorCode: e.errorCode,
          details: e.details,
        );
      }
      return UnexpectedFailure(
        e.message,
        errorCode: e.errorCode,
        details: e.details,
      );
  }
}
