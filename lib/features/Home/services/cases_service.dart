import 'dart:convert';
import 'dart:io';

import 'package:auto_care/features/Home/models/case_model.dart';
import 'package:auto_care/features/vehicle/models/create_case_request.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class CasesService {
  CasesService({http.Client? client})
      : _client = client ?? _defaultClient(),
        _uploadClient = client ?? _createUploadClient();

  static http.Client _defaultClient() => http.Client();

  static http.Client _createUploadClient() {
    final httpClient = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30)
      ..idleTimeout = const Duration(minutes: 5);
    return IOClient(httpClient);
  }

  final http.Client _client;
  final http.Client _uploadClient;

  static const String _baseUrl = 'http://35.154.202.121:8080';

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

  Future<CaseModel> createCase({
    required CreateCaseRequest request,
    required String token,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/cases/create').replace(
      queryParameters: request.toQueryParameters(),
    );
    debugPrint('[CASES_CREATE] POST => $uri');

    final multipart = http.MultipartRequest('POST', uri);
    final trimmedToken = token.trim();
    if (trimmedToken.isNotEmpty) {
      multipart.headers['Authorization'] = 'Bearer $trimmedToken';
    }

    for (final path in request.imagePaths) {
      final file = await _multipartFile('images', path);
      if (file != null) multipart.files.add(file);
    }

    final videoPath = request.videoPath;
    if (videoPath != null && videoPath.isNotEmpty) {
      final file = await _multipartFile('videos', videoPath);
      if (file != null) multipart.files.add(file);
    }

    for (final path in request.rcImages) {
      final file = await _multipartFile('rc', path);
      if (file != null) multipart.files.add(file);
    }

    final streamed = await _uploadClient.send(multipart);
    final response = await http.Response.fromStream(streamed);
    final bodyPreview = response.body.length > 500
        ? '${response.body.substring(0, 500)}...'
        : response.body;
    debugPrint(
      '[CASES_CREATE] Response <= $uri status=${response.statusCode} body=$bodyPreview',
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        _apiErrorMessage(
          response.body,
          'Unable to create inspection request. Please try again.',
        ),
      );
    }

    if (response.body.isEmpty) {
      return CaseModel.fromVehicleRecord(
        request.toVehicleRecord(),
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is Map<String, dynamic>) {
        return CaseModel.fromJson(data);
      }
      return CaseModel.fromJson(decoded);
    }

    return CaseModel.fromVehicleRecord(request.toVehicleRecord());
  }

  Future<http.MultipartFile?> _multipartFile(String field, String path) async {
    final file = File(path);
    if (!await file.exists()) return null;

    final segments = path.split(Platform.pathSeparator);
    final filename = segments.isNotEmpty ? segments.last : 'upload';
    return http.MultipartFile.fromPath(
      field,
      path,
      filename: filename,
    );
  }
}
