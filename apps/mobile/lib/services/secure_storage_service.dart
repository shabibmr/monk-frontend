import 'package:shared_preferences/shared_preferences.dart';

/// Platform Secure Storage Interface Stub for Monk Mobile.
///
/// Human Review Gate (Phase 3 Mobile Auth):
/// For production iOS/Android native builds, replace [InMemorySecureStorageService]
/// or [SharedPreferencesSecureStorageService] with hardware-backed Keychain (iOS)
/// and EncryptedSharedPreferences / KeyStore (Android) using `flutter_secure_storage`.
abstract class SecureStorageService {
  static const String accessTokenKey = 'monk_mobile_access_token';
  static const String refreshTokenKey = 'monk_mobile_refresh_token';
  static const String userPinKey = 'monk_mobile_user_pin';

  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
  Future<void> clearAll();
  Future<bool> containsKey({required String key});

  Future<void> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await write(key: accessTokenKey, value: accessToken);
    await write(key: refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() => read(key: accessTokenKey);
  Future<String?> getRefreshToken() => read(key: refreshTokenKey);

  Future<void> clearTokens() async {
    await delete(key: accessTokenKey);
    await delete(key: refreshTokenKey);
  }
}

/// In-memory implementation of [SecureStorageService] for fast unit testing & stubs.
class InMemorySecureStorageService extends SecureStorageService {
  final Map<String, String> _storage = {};

  @override
  Future<void> write({required String key, required String value}) async {
    _storage[key] = value;
  }

  @override
  Future<String?> read({required String key}) async {
    return _storage[key];
  }

  @override
  Future<void> delete({required String key}) async {
    _storage.remove(key);
  }

  @override
  Future<void> clearAll() async {
    _storage.clear();
  }

  @override
  Future<bool> containsKey({required String key}) async {
    return _storage.containsKey(key);
  }
}

/// Platform-backed SharedPreferences implementation of [SecureStorageService].
class SharedPreferencesSecureStorageService extends SecureStorageService {
  SharedPreferencesSecureStorageService(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<void> write({required String key, required String value}) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<String?> read({required String key}) async {
    return _prefs.getString(key);
  }

  @override
  Future<void> delete({required String key}) async {
    await _prefs.remove(key);
  }

  @override
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  @override
  Future<bool> containsKey({required String key}) async {
    return _prefs.containsKey(key);
  }
}
