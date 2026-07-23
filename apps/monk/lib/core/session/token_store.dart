import 'package:shared_preferences/shared_preferences.dart';

/// Web-appropriate token storage.
/// Access + refresh tokens live in SharedPreferences for local/web MVP.
/// Human review gate: upgrade path to httpOnly cookies / secure storage noted.
class TokenStore {
  TokenStore(this._prefs);

  final SharedPreferences _prefs;

  static const _accessKey = 'im.access_token';
  static const _refreshKey = 'im.refresh_token';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _prefs.setString(_accessKey, accessToken);
    await _prefs.setString(_refreshKey, refreshToken);
  }

  String? get accessToken => _prefs.getString(_accessKey);
  String? get refreshToken => _prefs.getString(_refreshKey);

  bool get hasTokens =>
      (accessToken?.isNotEmpty ?? false) &&
      (refreshToken?.isNotEmpty ?? false);

  Future<void> clear() async {
    await _prefs.remove(_accessKey);
    await _prefs.remove(_refreshKey);
  }
}
