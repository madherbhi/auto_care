import 'dart:convert';

import 'package:auto_care/utils/user_session.dart';

/// Lightweight JWT payload helpers (no signature verification).
class JwtHelper {
  JwtHelper._();

  static String? usernameFromToken(String token) {
    final payload = _decodePayload(token);
    if (payload == null) return null;

    for (final key in const [
      'username',
      'userName',
      'name',
      'preferred_username',
      'unique_name',
      'given_name',
    ]) {
      final value = payload[key];
      if (value == null) continue;
      final resolved = value.toString().trim();
      if (resolved.isNotEmpty && !UserSession.isLikelyEmail(resolved)) {
        return resolved;
      }
    }

    final sub = payload['sub']?.toString().trim() ?? '';
    if (sub.isNotEmpty && !UserSession.isLikelyEmail(sub)) return sub;
    return null;
  }

  static Map<String, dynamic>? _decodePayload(String token) {
    final parts = token.split('.');
    if (parts.length < 2) return null;

    try {
      var segment = parts[1];
      final remainder = segment.length % 4;
      if (remainder > 0) {
        segment += '=' * (4 - remainder);
      }
      final normalized = segment.replaceAll('-', '+').replaceAll('_', '/');
      final decoded = utf8.decode(base64.decode(normalized));
      final json = jsonDecode(decoded);
      if (json is Map<String, dynamic>) return json;
      if (json is Map) return Map<String, dynamic>.from(json);
    } catch (_) {
      return null;
    }
    return null;
  }
}
