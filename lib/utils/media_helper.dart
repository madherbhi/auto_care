import 'dart:io';

import 'package:auto_care/features/vehicle/vehicle_camera_capture_page.dart';
import 'package:auto_care/models/vehicle_image_capture.dart';
import 'package:auto_care/utils/capture_metadata_service.dart';
import 'package:auto_care/utils/image_stamp_helper.dart';
import 'package:auto_care/utils/navigation_helper.dart';
import 'package:auto_care/utils/string_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class MediaHelper {
  MediaHelper._();

  static final ImagePicker _picker = ImagePicker();

  static Future<bool> _ensureCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isGranted) return true;
    status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> _ensureMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (status.isGranted) return true;
    status = await Permission.microphone.request();
    return status.isGranted;
  }

  static Future<bool> _ensurePhotosPermission() async {
    final photos = await Permission.photos.status;
    if (photos.isGranted) return true;
    if (photos.isDenied || photos.isLimited) {
      final result = await Permission.photos.request();
      if (result.isGranted || result.isLimited) return true;
    }
    final storage = await Permission.storage.status;
    if (storage.isGranted) return true;
    final storageResult = await Permission.storage.request();
    return storageResult.isGranted;
  }

  static Future<ImageSource?> pickVehicleImageSource(BuildContext context) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text(StringHelper.captureFromCamera),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text(StringHelper.chooseFromGallery),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  static Future<ImageSource?> _pickImageSource(BuildContext context) {
    return pickVehicleImageSource(context);
  }

  static Future<String?> captureVideo() async {
    if (!await _ensureCameraPermission() ||
        !await _ensureMicrophonePermission()) {
      return null;
    }
    final file = await _picker.pickVideo(source: ImageSource.camera);
    return file?.path;
  }

  static Future<String?> captureImage() async {
    if (!await _ensureCameraPermission()) return null;
    final file = await _picker.pickImage(source: ImageSource.camera);
    return file?.path;
  }

  static Future<String?> pickImageFromGallery() async {
    if (!await _ensurePhotosPermission()) return null;
    final file = await _picker.pickImage(source: ImageSource.gallery);
    return file?.path;
  }

  static Future<String?> pickImage(BuildContext context) async {
    final source = await _pickImageSource(context);
    if (source == null) return null;
    if (source == ImageSource.camera) return captureImage();
    return pickImageFromGallery();
  }

  /// Opens the camera, stamps metadata overlay, and returns the capture result.
  static Future<VehicleImageCapture?> captureVehicleImage(
    BuildContext context, {
    required int indexNumber,
  }) async {
    if (!context.mounted) return null;
    return _captureWithCustomCamera(context, indexNumber);
  }

  static Future<VehicleImageCapture?> _captureWithCustomCamera(
    BuildContext context,
    int indexNumber,
  ) async {
    if (!await _ensureCameraPermission()) return null;

    final locationGranted = await CaptureMetadataService.ensureLocationPermission();
    if (!locationGranted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(StringHelper.locationPermissionRequired)),
      );
    }

    if (!context.mounted) return null;

    final canUseCustomCamera =
        !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    if (canUseCustomCamera) {
      return Navigator.of(context).push<VehicleImageCapture>(
        appRoute(VehicleCameraCapturePage(indexNumber: indexNumber)),
      );
    }

    final path = await captureImage();
    if (path == null) return null;
    return _stampExistingImage(path, indexNumber);
  }

  static Future<VehicleImageCapture> _stampExistingImage(
    String sourcePath,
    int indexNumber,
  ) async {
    final metadata = await CaptureMetadataService.collectSnapshot(
      indexNumber: indexNumber,
    );
    final stampedPath = await ImageStampHelper.stampVehicleImage(
      sourcePath: sourcePath,
      metadata: metadata,
    );
    return VehicleImageCapture(path: stampedPath, metadata: metadata);
  }
}
