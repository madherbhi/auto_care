import 'dart:io';

import 'package:auto_care/constants/app_layout.dart';
import 'package:auto_care/utils/media_helper.dart';
import 'package:auto_care/starting_page.dart';
import 'package:auto_care/utils/color_helper.dart';
import 'package:auto_care/utils/font_helper.dart';
import 'package:auto_care/utils/navigation_helper.dart';
import 'package:auto_care/utils/string_helper.dart';
import 'package:auto_care/widgets/auth_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:video_player/video_player.dart';

class VehicleFormAppBar extends StatelessWidget implements PreferredSizeWidget {
  const VehicleFormAppBar({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ColorHelper.primaryBlue,
      foregroundColor: ColorHelper.white,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: ColorHelper.white,
          size: AuthScreenLayout.appBarBackIconSize,
        ),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: AuthScreenLayout.appBarLeadingMinWidth,
          minHeight: AuthScreenLayout.appBarLeadingMinHeight,
        ),
      ),
      title: Text(
        title,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontFamily: FontHelper.poppinsSemiBold,
          color: ColorHelper.white,
          fontSize: 16,
          height: 1.2,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              appRoute<void>(const StartingPage()),
              (_) => false,
            );
          },
          icon: const Icon(Icons.logout_rounded, color: ColorHelper.white),
          tooltip: StringHelper.logout,
        ),
      ],
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: ColorHelper.primaryBlue,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }
}

class VehicleMediaActionButton extends StatelessWidget {
  const VehicleMediaActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: AuthPillButton(
        label: label,
        foreground: ColorHelper.primaryBlue,
        compact: true,
        onPressed: onPressed,
      ),
    );
  }
}

class VehicleFormSaveBar extends StatelessWidget {
  const VehicleFormSaveBar({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final padH = AuthResponsive.horizontalPadding(MediaQuery.sizeOf(context).width);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        padH,
        8,
        padH,
        12 + MediaQuery.paddingOf(context).bottom * 0.25,
      ),
      child: AuthPillButton(
        label: label,
        foreground: ColorHelper.primaryBlue,
        onPressed: onPressed,
      ),
    );
  }
}

class VehicleVideoPreview extends StatefulWidget {
  const VehicleVideoPreview({
    super.key,
    this.videoPath,
    this.ownerContact,
  });

  final String? videoPath;
  final String? ownerContact;

  @override
  State<VehicleVideoPreview> createState() => _VehicleVideoPreviewState();
}

class _VehicleVideoPreviewState extends State<VehicleVideoPreview> {
  VideoPlayerController? _controller;

  bool get _hasVideo =>
      widget.videoPath != null && File(widget.videoPath!).existsSync();

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(covariant VehicleVideoPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoPath != widget.videoPath) {
      _disposeController();
      _initController();
    }
  }

  void _initController() {
    if (!_hasVideo) return;
    final controller = VideoPlayerController.file(File(widget.videoPath!));
    _controller = controller;
    controller.initialize().then((_) {
      if (!mounted || _controller != controller) return;
      controller.setLooping(true);
      setState(() {});
    }).catchError((_) {
      if (!mounted || _controller != controller) return;
      setState(() {});
    });
    controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  void _disposeController() {
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    _disposeController();
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

  Widget _buildVideoSurface() {
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      );
    }
    return const ColoredBox(
      color: ColorHelper.black,
      child: Center(
        child: CircularProgressIndicator(
          color: ColorHelper.white,
          strokeWidth: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ownerContact = widget.ownerContact;
    final showPlayOverlay =
        _controller == null || !_controller!.value.isPlaying;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AuthFieldLayout.radius),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_hasVideo)
              GestureDetector(
                onTap: _togglePlayback,
                child: _buildVideoSurface(),
              )
            else
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.lerp(ColorHelper.accentYellow, ColorHelper.white, 0.2)!,
                      Color.lerp(ColorHelper.primaryBlue, ColorHelper.accentYellow, 0.35)!,
                    ],
                  ),
                ),
                child: const Center(
                  child: Text(
                    StringHelper.videoClipPreview,
                    style: TextStyle(
                      fontFamily: FontHelper.poppinsSemiBold,
                      fontSize: 16,
                      color: ColorHelper.white,
                    ),
                  ),
                ),
              ),
            if (_hasVideo && showPlayOverlay)
              IgnorePointer(
                child: ColoredBox(
                  color: ColorHelper.black.withValues(alpha: 0.25),
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_fill_rounded,
                      color: ColorHelper.white,
                      size: 56,
                    ),
                  ),
                ),
              ),
            if (ownerContact != null && ownerContact.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 12,
                child: Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: ColorHelper.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      child: Text(
                        'tel:$ownerContact',
                        style: const TextStyle(
                          fontFamily: FontHelper.poppinsMedium,
                          fontSize: 13,
                          color: ColorHelper.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class VehicleImageSlotGrid extends StatelessWidget {
  const VehicleImageSlotGrid({
    super.key,
    required this.imagePaths,
    this.maxSlots = MediaHelper.maxImages,
    this.onSlotTap,
  });

  final List<String> imagePaths;
  final int maxSlots;
  final VoidCallback? onSlotTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: maxSlots,
      itemBuilder: (context, index) {
        final hasImage = index < imagePaths.length;
        final path = hasImage ? imagePaths[index] : null;
        final slot = hasImage && path != null && File(path).existsSync()
            ? Image.file(File(path), fit: BoxFit.cover)
            : DecoratedBox(
                decoration: BoxDecoration(
                  color: Color.lerp(ColorHelper.primaryBlue, ColorHelper.white, 0.14)!
                      .withValues(alpha: 0.35),
                  border: Border.all(
                    color: ColorHelper.white.withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 28,
                      color: ColorHelper.white.withValues(alpha: 0.75),
                    ),
                    const Gap(4),
                    Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontFamily: FontHelper.poppinsMedium,
                        fontSize: 11,
                        color: ColorHelper.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              );
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: GestureDetector(
            onTap: onSlotTap,
            child: slot,
          ),
        );
      },
    );
  }
}

class VehicleLicencePreview extends StatelessWidget {
  const VehicleLicencePreview({
    super.key,
    this.licenceImagePath,
    this.onTap,
  });

  final String? licenceImagePath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasImage =
        licenceImagePath != null && File(licenceImagePath!).existsSync();
    final preview = hasImage
        ? Image.file(File(licenceImagePath!), fit: BoxFit.cover)
        : DecoratedBox(
            decoration: BoxDecoration(
              color: Color.lerp(ColorHelper.primaryBlue, ColorHelper.white, 0.14)!
                  .withValues(alpha: 0.35),
              border: Border.all(
                color: ColorHelper.white.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.badge_outlined,
                  size: 40,
                  color: ColorHelper.white.withValues(alpha: 0.75),
                ),
                const Gap(8),
                Text(
                  StringHelper.licencePreview,
                  style: TextStyle(
                    fontFamily: FontHelper.poppinsMedium,
                    fontSize: 14,
                    color: ColorHelper.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          );
    return ClipRRect(
      borderRadius: BorderRadius.circular(AuthFieldLayout.radius),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: GestureDetector(
          onTap: onTap,
          child: preview,
        ),
      ),
    );
  }
}

void showVehicleFormSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
