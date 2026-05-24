class UserSession {
  UserSession._();

  static String? _userName;

  static String? get userName => _userName;

  static void setUserName(String name) {
    final trimmed = name.trim();
    _userName = trimmed.isEmpty ? null : trimmed;
  }

  static void clear() => _userName = null;
}
