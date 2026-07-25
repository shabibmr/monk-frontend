import 'package:monk_shared/monk_shared.dart';

import '../../features/auth/domain/entities/user.dart';
import 'mock_ids.dart';
import 'seed/demo_accounts.dart';
import 'seed/seed_fulfillment.dart';
import 'seed/seed_marketplace.dart';
import 'seed/seed_money.dart';
import 'seed/seed_platform.dart';
import 'seed/seed_profiles.dart';

/// Demo account row used by [MockAuthRepository].
class DemoAccount {
  const DemoAccount({
    required this.user,
    required this.password,
    this.brandId,
    this.profileId,
    this.profileName,
    this.brandOnboardingComplete = true,
    this.influencerOnboardingComplete = true,
    this.isManagerContext = false,
    this.managerPermissions = const [],
  });

  final User user;
  final String password;
  final String? brandId;
  final String? profileId;
  final String? profileName;
  final bool brandOnboardingComplete;
  final bool influencerOnboardingComplete;
  final bool isManagerContext;
  final List<String> managerPermissions;
}

/// Single in-memory "DB" for offline demo mocks. Mutable so Brand + Creator stay in sync.
class MockSeedStore {
  MockSeedStore({this.latencyMs = 150});

  final int latencyMs;
  bool _initialized = false;

  final Map<String, DemoAccount> accountsByEmail = {};
  final Map<String, DemoAccount> accountsById = {};
  final Map<String, String> tokenToUserId = {};

  /// Generic bag keyed by collection name → list of domain objects / maps.
  final Map<String, List<dynamic>> collections = {};

  /// Single-record bag (subscription, dashboards, etc.).
  final Map<String, dynamic> singles = {};

  String? currentUserId;

  bool get isInitialized => _initialized;

  Future<void> delay() async {
    if (latencyMs <= 0) return;
    await Future<void>.delayed(Duration(milliseconds: latencyMs));
  }

  void initialize() {
    if (_initialized) return;
    seedDemoAccounts(this);
    seedProfiles(this);
    seedMarketplace(this);
    seedFulfillment(this);
    seedMoney(this);
    seedPlatform(this);
    _initialized = true;
  }

  List<T> list<T>(String key) {
    final raw = collections[key] ?? const [];
    return raw.whereType<T>().toList();
  }

  void putAll(String key, List<dynamic> items) {
    collections[key] = List<dynamic>.from(items);
  }

  void add(String key, dynamic item) {
    collections.putIfAbsent(key, () => <dynamic>[]);
    collections[key]!.add(item);
  }

  T? findWhere<T>(String key, bool Function(T) test) {
    for (final item in list<T>(key)) {
      if (test(item)) return item;
    }
    return null;
  }

  void replaceWhere<T>(String key, bool Function(T) test, T replacement) {
    final items = collections.putIfAbsent(key, () => <dynamic>[]);
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      if (item is T && test(item)) {
        items[i] = replacement;
        return;
      }
    }
    items.add(replacement);
  }

  void removeWhere<T>(String key, bool Function(T) test) {
    final items = collections[key];
    if (items == null) return;
    items.removeWhere((e) => e is T && test(e));
  }

  /// Legacy / friendly sign-in names → canonical demo username.
  static const _emailAliases = <String, String>{
    'demo.admin@influencersmonk.local': MockIds.emailAdmin,
    'demo.brand1@influencersmonk.local': MockIds.emailBrand1,
    'priya': MockIds.emailBrand1,
    'demo.creator1@influencersmonk.local': MockIds.emailCreator1,
    'arjun': MockIds.emailCreator1,
    'demo.manager1@influencersmonk.local': MockIds.emailManager1,
    'meera': MockIds.emailManager1,
    'demo.agency1@influencersmonk.local': MockIds.emailAgency1,
    'alex': MockIds.emailAgency1,
    'demo.brand.fresh@influencersmonk.local': MockIds.emailBrandFresh,
    'freshbrand': MockIds.emailBrandFresh,
    'demo.creator.fresh@influencersmonk.local': MockIds.emailCreatorFresh,
    'freshcreator': MockIds.emailCreatorFresh,
  };

  DemoAccount? findAccountByEmail(String email) {
    final norm = email.trim().toLowerCase();
    if (accountsByEmail.containsKey(norm)) {
      return accountsByEmail[norm];
    }

    final alias = _emailAliases[norm];
    if (alias != null) {
      return accountsByEmail[alias.toLowerCase()];
    }

    // `creator@anything` still lands on the creator persona, etc.
    final local = norm.contains('@') ? norm.split('@').first : norm;
    if (accountsByEmail.containsKey(local)) {
      return accountsByEmail[local];
    }
    final localAlias = _emailAliases[local];
    if (localAlias != null) {
      return accountsByEmail[localAlias.toLowerCase()];
    }
    return null;
  }

  DemoAccount? findAccountById(String id) => accountsById[id];

  void registerAccount(DemoAccount account) {
    final email = account.user.email.toLowerCase();
    accountsByEmail[email] = account;
    accountsById[account.user.id] = account;
  }

  String issueTokens(String userId) {
    final access = 'mock-access-$userId';
    final refresh = 'mock-refresh-$userId';
    tokenToUserId[access] = userId;
    tokenToUserId[refresh] = userId;
    currentUserId = userId;
    return access;
  }

  User? userFromAccessToken(String? accessToken) {
    if (accessToken == null || accessToken.isEmpty) return null;
    final userId = tokenToUserId[accessToken];
    if (userId == null) {
      // Accept token shape mock-access-<userId> even if map was cleared.
      if (accessToken.startsWith('mock-access-')) {
        final id = accessToken.substring('mock-access-'.length);
        return accountsById[id]?.user;
      }
      return null;
    }
    return accountsById[userId]?.user;
  }

  void clearSession() {
    currentUserId = null;
  }

  static User makeUser({
    required String id,
    required String email,
    required UserRole role,
    String? fullName,
    UserStatus status = UserStatus.active,
  }) {
    return User(
      id: id,
      email: email,
      role: role,
      status: status,
      fullName: fullName,
    );
  }

  /// Convenience for demos that need the primary brand org id.
  String get primaryBrandId => MockIds.brandOrg1;

  String get primaryProfileId => MockIds.influencer1;
}
