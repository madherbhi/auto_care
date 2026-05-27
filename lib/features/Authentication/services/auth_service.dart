import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:auto_care/features/Authentication/models/auth_models.dart';
import 'package:http/http.dart' as http;

class AuthService {
  AuthService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = 'http://35.154.202.121:8080';

  final http.Client _client;

  void _logRequest({
    required Uri uri,
    required String endpointName,
    String? userHint,
    Map<String, dynamic>? body,
  }) {
    debugPrint(
      '[$endpointName] POST => $uri${userHint != null ? ' (user: $userHint)' : ''}',
    );
    if (body != null) {
      // Avoid logging raw passwords.
      final sanitized = Map<String, dynamic>.from(body);
      if (sanitized.containsKey('password')) {
        sanitized['password'] = '***';
      }
      debugPrint('[$endpointName] BODY => ${jsonEncode(sanitized)}');
    }
  }

  void _logResponse({
    required Uri uri,
    required String endpointName,
    required int statusCode,
    required String responseBody,
  }) {
    final bodyPreview = responseBody.length > 500
        ? '${responseBody.substring(0, 500)}...'
        : responseBody;
    debugPrint('[$endpointName] Response <= $uri status=$statusCode body=$bodyPreview');
  }

  /// Extracts the user-facing `message` from API error JSON responses.
  String _apiErrorMessage(String body, String fallback) {
    if (body.isEmpty) return fallback;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message = (decoded['message'] ?? '').toString().trim();
        if (message.isNotEmpty) return message;
      }
    } catch (_) {
      // Body is not JSON; show as-is if it looks like plain text.
    }
    return body;
  }

  Future<void> register(RegisterRequest request) async {
    final uri = Uri.parse('$_baseUrl/auth/register');
    final body = request.toJson();
    _logRequest(
      uri: uri,
      endpointName: 'AUTH_REGISTER',
      userHint: request.username,
      body: body,
    );

    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    _logResponse(
      uri: uri,
      endpointName: 'AUTH_REGISTER',
      statusCode: response.statusCode,
      responseBody: response.body,
    );

    if (response.statusCode != 201) {
      throw Exception(
        _apiErrorMessage(
          response.body,
          'Registration failed. Please try again.',
        ),
      );
    }
  }

  Future<LoginResponse> login(LoginRequest request) async {
    final uri = Uri.parse('$_baseUrl/auth/login');
    final body = request.toJson();
    _logRequest(
      uri: uri,
      endpointName: 'AUTH_LOGIN',
      userHint: request.mailId,
      body: body,
    );

    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    _logResponse(
      uri: uri,
      endpointName: 'AUTH_LOGIN',
      statusCode: response.statusCode,
      responseBody: response.body,
    );

    if (response.statusCode != 200) {
      throw Exception(
        _apiErrorMessage(
          response.body,
          'Login failed. Please check your credentials.',
        ),
      );
    }

    final Map<String, dynamic> json =
        response.body.isNotEmpty ? jsonDecode(response.body) : {};
    return LoginResponse.fromJson(json);
  }
}

