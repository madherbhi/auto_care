import 'dart:async';
import 'dart:io';

import 'package:auto_care/features/vehicle/widgets/capture_overlay_widgets.dart';
import 'package:auto_care/features/vehicle/models/vehicle_image_capture.dart';
import 'package:auto_care/utils/capture_metadata_service.dart';
import 'package:auto_care/utils/color_helper.dart';
import 'package:auto_care/utils/image_stamp_helper.dart';
import 'package:auto_care/utils/string_helper.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Full-screen camera with GPS/compass overlays. Returns a stamped image.
class VehicleCameraCapturePage extends StatefulWidget {
  const VehicleCameraCapturePage({
    super.key,
    required this.indexNumber,
  });

  final int indexNumber;

  @override
  State<VehicleCameraCapturePage> createState() =>
      _VehicleCameraCapturePageState();
}

class _VehicleCameraCapturePageState extends State<VehicleCameraCapturePage> {
  CameraController? _camera;
  VehicleImageMetadata? _metadata;
  double? _heading;
  bool _loading = true;
  bool _capturing = false;
  String? _error;
  Timer? _metadataTimer;
  StreamSubscription<double>? _compassSubscription;

  @override
  void initState() {
    super.initState();
    _startCamera();
    _listenToCompass();
    _loadMetadata();
    _metadataTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _loadMetadata(),
    );
  }

  Future<void> _startCamera() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      setState(() {
        _error = StringHelper.cameraNotSupported;
        _loading = false;
      });
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _error = StringHelper.cameraNotAvailable;
          _loading = false;
        });
        return;
      }

      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final camera = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await camera.initialize();

      if (!mounted) {
        await camera.dispose();
        return;
      }

      setState(() {
        _camera = camera;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = StringHelper.cameraNotAvailable;
        _loading = false;
      });
    }
  }

  void _listenToCompass() {
    final stream = CaptureMetadataService.compassHeadingStream();
    if (stream == null) return;

    _compassSubscription = stream.listen((heading) {
      if (!mounted) return;
      setState(() => _heading = heading);
    });
  }

  Future<void> _loadMetadata() async {
    final snapshot = await CaptureMetadataService.collectSnapshot(
      indexNumber: widget.indexNumber,
      headingDegrees: _heading,
    );
    if (!mounted) return;
    setState(() => _metadata = snapshot);
  }

  VehicleImageMetadata? get _metadataForCapture {
    final base = _metadata;
    if (base == null) return null;
    return base.copyWith(
      headingDegrees: _heading ?? base.headingDegrees,
    );
  }

  Future<void> _capturePhoto() async {
    final camera = _camera;
    final metadata = _metadataForCapture;
    if (camera == null ||
        !camera.value.isInitialized ||
        metadata == null ||
        _capturing) {
      return;
    }

    setState(() => _capturing = true);
    try {
      await camera.setFlashMode(FlashMode.off);
      final photo = await camera.takePicture();
      final stampedPath = await ImageStampHelper.stampVehicleImage(
        sourcePath: photo.path,
        metadata: metadata,
      );

      if (!mounted) return;
      Navigator.of(context).pop(
        VehicleImageCapture(path: stampedPath, metadata: metadata),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(StringHelper.captureFailed)),
      );
      setState(() => _capturing = false);
    }
  }

  @override
  void dispose() {
    _metadataTimer?.cancel();
    _compassSubscription?.cancel();
    _camera?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraReady =
        _camera != null && _camera!.value.isInitialized && _error == null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_loading)
                const Center(
                  child: CircularProgressIndicator(color: ColorHelper.white),
                )
              else if (_error != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: ColorHelper.white),
                    ),
                  ),
                )
              else if (cameraReady)
                CameraPreview(_camera!),
              if (_metadata != null) ...[
                Positioned(
                  top: 12,
                  left: 12,
                  child: CaptureCompassOverlay(heading: _heading),
                ),
                Positioned(
                  right: 12,
                  bottom: 96,
                  child: CaptureMetadataOverlay(metadata: _metadata!),
                ),
              ],
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                    ),
                    const Spacer(),
                    if (_capturing)
                      const Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (cameraReady)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 20,
                  child: Center(
                    child: GestureDetector(
                      onTap: _capturing ? null : _capturePhoto,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Center(
                          child: Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: _capturing ? Colors.white54 : Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
