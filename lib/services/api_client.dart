import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// Central HTTP client for all API calls (GET, POST, PUT, PATCH, DELETE, multipart).
class ApiClient {
  ApiClient({http.Client? client, http.Client? uploadClient})
      : _client = client ?? http.Client(),
        _uploadClient = uploadClient ?? client ?? _createUploadClient();

  static const Duration defaultUploadTimeout = Duration(minutes: 10);

  final http.Client _client;
  final http.Client _uploadClient;

  static http.Client _createUploadClient() {
    final httpClient = HttpClient()
      ..connectionTimeout = const Duration(seconds: 45)
      ..idleTimeout = const Duration(minutes: 10);
    return IOClient(httpClient);
  }

  String apiErrorMessage(String body, String fallback) {
    if (body.isEmpty) return fallback;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message = (decoded['message'] ?? '').toString().trim();
        if (message.isNotEmpty) return message;
      }
    } catch (_) {
      return fallback;
    }
    return body;
  }

  Map<String, String> _authHeaders({String? token}) {
    final headers = <String, String>{};
    final trimmedToken = token?.trim() ?? '';
    if (trimmedToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $trimmedToken';
    }
    return headers;
  }

  Map<String, String> _jsonHeaders({
    String? token,
    Map<String, String>? extra,
  }) {
    return {
      'Content-Type': 'application/json',
      ..._authHeaders(token: token),
      ...?extra,
    };
  }

  void _logRequest({
    required Uri uri,
    required String method,
    required String endpointName,
    Object? body,
    String? userHint,
  }) {
    debugPrint(
      '[$endpointName] $method => $uri'
      '${userHint != null ? ' (user: $userHint)' : ''}',
    );
    if (body != null) {
      debugPrint('[$endpointName] BODY => ${jsonEncode(body)}');
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
    debugPrint(
      '[$endpointName] Response <= $uri status=$statusCode body=$bodyPreview',
    );
  }

  Future<http.Response> get(
    String url, {
    String? token,
    Map<String, String>? headers,
    String endpointName = 'GET',
  }) async {
    final uri = Uri.parse(url);
    _logRequest(uri: uri, method: 'GET', endpointName: endpointName);

    final response = await _client.get(
      uri,
      headers: {
        ..._authHeaders(token: token),
        ...?headers,
      },
    );

    _logResponse(
      uri: uri,
      endpointName: endpointName,
      statusCode: response.statusCode,
      responseBody: response.body,
    );
    return response;
  }

  Future<http.Response> post(
    String url, {
    Object? body,
    String? token,
    Map<String, String>? headers,
    String endpointName = 'POST',
    String? userHint,
  }) async {
    final uri = Uri.parse(url);
    _logRequest(
      uri: uri,
      method: 'POST',
      endpointName: endpointName,
      body: body,
      userHint: userHint,
    );

    final response = await _client.post(
      uri,
      headers: _jsonHeaders(token: token, extra: headers),
      body: body != null ? jsonEncode(body) : null,
    );

    _logResponse(
      uri: uri,
      endpointName: endpointName,
      statusCode: response.statusCode,
      responseBody: response.body,
    );
    return response;
  }

  Future<http.Response> put(
    String url, {
    Object? body,
    String? token,
    Map<String, String>? headers,
    String endpointName = 'PUT',
    String? userHint,
  }) async {
    final uri = Uri.parse(url);
    _logRequest(
      uri: uri,
      method: 'PUT',
      endpointName: endpointName,
      body: body,
      userHint: userHint,
    );

    final response = await _client.put(
      uri,
      headers: _jsonHeaders(token: token, extra: headers),
      body: body != null ? jsonEncode(body) : null,
    );

    _logResponse(
      uri: uri,
      endpointName: endpointName,
      statusCode: response.statusCode,
      responseBody: response.body,
    );
    return response;
  }

  Future<http.Response> patch(
    String url, {
    Object? body,
    String? token,
    Map<String, String>? headers,
    String endpointName = 'PATCH',
    String? userHint,
  }) async {
    final uri = Uri.parse(url);
    _logRequest(
      uri: uri,
      method: 'PATCH',
      endpointName: endpointName,
      body: body,
      userHint: userHint,
    );

    final response = await _client.patch(
      uri,
      headers: _jsonHeaders(token: token, extra: headers),
      body: body != null ? jsonEncode(body) : null,
    );

    _logResponse(
      uri: uri,
      endpointName: endpointName,
      statusCode: response.statusCode,
      responseBody: response.body,
    );
    return response;
  }

  Future<http.Response> delete(
    String url, {
    Object? body,
    String? token,
    Map<String, String>? headers,
    String endpointName = 'DELETE',
    String? userHint,
  }) async {
    final uri = Uri.parse(url);
    _logRequest(
      uri: uri,
      method: 'DELETE',
      endpointName: endpointName,
      body: body,
      userHint: userHint,
    );

    final response = await _client.delete(
      uri,
      headers: _jsonHeaders(token: token, extra: headers),
      body: body != null ? jsonEncode(body) : null,
    );

    _logResponse(
      uri: uri,
      endpointName: endpointName,
      statusCode: response.statusCode,
      responseBody: response.body,
    );
    return response;
  }

  Future<http.Response> sendMultipart(
    http.MultipartRequest request, {
    Duration timeout = defaultUploadTimeout,
    String endpointName = 'MULTIPART',
    Never Function()? onTimeout,
  }) async {
    _logRequest(
      uri: request.url,
      method: request.method,
      endpointName: endpointName,
    );

    final streamed = await _uploadClient.send(request).timeout(
      timeout,
      onTimeout: onTimeout ??
          (() => throw Exception('Upload timed out. Please try again.')),
    );
    final response = await http.Response.fromStream(streamed);

    _logResponse(
      uri: request.url,
      endpointName: endpointName,
      statusCode: response.statusCode,
      responseBody: response.body,
    );
    return response;
  }
}
