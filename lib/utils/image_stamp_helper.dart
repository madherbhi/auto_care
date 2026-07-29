import 'dart:io';
import 'dart:math' as math;

import 'package:auto_care/features/vehicle/models/vehicle_image_capture.dart';
import 'package:auto_care/utils/capture_metadata_service.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Draws compass + metadata text onto a vehicle photo file.
class ImageStampHelper {
  ImageStampHelper._();

  static Future<String> stampVehicleImage({
    required String sourcePath,
    required VehicleImageMetadata metadata,
  }) async {
    final bytes = await File(sourcePath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return sourcePath;

    final stamped = drawStampedImage(decoded, metadata);
    final outputDir = await getApplicationDocumentsDirectory();
    final stampedDir = Directory(p.join(outputDir.path, 'stamped_vehicle_images'));
    if (!stampedDir.existsSync()) {
      stampedDir.createSync(recursive: true);
    }

    final outputPath = p.join(
      stampedDir.path,
      'vehicle_${metadata.indexNumber}_${metadata.capturedAt.millisecondsSinceEpoch}.jpg',
    );
    await File(outputPath).writeAsBytes(
      img.encodeJpg(stamped, quality: 92),
      flush: true,
    );
    return outputPath;
  }

  /// Returns a copy of [source] with compass and metadata overlays applied.
  static img.Image drawStampedImage(
    img.Image source,
    VehicleImageMetadata metadata,
  ) {
    final image = img.copyResize(
      source,
      width: source.width,
      height: source.height,
    );
    drawOverlays(image, metadata);
    return image;
  }

  /// Transparent PNG sized for burning onto video frames.
  static img.Image buildOverlayPng({
    required int width,
    required int height,
    required VehicleImageMetadata metadata,
  }) {
    final overlay = img.Image(width: width, height: height, numChannels: 4);
    drawOverlays(overlay, metadata);
    return overlay;
  }

  static void drawOverlays(img.Image image, VehicleImageMetadata metadata) {
    final scale = image.width / 1280.0;
    _drawCompass(image, metadata.headingDegrees, scale);
    _drawMetadataText(image, metadata, scale);
  }

  static void _drawCompass(img.Image image, double? heading, double scale) {
    final size = (110 * scale).round().clamp(72, 180);
    final margin = (16 * scale).round();
    final centerX = margin + size ~/ 2;
    final centerY = margin + size ~/ 2;
    final radius = size ~/ 2;

    for (var y = margin; y < margin + size; y++) {
      for (var x = margin; x < margin + size; x++) {
        final dx = x - centerX;
        final dy = y - centerY;
        if (dx * dx + dy * dy <= radius * radius) {
          image.setPixelRgba(x, y, 30, 30, 30, 170);
        }
      }
    }

    img.drawCircle(
      image,
      x: centerX,
      y: centerY,
      radius: radius,
      color: img.ColorRgba8(255, 255, 255, 80),
    );

    const labels = ['N', 'E', 'S', 'W'];
    const angles = [0.0, 90.0, 180.0, 270.0];
    final font = img.arial14;
    for (var i = 0; i < labels.length; i++) {
      final radians = (angles[i] - 90) * math.pi / 180;
      final lx = centerX + (radius - 18 * scale).round() * math.cos(radians);
      final ly = centerY + (radius - 18 * scale).round() * math.sin(radians);
      _drawShadowText(
        image,
        labels[i],
        lx.round() - 4,
        ly.round() - 7,
        font,
        img.ColorRgba8(255, 255, 255, 255),
      );
    }

    if (heading != null) {
      final needleRadians = (heading - 90) * math.pi / 180;
      final needleLength = (radius - 14 * scale).round();
      final tipX = centerX + needleLength * math.cos(needleRadians);
      final tipY = centerY + needleLength * math.sin(needleRadians);
      img.drawLine(
        image,
        x1: centerX,
        y1: centerY,
        x2: tipX.round(),
        y2: tipY.round(),
        color: img.ColorRgba8(33, 150, 243, 255),
        thickness: (4 * scale).round().clamp(2, 6),
      );
    }
  }

  static void _drawMetadataText(
    img.Image image,
    VehicleImageMetadata metadata,
    double scale,
  ) {
    final font = scale >= 1 ? img.arial24 : img.arial14;
    final lineHeight = (font.lineHeight + 4 * scale).round();
    final margin = (16 * scale).round();
    final lines = CaptureMetadataService.overlayLines(metadata);

    var y = image.height - margin - lines.length * lineHeight;
    for (final line in lines) {
      final x = image.width - margin - _textWidth(line, font);
      _drawShadowText(
        image,
        line,
        x,
        y,
        font,
        img.ColorRgba8(255, 255, 255, 255),
      );
      y += lineHeight;
    }
  }

  static int _textWidth(String text, img.BitmapFont font) {
    var width = 0;
    for (final codeUnit in text.codeUnits) {
      final glyph = font.characters[codeUnit];
      width += glyph?.xAdvance ?? font.base ~/ 2;
    }
    return width;
  }

  static void _drawShadowText(
    img.Image image,
    String text,
    int x,
    int y,
    img.BitmapFont font,
    img.Color color,
  ) {
    const shadowOffsets = <(int, int)>[(1, 1), (-1, 1), (1, -1), (-1, -1)];
    for (final (ox, oy) in shadowOffsets) {
      img.drawString(
        image,
        text,
        font: font,
        x: x + ox,
        y: y + oy,
        color: img.ColorRgba8(0, 0, 0, 220),
      );
    }
    img.drawString(
      image,
      text,
      font: font,
      x: x,
      y: y,
      color: color,
    );
  }
}
