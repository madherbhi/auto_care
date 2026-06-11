import 'package:auto_care/utils/color_helper.dart';
import 'package:auto_care/utils/font_helper.dart';
import 'package:auto_care/utils/string_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class SegmentGuideVideoPage extends StatefulWidget {
  const SegmentGuideVideoPage({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  final String videoUrl;
  final String title;

  @override
  State<SegmentGuideVideoPage> createState() => _SegmentGuideVideoPageState();
}

class _SegmentGuideVideoPageState extends State<SegmentGuideVideoPage> {
  VideoPlayerController? _controller;
  var _initialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      _controller = controller;
      controller.addListener(_onControllerUpdate);
      await controller.initialize();
      if (!mounted || _controller != controller) {
        await controller.dispose();
        return;
      }
      await controller.setLooping(true);
      await controller.play();
      setState(() {
        _initialized = true;
        _errorMessage = null;
      });
    } catch (error, stack) {
      debugPrint('[SEGMENT_GUIDE_VIDEO] Failed to load: $error\n$stack');
      if (!mounted) return;
      setState(() {
        _initialized = false;
        _errorMessage = StringHelper.segmentGuideLoadFailed;
      });
    }
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final showPlayOverlay =
        _initialized && controller != null && !controller.value.isPlaying;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: ColorHelper.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: _errorMessage == null ? _togglePlayback : null,
              child: ColoredBox(
                color: ColorHelper.black,
                child: _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: FontHelper.poppinsRegular,
                              fontSize: 14,
                              color: ColorHelper.white,
                            ),
                          ),
                        ),
                      )
                    : !_initialized || controller == null
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: ColorHelper.white,
                              strokeWidth: 2,
                            ),
                          )
                        : FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: controller.value.size.width,
                              height: controller.value.size.height,
                              child: VideoPlayer(controller),
                            ),
                          ),
              ),
            ),
            if (_initialized && showPlayOverlay)
              IgnorePointer(
                child: ColoredBox(
                  color: ColorHelper.black.withValues(alpha: 0.25),
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_fill_rounded,
                      color: ColorHelper.white,
                      size: 72,
                    ),
                  ),
                ),
              ),
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: ColorHelper.white),
                  tooltip: StringHelper.cancel,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
