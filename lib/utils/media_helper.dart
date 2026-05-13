import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class MediaHelper {
  MediaHelper._();

  static const int maxImages = 6;

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

  static Future<String?> captureVideo() async {
    if (!await _ensureCameraPermission() || !await _ensureMicrophonePermission()) {
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

  static Future<String?> pickLicenceImage(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
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
              title: const Text('Capture from camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return null;
    if (source == ImageSource.camera) return captureImage();
    return pickImageFromGallery();
  }
}
