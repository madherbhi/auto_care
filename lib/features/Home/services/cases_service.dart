import 'dart:convert';
import 'dart:io';

import 'package:auto_care/constants/api_endpoints.dart';
import 'package:auto_care/features/Home/models/case_model.dart';
import 'package:auto_care/features/vehicle/models/create_case_request.dart';
import 'package:auto_care/services/api_client.dart';
import 'package:auto_care/utils/media_compress_helper.dart';
import 'package:auto_care/utils/media_path_helper.dart';
import 'package:auto_care/utils/media_upload_filename.dart';
import 'package:auto_care/utils/media_upload_resolver.dart';
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

    final tempFilesToCleanup = <String>[];
    try {
      final freshCase = await _fetchCaseById(
        caseId: caseId,
        token: trimmedToken,
        userName: request.userName,
      );
      final media = freshCase != null
          ? _mergeFreshRemoteMedia(request: request, freshCase: freshCase)
          : _UpdateMediaBundle.fromRequest(request);

      final multipart = http.MultipartRequest('PUT', uri);
      multipart.headers['Authorization'] = 'Bearer $trimmedToken';

      final imagePaths = await MediaUploadResolver.resolveForUpload(
        media.imagePaths,
        tempFilesToCleanup: tempFilesToCleanup,
        authToken: trimmedToken,
      );
      _ensureAllMediaResolved(
        requested: media.imagePaths,
        resolved: imagePaths,
      );
      await _attachResolvedFiles(
        multipart,
        field: 'images',
        paths: imagePaths,
        serverFileNames: media.imageFileNames,
      );

      final videoPath = media.videoPath?.trim();
      if (videoPath != null && videoPath.isNotEmpty) {
        final videoPaths = await MediaUploadResolver.resolveForUpload(
          [videoPath],
          tempFilesToCleanup: tempFilesToCleanup,
          authToken: trimmedToken,
        );
        _ensureAllMediaResolved(
          requested: [videoPath],
          resolved: videoPaths,
        );
        await _attachResolvedFiles(
          multipart,
          field: 'videos',
          paths: videoPaths,
          serverFileNames: [media.videoFileName],
        );
      }

      final rcPaths = await MediaUploadResolver.resolveForUpload(
        media.rcImages,
        tempFilesToCleanup: tempFilesToCleanup,
        authToken: trimmedToken,
      );
      _ensureAllMediaResolved(
        requested: media.rcImages,
        resolved: rcPaths,
      );
      await _attachResolvedFiles(
        multipart,
        field: 'rcImages',
        paths: rcPaths,
        serverFileNames: media.rcFileNames,
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
    } finally {
      await MediaUploadResolver.deleteTempFiles(tempFilesToCleanup);
    }
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

  Future<CaseModel?> _fetchCaseById({
    required int caseId,
    required String token,
    required String userName,
  }) async {
    try {
      final cases = await fetchAllCases(token: token, username: userName);
      for (final item in cases) {
        if (item.id == caseId) return item;
      }
    } catch (e) {
      debugPrint('[CASES_UPDATE] Fresh case fetch failed: $e');
    }
    return null;
  }

  _UpdateMediaBundle _mergeFreshRemoteMedia({
    required CreateCaseRequest request,
    required CaseModel freshCase,
  }) {
    final imagePaths = <String>[];
    final imageFileNames = <String?>[];
    for (var i = 0; i < request.imagePaths.length; i++) {
      final path = request.imagePaths[i];
      if (MediaPathHelper.isLocal(path)) {
        imagePaths.add(path);
        imageFileNames.add(null);
        continue;
      }
      final fresh = _findMediaBySlot(freshCase.images, path) ??
          (i < freshCase.images.length ? freshCase.images[i] : null);
      if (fresh != null) {
        imagePaths.add(fresh.url);
        imageFileNames.add(fresh.fileName);
      } else {
        imagePaths.add(path);
        imageFileNames.add(MediaUploadFilename.slotKey(path));
      }
    }

    String? videoPath = request.videoPath;
    String? videoFileName;
    final rawVideo = request.videoPath?.trim();
    if (rawVideo != null &&
        rawVideo.isNotEmpty &&
        MediaPathHelper.isRemote(rawVideo)) {
      final fresh = _findMediaBySlot(freshCase.videos, rawVideo) ??
          (freshCase.videos.isNotEmpty ? freshCase.videos.first : null);
      if (fresh != null) {
        videoPath = fresh.url;
        videoFileName = fresh.fileName;
      }
    }

    final rcImages = <String>[];
    final rcFileNames = <String?>[];
    for (var i = 0; i < request.rcImages.length; i++) {
      final path = request.rcImages[i];
      if (MediaPathHelper.isLocal(path)) {
        rcImages.add(path);
        rcFileNames.add(null);
        continue;
      }
      final fresh = _findMediaBySlot(freshCase.rcImages, path) ??
          (i < freshCase.rcImages.length ? freshCase.rcImages[i] : null);
      if (fresh != null) {
        rcImages.add(fresh.url);
        rcFileNames.add(fresh.fileName);
      } else {
        rcImages.add(path);
        rcFileNames.add(MediaUploadFilename.slotKey(path));
      }
    }

    return _UpdateMediaBundle(
      imagePaths: imagePaths,
      imageFileNames: imageFileNames,
      videoPath: videoPath,
      videoFileName: videoFileName,
      rcImages: rcImages,
      rcFileNames: rcFileNames,
    );
  }

  CaseMedia? _findMediaBySlot(List<CaseMedia> mediaList, String stalePath) {
    final slot = MediaUploadFilename.slotKey(stalePath);
    if (slot == null) return null;

    for (final media in mediaList) {
      final mediaSlot = MediaUploadFilename.slotKey(media.fileName) ??
          MediaUploadFilename.slotKey(media.url);
      if (mediaSlot == slot) return media;
    }
    return null;
  }

  void _ensureAllMediaResolved({
    required List<String> requested,
    required List<String> resolved,
  }) {
    final expected = requested.where((p) => p.trim().isNotEmpty).length;
    if (expected > 0 && resolved.length < expected) {
      throw Exception(StringHelper.existingMediaPrepareFailed);
    }
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

  Future<void> _attachResolvedFiles(
    http.MultipartRequest multipart, {
    required String field,
    required List<String> paths,
    List<String?>? serverFileNames,
  }) async {
    for (var i = 0; i < paths.length; i++) {
      final serverName =
          serverFileNames != null && i < serverFileNames.length
              ? serverFileNames[i]
              : null;
      final filename = MediaUploadFilename.forField(
        field,
        i,
        serverFileName: serverName,
        localPath: paths[i],
      );
      final file = await _multipartFile(
        field,
        paths[i],
        filename: filename,
      );
      if (file != null) {
        multipart.files.add(file);
      }
    }
  }

  Future<http.MultipartFile?> _multipartFile(
    String field,
    String path, {
    String? filename,
  }) async {
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

    final resolvedFilename = filename?.trim();
    final segments = uploadPath.split(Platform.pathSeparator);
    final uploadFilename = resolvedFilename != null && resolvedFilename.isNotEmpty
        ? resolvedFilename
        : (segments.isNotEmpty ? segments.last : 'upload');
    return http.MultipartFile.fromPath(
      field,
      uploadPath,
      filename: uploadFilename,
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

class _UpdateMediaBundle {
  const _UpdateMediaBundle({
    required this.imagePaths,
    required this.imageFileNames,
    required this.videoPath,
    required this.videoFileName,
    required this.rcImages,
    required this.rcFileNames,
  });

  final List<String> imagePaths;
  final List<String?> imageFileNames;
  final String? videoPath;
  final String? videoFileName;
  final List<String> rcImages;
  final List<String?> rcFileNames;

  factory _UpdateMediaBundle.fromRequest(CreateCaseRequest request) {
    return _UpdateMediaBundle(
      imagePaths: List<String>.from(request.imagePaths),
      imageFileNames: List<String?>.filled(request.imagePaths.length, null),
      videoPath: request.videoPath,
      videoFileName: null,
      rcImages: List<String>.from(request.rcImages),
      rcFileNames: List<String?>.filled(request.rcImages.length, null),
    );
  }
}
