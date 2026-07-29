import 'dart:io';

import 'package:auto_care/features/vehicle/view/vehicle_camera_capture_page.dart';
import 'package:auto_care/features/vehicle/view/vehicle_video_capture_page.dart';
import 'package:auto_care/features/vehicle/models/vehicle_image_capture.dart';
import 'package:auto_care/utils/capture_metadata_service.dart';
import 'package:auto_care/utils/image_stamp_helper.dart';
import 'package:auto_care/utils/video_stamp_helper.dart';
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

  static Future<String?> captureVideo() async {
    if (!await _ensureCameraPermission() ||
        !await _ensureMicrophonePermission()) {
      return null;
    }
    final file = await _picker.pickVideo(source: ImageSource.camera);
    return file?.path;
  }

  /// Opens the video camera with GPS overlays and burns metadata into the clip.
  static Future<String?> captureVehicleVideo(
    BuildContext context, {
    required int indexNumber,
  }) async {
    if (!context.mounted) return null;
    if (!await _ensureCameraPermission() ||
        !await _ensureMicrophonePermission()) {
      return null;
    }

    final locationGranted =
        await CaptureMetadataService.ensureLocationPermission();
    if (!locationGranted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(StringHelper.locationPermissionRequired)),
      );
    }
    if (!context.mounted) return null;

    final useCustomCamera = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    if (useCustomCamera) {
      return Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (context) =>(VehicleVideoCapturePage(indexNumber: indexNumber)),
      ));
    }

    final path = await captureVideo();
    if (path == null) return null;

    final metadata = await CaptureMetadataService.collectSnapshot(
      indexNumber: indexNumber,
    );
    return VideoStampHelper.stampVehicleVideo(
      sourcePath: path,
      metadata: metadata,
    );
  }

  static Future<String?> captureImage() async {
    if (!await _ensureCameraPermission()) return null;
    final file = await _picker.pickImage(source: ImageSource.camera);
    return file?.path;
  }

  /// Uses the system photo picker — no READ_MEDIA_* / storage permission needed.
  static Future<String?> pickImageFromGallery() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    return file?.path;
  }

  static Future<String?> pickImage(BuildContext context) async {
    final source = await pickVehicleImageSource(context);
    if (source == null) return null;
    if (source == ImageSource.camera) return captureImage();
    return pickImageFromGallery();
  }

  /// Opens camera (or falls back to image picker), stamps metadata, returns result.
  static Future<VehicleImageCapture?> captureVehicleImage(
    BuildContext context, {
    required int indexNumber,
  }) async {
    if (!context.mounted) return null;
    if (!await _ensureCameraPermission()) return null;

    final locationGranted =
        await CaptureMetadataService.ensureLocationPermission();
    if (!locationGranted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(StringHelper.locationPermissionRequired)),
      );
    }
    if (!context.mounted) return null;

    final useCustomCamera = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    if (useCustomCamera) {
      return Navigator.of(context).push<VehicleImageCapture>(
        MaterialPageRoute(builder: (context) =>(VehicleCameraCapturePage(indexNumber: indexNumber)),
       ) );
    }

    final path = await captureImage();
    if (path == null) return null;

    final metadata = await CaptureMetadataService.collectSnapshot(
      indexNumber: indexNumber,
    );
    final stampedPath = await ImageStampHelper.stampVehicleImage(
      sourcePath: path,
      metadata: metadata,
    );
    return VehicleImageCapture(path: stampedPath, metadata: metadata);
  }
}
