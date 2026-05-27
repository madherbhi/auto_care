import 'dart:async';
import 'dart:io';

import 'package:auto_care/features/vehicle/models/vehicle_image_capture.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

/// GPS, compass, and address data for vehicle photo overlays.
class CaptureMetadataService {
  CaptureMetadataService._();

  static int _indexCounter = 21000;

  static int nextIndexNumber() => ++_indexCounter;

  /// Text lines shown on camera preview and burned into the saved image.
  static List<String> overlayLines(VehicleImageMetadata metadata) {
    return [
      DateFormat('dd/MM/yyyy h:mm a').format(metadata.capturedAt),
      headingLabel(metadata.headingDegrees),
      formatCoordinates(metadata.latitude, metadata.longitude),
      formatLocationLine(metadata),
      'Altitude:${formatAltitude(metadata.altitudeMeters)}',
      'Speed:${formatSpeed(metadata.speedKmh)}',
      'Index number: ${metadata.indexNumber}',
    ];
  }

  static String formatAltitude(double? meters) {
    if (meters == null) return '--m';
    return '${meters.toStringAsFixed(1)}m';
  }

  static String formatSpeed(double? kmh) {
    if (kmh == null) return '--km/h';
    return '${kmh.toStringAsFixed(1)}km/h';
  }

  static Future<bool> ensureLocationPermission() async {
    if (kIsWeb) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      await openAppSettings();
      return false;
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  static Future<bool> isLocationServiceEnabled() async {
    if (kIsWeb) return false;
    return Geolocator.isLocationServiceEnabled();
  }

  static Future<VehicleImageMetadata> collectSnapshot({
    int? indexNumber,
    double? headingDegrees,
  }) async {
    final capturedAt = DateTime.now();
    final index = indexNumber ?? nextIndexNumber();

    double? latitude;
    double? longitude;
    double? altitudeMeters;
    double? speedKmh;
    double? heading = headingDegrees;
    String? city;
    String? pincode;
    String? addressLine;

    final canReadLocation = !kIsWeb &&
        (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

    if (canReadLocation) {
      final hasPermission = await ensureLocationPermission();
      if (hasPermission && await isLocationServiceEnabled()) {
        try {
          final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 8),
            ),
          );

          latitude = position.latitude;
          longitude = position.longitude;
          altitudeMeters = position.altitude;
          if (position.speed >= 0) {
            speedKmh = position.speed * 3.6;
          }
          if (heading == null && position.heading >= 0) {
            heading = position.heading;
          }

          final placemarks = await placemarkFromCoordinates(
            latitude,
            longitude,
          );
          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            city = _firstNonEmpty([
              place.locality,
              place.subAdministrativeArea,
              place.administrativeArea,
            ]);
            pincode = place.postalCode;
            addressLine = _firstNonEmpty([
              place.street,
              place.subLocality,
              place.name,
            ]);
          }
        } catch (_) {
          // Keep whatever data we already have.
        }
      }
    }

    if (heading == null && !kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      heading = await _readCompassOnce();
    }

    return VehicleImageMetadata(
      capturedAt: capturedAt,
      indexNumber: index,
      latitude: latitude,
      longitude: longitude,
      altitudeMeters: altitudeMeters,
      speedKmh: speedKmh,
      headingDegrees: heading,
      city: city,
      pincode: pincode,
      addressLine: addressLine,
    );
  }

  /// Live compass updates for the camera screen.
  static Stream<double>? compassHeadingStream() {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return null;
    final events = FlutterCompass.events;
    if (events == null) return null;

    return events.map((event) => normalizeHeading(event.heading)).where((h) => h != null).cast<double>();
  }

  static double? normalizeHeading(double? heading) {
    if (heading == null || heading.isNaN) return null;
    if (heading < 0) return (360 + heading) % 360;
    return heading % 360;
  }

  static Future<double?> _readCompassOnce() async {
    try {
      final events = FlutterCompass.events;
      if (events == null) return null;

      final event = await events.first.timeout(const Duration(seconds: 2));
      return normalizeHeading(event.heading);
    } catch (_) {
      return null;
    }
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  static String headingLabel(double? degrees) {
    if (degrees == null) return '--° --';
    final normalized = degrees % 360;
    const labels = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((normalized + 22.5) / 45).floor() % 8;
    return '${normalized.round()}° ${labels[index]}';
  }

  static String formatCoordinates(double? lat, double? lng) {
    if (lat == null || lng == null) return 'Location unavailable';
    final latDir = lat >= 0 ? 'N' : 'S';
    final lngDir = lng >= 0 ? 'E' : 'W';
    return '${lat.abs().toStringAsFixed(5)}° $latDir, ${lng.abs().toStringAsFixed(5)}° $lngDir';
  }

  static String formatLocationLine(VehicleImageMetadata metadata) {
    final city = metadata.city;
    final pincode = metadata.pincode;
    if (city != null && pincode != null) return '$city, $pincode';
    if (city != null) return city;
    if (pincode != null) return pincode;
    return formatCoordinates(metadata.latitude, metadata.longitude);
  }
}
