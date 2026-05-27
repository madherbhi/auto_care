import 'package:auto_care/utils/jwt_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  UserSession._();

  static String? _userName;
  static String? _authToken;

  static SharedPreferences? _prefs;

  static const String _kUserName = 'userName';
  static const String _kAuthToken = 'authToken';
  static const String _kUsernameByMailPrefix = 'usernameForMail:';

  static String? get userName => _userName;
  static String? get authToken => _authToken;

  static bool get isLoggedIn => _authToken != null && _authToken!.isNotEmpty;

  /// True when [value] looks like a login email, not a display name.
  static bool isLikelyEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return false;
    return trimmed.contains('@');
  }

  /// Session username suitable for display (excludes stored emails).
  static String? get displayUserName {
    final name = _userName?.trim() ?? '';
    if (name.isEmpty || isLikelyEmail(name)) return null;
    return name;
  }

  /// Username for API calls: saved display name, then JWT claims.
  static String? resolvedUserName() {
    final fromSession = displayUserName;
    if (fromSession != null && fromSession.isNotEmpty) return fromSession;

    final token = _authToken?.trim() ?? '';
    if (token.isEmpty) return null;
    return JwtHelper.usernameFromToken(token);
  }

  /// Loads saved session values from local storage into memory.
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    _userName = _prefs?.getString(_kUserName);
    _authToken = _prefs?.getString(_kAuthToken);
    if (isLikelyEmail(_userName)) {
      _userName = null;
      await _prefs?.remove(_kUserName);
    }
  }

  static void setUserName(String name) {
    final trimmed = name.trim();
    _userName = trimmed.isEmpty ? null : trimmed;
  }

  /// Saves the display username for a login email (from registration).
  static Future<void> rememberUsernameForMail(
    String mailId,
    String username,
  ) async {
    final mail = mailId.trim().toLowerCase();
    final name = username.trim();
    if (mail.isEmpty || name.isEmpty || isLikelyEmail(name)) return;

    final prefs = _prefs ??= await SharedPreferences.getInstance();
    await prefs.setString('$_kUsernameByMailPrefix$mail', name);
  }

  /// Restores the display username for [mailId] if one was saved at registration.
  static Future<void> restoreUsernameForMail(String mailId) async {
    final mail = mailId.trim().toLowerCase();
    if (mail.isEmpty) return;

    final prefs = _prefs ??= await SharedPreferences.getInstance();
    final remembered = prefs.getString('$_kUsernameByMailPrefix$mail')?.trim();
    if (remembered == null || remembered.isEmpty || isLikelyEmail(remembered)) {
      return;
    }
    setUserName(remembered);
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
