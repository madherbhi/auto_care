import 'dart:io';

import 'package:auto_care/utils/media_path_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Resolves form media paths into local files for multipart upload.
/// Remote URLs are downloaded to a temp file before upload.
abstract final class MediaUploadResolver {
  MediaUploadResolver._();

  static final CacheManager _cache = DefaultCacheManager();

  static Future<List<String>> resolveForUpload(
    Iterable<String> paths, {
    required List<String> tempFilesToCleanup,
    String? authToken,
  }) async {
    final resolved = <String>[];
    for (final path in paths) {
      final trimmed = path.trim();
      if (trimmed.isEmpty) continue;

      if (MediaPathHelper.isLocal(trimmed)) {
        resolved.add(trimmed);
        continue;
      }

      final cached = await _fromCache(trimmed);
      if (cached != null) {
        resolved.add(cached);
        continue;
      }

      final local = await _downloadRemote(trimmed, authToken: authToken);
      if (local != null) {
        resolved.add(local);
        tempFilesToCleanup.add(local);
      } else {
        debugPrint('[MEDIA_UPLOAD] Skipped remote: $trimmed');
      }
    }
    return resolved;
  }

  static Future<String?> _fromCache(String url) async {
    try {
      final cached = await _cache.getFileFromCache(url);
      if (cached != null && await cached.file.exists()) {
        debugPrint('[MEDIA_UPLOAD] Using cache (${cached.file.path})');
        return cached.file.path;
      }
    } catch (e) {
      debugPrint('[MEDIA_UPLOAD] Cache miss: $e');
    }
    return null;
  }

  static Future<String?> _downloadRemote(
    String url, {
    String? authToken,
  }) async {
    try {
      final headers = <String, String>{};
      if (!_isPresignedUrl(url)) {
        final token = authToken?.trim() ?? '';
        if (token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }
      }

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(minutes: 5));
      if (response.statusCode != 200) {
        debugPrint(
          '[MEDIA_UPLOAD] HTTP ${response.statusCode} for $url',
        );
        return null;
      }

      final tempDir = await getTemporaryDirectory();
      final fileName = _fileNameFromUrl(
        url,
        contentType: response.headers['content-type'],
      );
      final file = File(p.join(tempDir.path, 'upload_$fileName'));
      await file.writeAsBytes(response.bodyBytes);
      debugPrint('[MEDIA_UPLOAD] Temp file ${response.bodyBytes.length} bytes');
      return file.path;
    } catch (e) {
      debugPrint('[MEDIA_UPLOAD] Download error: $e');
      return null;
    }
  }

  static String _fileNameFromUrl(String url, {String? contentType}) {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    for (final segment in segments.reversed) {
      if (_hasKnownMediaExtension(segment)) return segment;
    }
    final ext = _extensionFromContentType(contentType) ?? '.jpg';
    return 'remote_media_${DateTime.now().millisecondsSinceEpoch}$ext';
  }

  static bool _hasKnownMediaExtension(String name) {
    final lower = name.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.mp4') ||
        lower.endsWith('.mov');
  }

  static bool _isPresignedUrl(String url) {
    final query = Uri.parse(url).queryParameters;
    return query.containsKey('X-Amz-Signature') ||
        query.containsKey('X-Amz-Algorithm');
  }

  static String? _extensionFromContentType(String? contentType) {
    final lower = contentType?.split(';').first.trim().toLowerCase() ?? '';
    if (lower == 'image/jpeg') return '.jpg';
    if (lower == 'image/png') return '.png';
    if (lower == 'image/webp') return '.webp';
    if (lower == 'video/mp4') return '.mp4';
    if (lower == 'video/quicktime') return '.mov';
    return null;
  }

  static Future<void> deleteTempFiles(Iterable<String> paths) async {
    for (final path in paths) {
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
  }
}
