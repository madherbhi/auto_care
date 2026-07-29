import 'dart:async';
import 'dart:io';

import 'package:auto_care/features/vehicle/widgets/capture_overlay_widgets.dart';
import 'package:auto_care/features/vehicle/models/vehicle_image_capture.dart';
import 'package:auto_care/utils/capture_metadata_service.dart';
import 'package:auto_care/utils/color_helper.dart';
import 'package:auto_care/utils/string_helper.dart';
import 'package:auto_care/utils/video_stamp_helper.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Full-screen video camera with GPS/compass overlays. Returns a stamped video path.
class VehicleVideoCapturePage extends StatefulWidget {
  const VehicleVideoCapturePage({
    super.key,
    required this.indexNumber,
  });

  final int indexNumber;

  @override
  State<VehicleVideoCapturePage> createState() =>
      _VehicleVideoCapturePageState();
}

class _VehicleVideoCapturePageState extends State<VehicleVideoCapturePage> {
  CameraController? _camera;
  VehicleImageMetadata? _metadata;
  double? _heading;
  bool _loading = true;
  bool _recording = false;
  bool _processing = false;
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
        enableAudio: true,
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
      capturedAt: DateTime.now(),
    );
  }

  Future<void> _toggleRecording() async {
    final camera = _camera;
    if (camera == null ||
        !camera.value.isInitialized ||
        _processing ||
        _metadata == null) {
      return;
    }

    if (_recording) {
      await _stopRecording();
      return;
    }

    try {
      await camera.startVideoRecording();
      if (!mounted) return;
      setState(() => _recording = true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(StringHelper.videoCaptureFailed)),
      );
    }
  }

  Future<void> _stopRecording() async {
    final camera = _camera;
    final metadata = _metadataForCapture;
    if (camera == null || metadata == null) return;

    setState(() {
      _recording = false;
      _processing = true;
    });

    try {
      final clip = await camera.stopVideoRecording();
      final stampedPath = await VideoStampHelper.stampVehicleVideo(
        sourcePath: clip.path,
        metadata: metadata,
      );

      if (!mounted) return;
      Navigator.of(context).pop(stampedPath);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(StringHelper.videoCaptureFailed)),
      );
      setState(() => _processing = false);
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
    final busy = _processing;

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
                      onPressed: busy ? null : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                    ),
                    if (_recording)
                      const Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.fiber_manual_record, color: Colors.red, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'Recording',
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    else
                      const Spacer(),
                    if (busy)
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
                      onTap: busy ? null : _toggleRecording,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _recording ? Colors.red : Colors.white,
                            width: 4,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: _recording ? 28 : 58,
                            height: _recording ? 28 : 58,
                            decoration: BoxDecoration(
                              color: _recording
                                  ? Colors.red
                                  : (busy ? Colors.white54 : Colors.white),
                              borderRadius: _recording
                                  ? BorderRadius.circular(6)
                                  : null,
                              shape: _recording ? BoxShape.rectangle : BoxShape.circle,
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
