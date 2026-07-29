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

  static bool isTokenExpired(String token, {DateTime? now}) {
    final payload = _decodePayload(token);
    if (payload == null) return true;

    final exp = payload['exp'];
    if (exp == null) return false;

    final expSeconds = exp is int ? exp : int.tryParse(exp.toString());
    if (expSeconds == null) return false;

    final clock = now ?? DateTime.now();
    return clock.isAfter(
      DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000, isUtc: true)
          .toLocal(),
    );
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
