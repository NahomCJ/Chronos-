import 'package:shared_preferences/shared_preferences.dart';

class TokenStorageService {
  static const _accessTokenKey = 'auth_access_token';
  static const _refreshTokenKey = 'auth_refresh_token';
  static const _userIdKey = 'auth_user_id';
  static const _firstNameKey = 'auth_first_name';

  final SharedPreferences _prefs;

  TokenStorageService(this._prefs);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? userId,
    String? firstName,
  }) async {
    await _prefs.setString(_accessTokenKey, accessToken);
    await _prefs.setString(_refreshTokenKey, refreshToken);
    if (userId != null) await _prefs.setString(_userIdKey, userId);
    if (firstName != null && firstName.isNotEmpty) {
      await _prefs.setString(_firstNameKey, firstName);
    }
  }

  String? get accessToken => _prefs.getString(_accessTokenKey);
  String? get refreshToken => _prefs.getString(_refreshTokenKey);
  String? get userId => _prefs.getString(_userIdKey);
  String? get firstName => _prefs.getString(_firstNameKey);
  bool get hasToken => _prefs.containsKey(_accessTokenKey);

  Future<void> clearTokens() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_firstNameKey);
  }
}
