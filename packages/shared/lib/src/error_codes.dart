/// Canonical API error codes — mirrors backend ErrorCode.
abstract final class ErrorCode {
  static const internalError = 'INTERNAL_ERROR';
  static const validationError = 'VALIDATION_ERROR';
  static const unauthorized = 'UNAUTHORIZED';
  static const forbidden = 'FORBIDDEN';
  static const notFound = 'NOT_FOUND';
  static const conflict = 'CONFLICT';
  static const rateLimited = 'RATE_LIMITED';
  static const invalidStateTransition = 'INVALID_STATE_TRANSITION';
  static const serviceUnavailable = 'SERVICE_UNAVAILABLE';
  static const badRequest = 'BAD_REQUEST';
  static const emailNotVerified = 'EMAIL_NOT_VERIFIED';
  static const invalidCredentials = 'INVALID_CREDENTIALS';
  static const tokenInvalid = 'TOKEN_INVALID';
  static const tokenExpired = 'TOKEN_EXPIRED';
  static const tokenReuseDetected = 'TOKEN_REUSE_DETECTED';
  static const accountSuspended = 'ACCOUNT_SUSPENDED';
  static const tcRequired = 'TC_REQUIRED';
}
