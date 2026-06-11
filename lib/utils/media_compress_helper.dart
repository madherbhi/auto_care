import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';

/// Ensures local images and videos are at most [maxUploadBytes] before upload.
abstract final class MediaCompressHelper {
  MediaCompressHelper._();

  static const int maxUploadBytes = 300 * 1024 * 1024;

  /// Returns [path] or a compressed copy under the app temp directory.
  static Future<String> prepareForUpload(String path) async {
    if (kIsWeb) return path;

    final file = File(path);
    if (!await file.exists()) return path;

    final originalSize = await file.length();
    if (originalSize <= maxUploadBytes) return path;

    final lower = path.toLowerCase();
    if (_isVideoPath(lower)) {
      return _compressVideo(path, originalSize);
    }
    if (_isImagePath(lower)) {
      return _compressImage(path, originalSize);
    }

    debugPrint(
      '[MEDIA_COMPRESS] Skipping unknown type ($originalSize bytes): $path',
    );
    return path;
  }

  static bool _isVideoPath(String lower) =>
      lower.endsWith('.mp4') ||
      lower.endsWith('.mov') ||
      lower.endsWith('.m4v') ||
      lower.endsWith('.avi');

  static bool _isImagePath(String lower) =>
      lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.png') ||
      lower.endsWith('.webp');

  static Future<Directory> _compressDir() async {
    final base = await getTemporaryDirectory();
    final dir = Directory(p.join(base.path, 'upload_compress'));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  static Future<String> _compressImage(String path, int originalSize) async {
    debugPrint(
      '[MEDIA_COMPRESS] Image ${(originalSize / (1024 * 1024)).toStringAsFixed(1)} MB => $path',
    );

    final bytes = await File(path).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      debugPrint('[MEDIA_COMPRESS] Could not decode image, uploading as-is');
      return path;
    }

    var working = decoded;
    const maxLongEdge = 2560;
    const minLongEdge = 1280;
    final longEdge = working.width > working.height ? working.width : working.height;

    if (longEdge > maxLongEdge) {
      working = img.copyResize(
        working,
        width: working.width >= working.height ? maxLongEdge : null,
        height: working.height > working.width ? maxLongEdge : null,
      );
    }

    final outputDir = await _compressDir();
    final baseName = p.basenameWithoutExtension(path);
    final outputPath = p.join(
      outputDir.path,
      '${baseName}_compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    for (var scalePass = 0; scalePass < 4; scalePass++) {
      for (var quality = 92; quality >= 58; quality -= 6) {
        final encoded = img.encodeJpg(working, quality: quality);
        if (encoded.length <= maxUploadBytes) {
          await File(outputPath).writeAsBytes(encoded, flush: true);
          debugPrint(
            '[MEDIA_COMPRESS] Image compressed to '
            '${(encoded.length / (1024 * 1024)).toStringAsFixed(2)} MB '
            '(q=$quality, ${working.width}x${working.height})',
          );
          return outputPath;
        }
      }

      final currentLong =
          working.width > working.height ? working.width : working.height;
      if (currentLong <= minLongEdge) break;

      final nextLong = (currentLong * 0.82).round().clamp(minLongEdge, maxLongEdge);
      working = img.copyResize(
        working,
        width: working.width >= working.height ? nextLong : null,
        height: working.height > working.width ? nextLong : null,
      );
    }

    throw Exception(
      'Image is too large to upload (max 300 MB). Try a smaller photo.',
    );
  }

  static Future<String> _compressVideo(String path, int originalSize) async {
    debugPrint(
      '[MEDIA_COMPRESS] Video ${(originalSize / (1024 * 1024)).toStringAsFixed(1)} MB => $path',
    );

    const qualities = <VideoQuality>[
      VideoQuality.Res1920x1080Quality,
      VideoQuality.DefaultQuality,
      VideoQuality.Res1280x720Quality,
      VideoQuality.MediumQuality,
      VideoQuality.Res960x540Quality,
      VideoQuality.LowQuality,
      VideoQuality.Res640x480Quality,
    ];

    String? bestPath;
    int? bestSize;

    for (final quality in qualities) {
      final info = await VideoCompress.compressVideo(
        path,
        quality: quality,
        deleteOrigin: false,
        includeAudio: true,
      );

      final compressedPath = info?.path?.trim();
      if (compressedPath == null || compressedPath.isEmpty) continue;

      final compressed = File(compressedPath);
      if (!await compressed.exists()) continue;

      final size = await compressed.length();
      debugPrint(
        '[MEDIA_COMPRESS] Video try $quality => '
        '${(size / (1024 * 1024)).toStringAsFixed(2)} MB',
      );

      if (size <= maxUploadBytes) {
        if (compressedPath != path) {
          final saved = await _persistCompressedVideo(compressedPath);
          return saved;
        }
        return path;
      }

      if (bestSize == null || size < bestSize) {
        bestSize = size;
        bestPath = compressedPath;
      }
    }

    if (bestPath != null &&
        bestSize != null &&
        bestSize <= maxUploadBytes) {
      return _persistCompressedVideo(bestPath);
    }

    throw Exception(
      'Video is too large to upload (max 300 MB). Record a shorter clip.',
    );
  }

  static Future<String> _persistCompressedVideo(String sourcePath) async {
    if (sourcePath == '') return sourcePath;

    final source = File(sourcePath);
    if (!await source.exists()) return sourcePath;

    final outputDir = await _compressDir();
    final ext = p.extension(sourcePath).isEmpty ? '.mp4' : p.extension(sourcePath);
    final destPath = p.join(
      outputDir.path,
      'video_${DateTime.now().millisecondsSinceEpoch}$ext',
    );
    await source.copy(destPath);
    return destPath;
  }
}
