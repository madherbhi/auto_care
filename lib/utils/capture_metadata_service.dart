import 'dart:async';
import 'dart:io';

import 'package:auto_care/models/vehicle_image_capture.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Collects live GPS, compass, and geocoding data for vehicle photo overlays.
class CaptureMetadataService {
  CaptureMetadataService._();

  static int _indexCounter = 21000;

  static int nextIndexNumber() => ++_indexCounter;

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
    double? headingOverride,
  }) async {
    final capturedAt = DateTime.now();
    final index = indexNumber ?? nextIndexNumber();

    double? latitude;
    double? longitude;
    double? altitudeMeters;
    double? speedKmh;
    double? heading = headingOverride;
    String? city;
    String? pincode;
    String? addressLine;

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
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

          final lat = latitude;
          final lng = longitude;
          final placemarks = await placemarkFromCoordinates(lat, lng);
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
          // Keep partial metadata when GPS/geocoding is unavailable.
        }
      }
    }

    if (heading == null && !kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      heading = await _readCurrentCompassHeading();
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

  static Future<double?> _readCurrentCompassHeading() async {
    try {
      if (FlutterCompass.events == null) return null;
      final event = await FlutterCompass.events!.first.timeout(
        const Duration(seconds: 2),
      );
      final value = event.heading;
      if (value == null || value.isNaN) return null;
      return value < 0 ? (360 + value) % 360 : value % 360;
    } catch (_) {
      return null;
    }
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) return value.trim();
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

/// Streams compass heading for live camera overlay.
class CompassHeadingStream {
  StreamSubscription<CompassEvent>? _subscription;
  final _controller = StreamController<double>.broadcast();

  Stream<double> get stream => _controller.stream;

  void start() {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;
    if (FlutterCompass.events == null) return;
    _subscription?.cancel();
    _subscription = FlutterCompass.events!.listen((event) {
      final heading = event.heading;
      if (heading == null || heading.isNaN) return;
      final normalized = heading < 0 ? (360 + heading) % 360 : heading % 360;
      _controller.add(normalized);
    });
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
