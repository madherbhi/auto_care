import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';

/// Compresses local media before upload.
///
/// Images target ~100–150 KB (hard cap [maxImageBytes]).
/// Videos target ~40–60 MB (hard cap [maxVideoBytes]).
abstract final class MediaCompressHelper {
  MediaCompressHelper._();

  static const int maxImageBytes = 150 * 1024; // 150 KB
  static const int minImageBytes = 100 * 1024; // 100 KB soft floor
  static const int maxVideoBytes = 60 * 1024 * 1024; // 60 MB
  static const int targetVideoBytes = 50 * 1024 * 1024; // prefer ~50 MB

  /// Returns [path] or a compressed copy under the app temp directory.
  static Future<String> prepareForUpload(String path) async {
    if (kIsWeb) return path;

    final file = File(path);
    if (!await file.exists()) return path;

    final originalSize = await file.length();
    final lower = path.toLowerCase();

    if (_isVideoPath(lower)) {
      if (originalSize <= maxVideoBytes) {
        debugPrint(
          '[MEDIA_COMPRESS] Video already within limit '
          '(${_fmtMb(originalSize)} MB): $path',
        );
        return path;
      }
      return _compressVideo(path, originalSize);
    }

    if (_isImagePath(lower)) {
      if (originalSize <= maxImageBytes) {
        debugPrint(
          '[MEDIA_COMPRESS] Image already within limit '
          '(${_fmtKb(originalSize)} KB): $path',
        );
        return path;
      }
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

  static String _fmtMb(int bytes) => (bytes / (1024 * 1024)).toStringAsFixed(2);
  static String _fmtKb(int bytes) => (bytes / 1024).toStringAsFixed(1);

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
      '[MEDIA_COMPRESS] Image ${_fmtKb(originalSize)} KB => $path',
    );

    final bytes = await File(path).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      debugPrint('[MEDIA_COMPRESS] Could not decode image, uploading as-is');
      return path;
    }

    var working = decoded;
    // Target ~100–150 KB: start at a modest long edge, then shrink if needed.
    const maxLongEdge = 1600;
    const minLongEdge = 640;
    final longEdge =
        working.width > working.height ? working.width : working.height;

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

    // Prefer the largest file that still fits (closest to 100–150 KB band).
    Uint8List? bestFit;
    int? bestFitSize;
    int? bestFitQuality;
    int bestFitWidth = 0;
    int bestFitHeight = 0;

    for (var scalePass = 0; scalePass < 6; scalePass++) {
      for (var quality = 85; quality >= 40; quality -= 5) {
        final encoded = img.encodeJpg(working, quality: quality);
        final size = encoded.length;

        if (size > maxImageBytes) continue;

        // First fit at this scale is the highest quality / largest size — take it.
        if (bestFit == null || size > bestFitSize!) {
          bestFit = encoded;
          bestFitSize = size;
          bestFitQuality = quality;
          bestFitWidth = working.width;
          bestFitHeight = working.height;
        }

        // In the preferred 100–150 KB band — done.
        if (size >= minImageBytes) {
          await File(outputPath).writeAsBytes(encoded, flush: true);
          debugPrint(
            '[MEDIA_COMPRESS] Image compressed to ${_fmtKb(size)} KB '
            '(q=$quality, ${working.width}x${working.height})',
          );
          return outputPath;
        }

        // Under 100 KB: keep this best fit and stop lowering quality further.
        break;
      }

      if (bestFit != null && bestFitSize! >= minImageBytes) {
        break;
      }

      final currentLong =
          working.width > working.height ? working.width : working.height;
      if (currentLong <= minLongEdge) break;

      // Only downscale further if we still have no under-cap result.
      if (bestFit != null) break;

      final nextLong =
          (currentLong * 0.78).round().clamp(minLongEdge, maxLongEdge);
      working = img.copyResize(
        working,
        width: working.width >= working.height ? nextLong : null,
        height: working.height > working.width ? nextLong : null,
      );
    }

    if (bestFit != null) {
      await File(outputPath).writeAsBytes(bestFit, flush: true);
      debugPrint(
        '[MEDIA_COMPRESS] Image compressed to ${_fmtKb(bestFitSize!)} KB '
        '(q=$bestFitQuality, ${bestFitWidth}x$bestFitHeight)',
      );
      return outputPath;
    }

    throw Exception(
      'Image is too large to upload (max 150 KB). Try a smaller photo.',
    );
  }

  static Future<String> _compressVideo(String path, int originalSize) async {
    debugPrint(
      '[MEDIA_COMPRESS] Video ${_fmtMb(originalSize)} MB => $path',
    );

    // Higher quality first so we land closer to the 40–60 MB band when possible.
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
    String? inRangePath;
    int? inRangeSize;

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
        '[MEDIA_COMPRESS] Video try $quality => ${_fmtMb(size)} MB',
      );

      if (size <= maxVideoBytes) {
        final inPreferredBand = size >= (40 * 1024 * 1024);
        if (inPreferredBand) {
          if (inRangeSize == null ||
              (size - targetVideoBytes).abs() <
                  (inRangeSize - targetVideoBytes).abs()) {
            inRangePath = compressedPath;
            inRangeSize = size;
          }
          // First in-band result is enough; stop degrading quality.
          break;
        }

        // Under 40 MB: keep the largest under-cap result (least quality loss).
        if (bestSize == null || size > bestSize) {
          bestSize = size;
          bestPath = compressedPath;
        }
        break;
      }

      if (bestSize == null || size < bestSize) {
        bestSize = size;
        bestPath = compressedPath;
      }
    }

    final chosen = inRangePath ?? bestPath;
    final chosenSize = inRangeSize ?? bestSize;

    if (chosen != null &&
        chosenSize != null &&
        chosenSize <= maxVideoBytes) {
      if (chosen != path) {
        final saved = await _persistCompressedVideo(chosen);
        debugPrint(
          '[MEDIA_COMPRESS] Video compressed to ${_fmtMb(chosenSize)} MB',
        );
        return saved;
      }
      return path;
    }

    throw Exception(
      'Video is too large to upload (max 60 MB). Record a shorter clip.',
    );
  }

  static Future<String> _persistCompressedVideo(String sourcePath) async {
    if (sourcePath == '') return sourcePath;

    final source = File(sourcePath);
    if (!await source.exists()) return sourcePath;

    final outputDir = await _compressDir();
    final ext =
        p.extension(sourcePath).isEmpty ? '.mp4' : p.extension(sourcePath);
    final destPath = p.join(
      outputDir.path,
      'video_${DateTime.now().millisecondsSinceEpoch}$ext',
    );
    await source.copy(destPath);
    return destPath;
  }
}
