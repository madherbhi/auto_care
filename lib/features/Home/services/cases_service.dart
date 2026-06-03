import 'dart:convert';
import 'dart:io';

import 'package:auto_care/constants/api_endpoints.dart';
import 'package:auto_care/features/Home/models/case_model.dart';
import 'package:auto_care/features/vehicle/models/create_case_request.dart';
import 'package:auto_care/services/api_client.dart';
import 'package:auto_care/utils/media_compress_helper.dart';
import 'package:auto_care/utils/media_path_helper.dart';
import 'package:auto_care/utils/string_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class CasesService {
  CasesService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<CaseModel>> fetchAllCases({
    required String token,
    required String username,
  }) async {
    final trimmedToken = token.trim();
    if (trimmedToken.isEmpty) {
      throw Exception(StringHelper.sessionExpired);
    }

    final trimmedUsername = username.trim();
    if (trimmedUsername.isEmpty) {
      throw Exception(StringHelper.userNameRequired);
    }

    final uri = Uri.parse(ApiEndpoints.casesAll).replace(
      queryParameters: {'userName': trimmedUsername},
    );

    final response = await _client.get(
      uri.toString(),
      token: trimmedToken,
      endpointName: 'CASES_ALL',
    );

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception(StringHelper.sessionExpired);
    }

    if (response.statusCode != 200) {
      throw Exception(
        _client.apiErrorMessage(
          response.body,
          StringHelper.loadCasesFailed,
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
    final uri = Uri.parse(ApiEndpoints.casesCreate).replace(
      queryParameters: request.toQueryParameters(),
    );
    final trimmedToken = token.trim();
    if (trimmedToken.isEmpty) {
      throw Exception(StringHelper.sessionExpired);
    }

    final multipart = http.MultipartRequest('POST', uri);
    multipart.headers['Authorization'] = 'Bearer $trimmedToken';

    await _attachFiles(
      multipart,
      field: 'images',
      paths: MediaPathHelper.localOnly(request.imagePaths),
      requiredLabel: null,
    );

    final videoPath = request.videoPath;
    if (videoPath != null && MediaPathHelper.isLocal(videoPath)) {
      await _attachFiles(
        multipart,
        field: 'videos',
        paths: [videoPath],
        requiredLabel: null,
      );
    }

    await _attachFiles(
      multipart,
      field: 'rcImages',
      paths: MediaPathHelper.localOnly(request.rcImages),
      requiredLabel: 'RC',
    );

    debugPrint(
      '[CASES_CREATE] Uploading ${multipart.files.length} file(s), '
      'total fields=${multipart.fields.length}',
    );

    final response = await _client.sendMultipart(
      multipart,
      endpointName: 'CASES_CREATE',
      timeout: ApiClient.defaultUploadTimeout,
      onTimeout: () => throw Exception(StringHelper.uploadTimedOut),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        _client.apiErrorMessage(
          response.body,
          StringHelper.createCaseFailed,
        ),
      );
    }

    return _parseCaseResponse(
      response.body,
      fallback: () => CaseModel.fromVehicleRecord(request.toVehicleRecord()),
    );
  }

  Future<CaseModel> updateCase({
    required int caseId,
    required CreateCaseRequest request,
    required String token,
  }) async {
    final uri = Uri.parse(ApiEndpoints.casesUpdate(caseId)).replace(
      queryParameters: request.toQueryParameters(),
    );
    final trimmedToken = token.trim();
    if (trimmedToken.isEmpty) {
      throw Exception(StringHelper.sessionExpired);
    }

    final multipart = http.MultipartRequest('PUT', uri);
    multipart.headers['Authorization'] = 'Bearer $trimmedToken';

    await _attachFiles(
      multipart,
      field: 'images',
      paths: MediaPathHelper.localOnly(request.imagePaths),
      requiredLabel: null,
    );

    final videoPath = request.videoPath;
    if (videoPath != null && MediaPathHelper.isLocal(videoPath)) {
      await _attachFiles(
        multipart,
        field: 'videos',
        paths: [videoPath],
        requiredLabel: null,
      );
    }

    await _attachFiles(
      multipart,
      field: 'rcImages',
      paths: MediaPathHelper.localOnly(request.rcImages),
      requiredLabel: null,
    );

    debugPrint(
      '[CASES_UPDATE] Uploading ${multipart.files.length} file(s), '
      'total fields=${multipart.fields.length}',
    );

    final response = await _client.sendMultipart(
      multipart,
      endpointName: 'CASES_UPDATE',
      timeout: ApiClient.defaultUploadTimeout,
      onTimeout: () => throw Exception(StringHelper.uploadTimedOut),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _client.apiErrorMessage(
          response.body,
          StringHelper.updateCaseFailed,
        ),
      );
    }

    return _parseCaseResponse(
      response.body,
      fallback: () => CaseModel.fromVehicleRecord(
        request.toVehicleRecord(),
        id: caseId,
      ),
    );
  }

  CaseModel _parseCaseResponse(
    String body, {
    required CaseModel Function() fallback,
  }) {
    if (body.isEmpty) return fallback();

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is Map<String, dynamic>) {
        return CaseModel.fromJson(data);
      }
      return CaseModel.fromJson(decoded);
    }

    return fallback();
  }

  Future<void> _attachFiles(
    http.MultipartRequest multipart, {
    required String field,
    required List<String> paths,
    required String? requiredLabel,
  }) async {
    if (paths.isEmpty) {
      if (requiredLabel != null) {
        throw Exception('$requiredLabel images are required.');
      }
      return;
    }

    var attached = 0;
    for (final path in paths) {
      final file = await _multipartFile(field, path);
      if (file != null) {
        multipart.files.add(file);
        attached++;
      }
    }

    if (requiredLabel != null && attached < paths.length) {
      throw Exception(
        '$requiredLabel file could not be read. Please upload it again.',
      );
    }
  }

  Future<http.MultipartFile?> _multipartFile(String field, String path) async {
    final file = File(path);
    if (!await file.exists()) {
      debugPrint('[CASES_UPLOAD] Missing file for $field: $path');
      return null;
    }

    final uploadPath = await MediaCompressHelper.prepareForUpload(path);
    final uploadFile = File(uploadPath);
    if (!await uploadFile.exists()) {
      debugPrint('[CASES_UPLOAD] Missing compressed file for $field: $uploadPath');
      return null;
    }

    final length = await uploadFile.length();
    debugPrint('[CASES_UPLOAD] Attaching $field ($length bytes): $uploadPath');

    final segments = uploadPath.split(Platform.pathSeparator);
    final filename = segments.isNotEmpty ? segments.last : 'upload';
    return http.MultipartFile.fromPath(
      field,
      uploadPath,
      filename: filename,
      contentType: _contentTypeForPath(uploadPath),
    );
  }

  MediaType? _contentTypeForPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return MediaType('image', 'png');
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return MediaType('image', 'jpeg');
    }
    if (lower.endsWith('.webp')) return MediaType('image', 'webp');
    if (lower.endsWith('.mp4')) return MediaType('video', 'mp4');
    if (lower.endsWith('.mov')) return MediaType('video', 'quicktime');
    return null;
  }
}
