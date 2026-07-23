import 'package:monk_shared/monk_shared.dart';

import '../../../features/auth/domain/entities/user.dart';
import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../errors/failures.dart';
import '../../session/session_cubit.dart';
import '../../session/token_store.dart';
import '../mock_ids.dart';
import '../mock_seed_store.dart';

/// Offline demo implementation of [AuthRepository].
///
/// Store keys:
/// - `sessions` → `List<DeviceSession>`
class MockAuthRepository implements AuthRepository {
  MockAuthRepository({
    required MockSeedStore store,
    required TokenStore tokenStore,
    required SessionCubit sessionCubit,
  })  : _store = store,
        _tokenStore = tokenStore,
        _sessionCubit = sessionCubit;

  final MockSeedStore _store;
  final TokenStore _tokenStore;
  final SessionCubit _sessionCubit;

  static const sessionsKey = 'sessions';

  @override
  Future<User> register({
    required String email,
    required String password,
    required String role,
    required bool acceptTerms,
    String? fullName,
  }) async {
    await _store.delay();
    if (!acceptTerms) {
      throw const ValidationFailure('You must accept the terms to register');
    }
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty || password.isEmpty) {
      throw const ValidationFailure('Email and password are required');
    }
    if (_store.findAccountByEmail(normalized) != null) {
      throw const ConflictFailure('An account with this email already exists');
    }

    final UserRole parsedRole;
    try {
      parsedRole = UserRole.fromApi(role);
    } catch (_) {
      throw ValidationFailure('Unknown role: $role');
    }

    final id = 'user-demo-reg-${DateTime.now().millisecondsSinceEpoch}';
    final user = MockSeedStore.makeUser(
      id: id,
      email: normalized,
      role: parsedRole,
      fullName: fullName,
      status: UserStatus.pendingEmail,
    );
    _store.registerAccount(
      DemoAccount(
        user: user,
        password: password,
        brandOnboardingComplete: parsedRole != UserRole.brandUser,
        influencerOnboardingComplete: parsedRole != UserRole.influencer,
      ),
    );
    return user;
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    await _store.delay();
    final account = _store.findAccountByEmail(email);
    if (account == null || account.password != password) {
      throw const AuthFailure('Invalid email or password');
    }

    final access = _store.issueTokens(account.user.id);
    final refresh = 'mock-refresh-${account.user.id}';
    await _tokenStore.saveTokens(
      accessToken: access,
      refreshToken: refresh,
    );
    _applyAccountSession(account);

    return AuthSession(
      user: account.user,
      accessToken: access,
      refreshToken: refresh,
      expiresIn: 3600,
    );
  }

  @override
  Future<void> logout() async {
    await _store.delay();
    _store.clearSession();
    await _sessionCubit.clear();
  }

  @override
  Future<User> verifyEmail({required String token}) async {
    await _store.delay();
    if (token.trim().isEmpty) {
      throw const ValidationFailure('Verification token is required');
    }

    DemoAccount? account;
    if (token.startsWith('mock-verify-')) {
      final id = token.substring('mock-verify-'.length);
      account = _store.findAccountById(id);
    }
    if (account == null) {
      final pending = _store.accountsById.values
          .where((a) => a.user.status == UserStatus.pendingEmail);
      if (pending.isNotEmpty) account = pending.first;
    }

    if (account == null) {
      return MockSeedStore.makeUser(
        id: MockIds.brand1,
        email: MockIds.emailBrand1,
        role: UserRole.brandUser,
        fullName: 'Verified User',
      );
    }

    final updatedUser = User(
      id: account.user.id,
      email: account.user.email,
      role: account.user.role,
      status: UserStatus.active,
      fullName: account.user.fullName,
      phone: account.user.phone,
    );
    _store.registerAccount(_copyAccount(account, user: updatedUser));
    return updatedUser;
  }

  @override
  Future<void> resendVerification({required String email}) async {
    await _store.delay();
    if (email.trim().isEmpty) {
      throw const ValidationFailure('Email is required');
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await _store.delay();
    if (email.trim().isEmpty) {
      throw const ValidationFailure('Email is required');
    }
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    await _store.delay();
    if (token.trim().isEmpty) {
      throw const ValidationFailure('Reset token is required');
    }
    if (password.length < 8) {
      throw const ValidationFailure('Password must be at least 8 characters');
    }
    if (token.startsWith('mock-reset-')) {
      final id = token.substring('mock-reset-'.length);
      final account = _store.findAccountById(id);
      if (account != null) {
        _store.registerAccount(_copyAccount(account, password: password));
      }
    }
  }

  @override
  Future<List<DeviceSession>> listSessions() async {
    await _store.delay();
    final existing = _store.list<DeviceSession>(sessionsKey);
    if (existing.isNotEmpty) return existing;

    final seeded = DeviceSession(
      id: MockIds.session1,
      current: true,
      userAgent: 'Demo Browser',
      ipAddress: '127.0.0.1',
      createdAt: DateTime.now().toUtc(),
    );
    _store.add(sessionsKey, seeded);
    return [seeded];
  }

  @override
  Future<void> revokeSession(String sessionId) async {
    await _store.delay();
    _store.removeWhere<DeviceSession>(
      sessionsKey,
      (s) => s.id == sessionId,
    );
  }

  @override
  Future<bool> healthCheck() async {
    await _store.delay();
    return true;
  }

  @override
  Future<User?> restoreSession() async {
    await _store.delay();
    if (!_tokenStore.hasTokens) return null;

    final user = _store.userFromAccessToken(_tokenStore.accessToken);
    if (user == null) {
      await _sessionCubit.clear();
      _store.clearSession();
      return null;
    }

    final account = _store.findAccountById(user.id);
    if (account == null) {
      await _sessionCubit.clear();
      _store.clearSession();
      return null;
    }

    _store.issueTokens(user.id);
    _applyAccountSession(account);
    return user;
  }

  void _applyAccountSession(DemoAccount account) {
    _sessionCubit.setSession(account.user);

    if (account.brandId != null) {
      _sessionCubit.setActiveBrand(account.brandId);
    }
    _sessionCubit.setBrandOnboardingComplete(account.brandOnboardingComplete);

    if (account.profileId != null) {
      _sessionCubit.setActiveProfile(
        profileId: account.profileId,
        isManagerContext: account.isManagerContext,
        displayName: account.profileName,
        permissions: account.managerPermissions,
      );
    }

    _sessionCubit.setOnboardingComplete(account.influencerOnboardingComplete);
  }

  DemoAccount _copyAccount(
    DemoAccount account, {
    User? user,
    String? password,
  }) {
    return DemoAccount(
      user: user ?? account.user,
      password: password ?? account.password,
      brandId: account.brandId,
      profileId: account.profileId,
      profileName: account.profileName,
      brandOnboardingComplete: account.brandOnboardingComplete,
      influencerOnboardingComplete: account.influencerOnboardingComplete,
      isManagerContext: account.isManagerContext,
      managerPermissions: account.managerPermissions,
    );
  }
}
