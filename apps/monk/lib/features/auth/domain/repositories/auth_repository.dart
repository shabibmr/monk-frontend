import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> register({
    required String email,
    required String password,
    required String role,
    required bool acceptTerms,
    String? fullName,
  });

  Future<AuthSession> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<User> verifyEmail({required String token});

  Future<void> resendVerification({required String email});

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({
    required String token,
    required String password,
  });

  Future<List<DeviceSession>> listSessions();

  Future<void> revokeSession(String sessionId);

  Future<bool> healthCheck();

  /// Restores session from stored tokens via GET /users/me.
  Future<User?> restoreSession();
}
