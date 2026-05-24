import 'dart:async';
import 'dart:io';

import 'package:auto_care/features/vehicle/capture_overlay_widgets.dart';
import 'package:auto_care/models/vehicle_image_capture.dart';
import 'package:auto_care/utils/capture_metadata_service.dart';
import 'package:auto_care/utils/color_helper.dart';
import 'package:auto_care/utils/image_stamp_helper.dart';
import 'package:auto_care/utils/string_helper.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Full-screen camera with live metadata overlays; returns a stamped image.
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
  CameraController? _controller;
  VehicleImageMetadata? _metadata;
  double? _heading;
  bool _initializing = true;
  bool _capturing = false;
  String? _error;
  Timer? _metadataTimer;
  final _compassStream = CompassHeadingStream();

  @override
  void initState() {
    super.initState();
    _initCamera();
    _compassStream.start();
    _compassStream.stream.listen((heading) {
      if (!mounted) return;
      setState(() => _heading = heading);
    });
    _refreshMetadata();
    _metadataTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _refreshMetadata();
    });
  }

  Future<void> _initCamera() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      setState(() {
        _error = StringHelper.cameraNotSupported;
        _initializing = false;
      });
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _error = StringHelper.cameraNotAvailable;
          _initializing = false;
        });
        return;
      }

      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _initializing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = StringHelper.cameraNotAvailable;
        _initializing = false;
      });
    }
  }

  Future<void> _refreshMetadata() async {
    final snapshot = await CaptureMetadataService.collectSnapshot(
      indexNumber: widget.indexNumber,
      headingOverride: _heading,
    );
    if (!mounted) return;
    setState(() => _metadata = snapshot);
  }

  Future<void> _capture() async {
    final controller = _controller;
    final metadata = _metadata;
    if (controller == null || !controller.value.isInitialized || metadata == null) {
      return;
    }
    if (_capturing) return;

    setState(() => _capturing = true);
    try {
      await controller.setFlashMode(FlashMode.off);
      final file = await controller.takePicture();
      final stampedPath = await ImageStampHelper.stampVehicleImage(
        sourcePath: file.path,
        metadata: metadata.copyWith(headingDegrees: _heading ?? metadata.headingDegrees),
      );
      if (!mounted) return;
      Navigator.of(context).pop(
        VehicleImageCapture(
          path: stampedPath,
          metadata: metadata.copyWith(headingDegrees: _heading ?? metadata.headingDegrees),
        ),
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
    _compassStream.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_initializing)
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
              else if (_controller != null && _controller!.value.isInitialized)
                CameraPreview(_controller!),
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
              if (_controller != null && _error == null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 20,
                  child: Center(
                    child: GestureDetector(
                      onTap: _capturing ? null : _capture,
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
