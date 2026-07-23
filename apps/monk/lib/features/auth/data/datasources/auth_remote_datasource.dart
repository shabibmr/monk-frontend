import 'package:api_client/api_client.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);
  final MonkApiClient _client;

  Future<RegisterResponseDto> register({
    required String email,
    required String password,
    required String role,
    required bool acceptTerms,
    String? fullName,
  }) {
    return _client.auth.register(
      email: email,
      password: password,
      role: role,
      acceptTerms: acceptTerms,
      fullName: fullName,
    );
  }

  Future<LoginResponseDto> login({
    required String email,
    required String password,
  }) {
    return _client.auth.login(email: email, password: password);
  }

  Future<void> logout() => _client.auth.logout();

  Future<PublicUserDto> verifyEmail(String token) =>
      _client.auth.verifyEmail(token: token);

  Future<void> resendVerification(String email) =>
      _client.auth.resendVerification(email: email);

  Future<void> forgotPassword(String email) =>
      _client.auth.forgotPassword(email: email);

  Future<void> resetPassword({
    required String token,
    required String password,
  }) =>
      _client.auth.resetPassword(token: token, password: password);

  Future<SessionsListDto> listSessions() => _client.auth.listSessions();

  Future<void> revokeSession(String id) => _client.auth.revokeSession(id);

  Future<bool> healthCheck() async {
    try {
      await _client.health.health();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<PublicUserDto> me() => _client.users.me();
}
