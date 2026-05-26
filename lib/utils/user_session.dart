import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  UserSession._();

  static String? _userName;
  static String? _authToken;

  static SharedPreferences? _prefs;

  static const String _kUserName = 'userName';
  static const String _kAuthToken = 'authToken';

  static String? get userName => _userName;
  static String? get authToken => _authToken;

  static bool get isLoggedIn => _authToken != null && _authToken!.isNotEmpty;

  /// Loads saved session values from local storage into memory.
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    _userName = _prefs?.getString(_kUserName);
    _authToken = _prefs?.getString(_kAuthToken);
  }

  static void setUserName(String name) {
    final trimmed = name.trim();
    _userName = trimmed.isEmpty ? null : trimmed;
  }

  static void setAuthToken(String token) {
    final trimmed = token.trim();
    _authToken = trimmed.isEmpty ? null : trimmed;
  }

  /// Persists current session values to local storage.
  static Future<void> persist() async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    if (_userName == null) {
      await prefs.remove(_kUserName);
    } else {
      await prefs.setString(_kUserName, _userName!);
    }
    if (_authToken == null) {
      await prefs.remove(_kAuthToken);
    } else {
      await prefs.setString(_kAuthToken, _authToken!);
    }
  }

  static void clear() {
    _userName = null;
    _authToken = null;
  }

  /// Clears session values and also removes them from local storage.
  static Future<void> clearPersisted() async {
    clear();
    await persist();
  }
}
