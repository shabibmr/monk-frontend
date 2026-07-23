import '../../../../core/network/error_mapper.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/session/token_store.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../mappers/user_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required TokenStore tokenStore,
    required SessionCubit sessionCubit,
  })  : _remote = remote,
        _tokenStore = tokenStore,
        _sessionCubit = sessionCubit;

  // Named params kept for DI readability (prefer_initializing_formals waived).
  final AuthRemoteDataSource _remote;
  final TokenStore _tokenStore;
  final SessionCubit _sessionCubit;

  @override
  Future<User> register({
    required String email,
    required String password,
    required String role,
    required bool acceptTerms,
    String? fullName,
  }) async {
    try {
      final res = await _remote.register(
        email: email,
        password: password,
        role: role,
        acceptTerms: acceptTerms,
        fullName: fullName,
      );
      return mapUser(res.user);
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _remote.login(email: email, password: password);
      await _tokenStore.saveTokens(
        accessToken: res.accessToken,
        refreshToken: res.refreshToken,
      );
      final user = mapUser(res.user);
      _sessionCubit.setSession(user);
      return AuthSession(
        user: user,
        accessToken: res.accessToken,
        refreshToken: res.refreshToken,
        expiresIn: res.expiresIn,
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      if (_tokenStore.hasTokens) {
        await _remote.logout();
      }
    } catch (_) {
      // Still clear local session on logout failure.
    } finally {
      await _sessionCubit.clear();
    }
  }

  @override
  Future<User> verifyEmail({required String token}) async {
    try {
      final dto = await _remote.verifyEmail(token);
      return mapUser(dto);
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> resendVerification({required String email}) async {
    try {
      await _remote.resendVerification(email);
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await _remote.forgotPassword(email);
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      await _remote.resetPassword(token: token, password: password);
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<List<DeviceSession>> listSessions() async {
    try {
      final res = await _remote.listSessions();
      return res.data.map(mapSession).toList();
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> revokeSession(String sessionId) async {
    try {
      await _remote.revokeSession(sessionId);
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<bool> healthCheck() => _remote.healthCheck();

  @override
  Future<User?> restoreSession() async {
    if (!_tokenStore.hasTokens) return null;
    try {
      final dto = await _remote.me();
      final user = mapUser(dto);
      _sessionCubit.setSession(user);
      return user;
    } catch (_) {
      await _sessionCubit.clear();
      return null;
    }
  }
}
