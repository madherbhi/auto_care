import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:auto_care/models/vehicle_image_capture.dart';
import 'package:auto_care/utils/capture_metadata_service.dart';
import 'package:auto_care/utils/color_helper.dart';
import 'package:auto_care/utils/font_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Top-left compass overlay shown during live camera capture.
class CaptureCompassOverlay extends StatelessWidget {
  const CaptureCompassOverlay({
    super.key,
    required this.heading,
    this.size = 96,
  });

  final double? heading;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CompassPainter(heading: heading),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  _CompassPainter({required this.heading});

  final double? heading;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()..color = const Color(0xAA1E1E1E),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    const labels = ['N', 'E', 'S', 'W'];
    const angles = [0.0, 90.0, 180.0, 270.0];
    for (var i = 0; i < labels.length; i++) {
      final radians = (angles[i] - 90) * math.pi / 180;
      final labelCenter = Offset(
        center.dx + (radius - 16) * math.cos(radians),
        center.dy + (radius - 16) * math.sin(radians),
      );
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(color: Colors.black, blurRadius: 2, offset: Offset(0.5, 0.5)),
            ],
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        labelCenter - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    if (heading != null) {
      final radians = (heading! - 90) * math.pi / 180;
      final tip = Offset(
        center.dx + (radius - 14) * math.cos(radians),
        center.dy + (radius - 14) * math.sin(radians),
      );
      canvas.drawLine(
        center,
        tip,
        Paint()
          ..color = const Color(0xFF2196F3)
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) {
    return oldDelegate.heading != heading;
  }
}

/// Bottom-right metadata overlay shown during live camera capture.
class CaptureMetadataOverlay extends StatelessWidget {
  const CaptureMetadataOverlay({
    super.key,
    required this.metadata,
  });

  final VehicleImageMetadata metadata;

  @override
  Widget build(BuildContext context) {
    final lines = [
      DateFormat('dd/MM/yyyy h:mm a').format(metadata.capturedAt),
      CaptureMetadataService.headingLabel(metadata.headingDegrees),
      CaptureMetadataService.formatCoordinates(
        metadata.latitude,
        metadata.longitude,
      ),
      CaptureMetadataService.formatLocationLine(metadata),
      'Altitude:${_formatAltitude(metadata.altitudeMeters)}',
      'Speed:${_formatSpeed(metadata.speedKmh)}',
      'Index number: ${metadata.indexNumber}',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: lines
          .map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                line,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: FontHelper.poppinsMedium,
                  color: ColorHelper.white,
                  fontSize: 12,
                  height: 1.15,
                  shadows: [
                    Shadow(
                      color: Colors.black87,
                      blurRadius: 3,
                      offset: Offset(0.5, 0.5),
                    ),
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 1,
                      offset: Offset(-0.5, -0.5),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  static String _formatAltitude(double? meters) {
    if (meters == null) return '--m';
    return '${meters.toStringAsFixed(1)}m';
  }

  static String _formatSpeed(double? kmh) {
    if (kmh == null) return '--km/h';
    return '${kmh.toStringAsFixed(1)}km/h';
  }
}
