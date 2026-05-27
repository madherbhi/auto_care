import 'dart:io';

import 'package:auto_care/features/vehicle/models/vehicle_image_capture.dart';
import 'package:auto_care/utils/image_stamp_helper.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

/// Burns compass + GPS metadata overlays onto a vehicle video file.
class VideoStampHelper {
  VideoStampHelper._();

  static Future<String> stampVehicleVideo({
    required String sourcePath,
    required VehicleImageMetadata metadata,
  }) async {
    final dimensions = await _readVideoDimensions(sourcePath);
    if (dimensions == null) return sourcePath;

    final overlayBytes = img.encodePng(
      ImageStampHelper.buildOverlayPng(
        width: dimensions.width,
        height: dimensions.height,
        metadata: metadata,
      ),
    );

    final outputDir = await getApplicationDocumentsDirectory();
    final stampedDir = Directory(p.join(outputDir.path, 'stamped_vehicle_videos'));
    if (!stampedDir.existsSync()) {
      stampedDir.createSync(recursive: true);
    }

    final workDir = Directory(
      p.join(stampedDir.path, 'work_${metadata.capturedAt.millisecondsSinceEpoch}'),
    );
    workDir.createSync(recursive: true);

    final overlayPath = p.join(workDir.path, 'overlay.png');

    await File(overlayPath).writeAsBytes(overlayBytes, flush: true);

    try {
      workDir.deleteSync(recursive: true);
    } catch (_) {
      // Best-effort cleanup.
    }

 
    return sourcePath;
  }

  static Future<({int width, int height})?> _readVideoDimensions(
    String path,
  ) async {
    final controller = VideoPlayerController.file(File(path));
    try {
      await controller.initialize();
      final size = controller.value.size;
      final width = size.width.round();
      final height = size.height.round();
      if (width <= 0 || height <= 0) return null;
      return (width: width, height: height);
    } catch (_) {
      return null;
    } finally {
      await controller.dispose();
    }
  }
}
