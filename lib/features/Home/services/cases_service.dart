import 'dart:convert';

import 'package:auto_care/features/Home/models/case_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CasesService {
  CasesService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = 'http://35.154.202.121:8080';

  final http.Client _client;

  String _apiErrorMessage(String body, String fallback) {
    if (body.isEmpty) return fallback;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message = (decoded['message'] ?? '').toString().trim();
        if (message.isNotEmpty) return message;
      }
    } catch (_) {}
    return body;
  }

  Future<List<CaseModel>> fetchAllCases({required String token}) async {
    final uri = Uri.parse('$_baseUrl/api/cases/get/all/cases');
    debugPrint('[CASES_ALL] GET => $uri');

    final trimmedToken = token.trim();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (trimmedToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $trimmedToken';
    }

    final response = await _client.get(uri, headers: headers);
    final bodyPreview = response.body.length > 500
        ? '${response.body.substring(0, 500)}...'
        : response.body;
    debugPrint(
      '[CASES_ALL] Response <= $uri status=${response.statusCode} body=$bodyPreview',
    );

    if (response.statusCode != 200) {
      throw Exception(
        _apiErrorMessage(
          response.body,
          'Unable to load inspection requests. Please try again.',
        ),
      );
    }

    final decoded = response.body.isNotEmpty ? jsonDecode(response.body) : [];
    final rawList = decoded is List
        ? decoded
        : (decoded is Map<String, dynamic> && decoded['data'] is List
              ? decoded['data'] as List
              : const []);

    return rawList
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map(CaseModel.fromJson)
        .toList();
  }
}
