import 'dart:io';

import 'package:auto_care/constants/app_layout.dart';
import 'package:auto_care/utils/auth_navigation.dart';
import 'package:auto_care/utils/color_helper.dart';
import 'package:auto_care/utils/font_helper.dart';
import 'package:auto_care/utils/media_path_helper.dart';
import 'package:auto_care/utils/string_helper.dart';
import 'package:auto_care/widgets/auth_shell.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:video_player/video_player.dart';

bool _hasMediaPath(String? path) {
  if (path == null || path.trim().isEmpty) return false;
  if (MediaPathHelper.isRemote(path)) return true;
  return File(path).existsSync();
}

Widget _mediaImage({
  required String path,
  required BoxFit fit,
  double? width,
  double? height,
}) {
  if (MediaPathHelper.isRemote(path)) {
    return CachedNetworkImage(
      imageUrl: path,
      fit: fit,
      width: width,
      height: height,
      placeholder: (_, __) => const ColoredBox(
        color: ColorHelper.black,
        child: Center(
          child: CircularProgressIndicator(
            color: ColorHelper.white,
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (_, __, ___) => ColoredBox(
        color: Color.lerp(ColorHelper.primaryBlue, ColorHelper.white, 0.14)!
            .withValues(alpha: 0.35),
        child: Icon(
          Icons.broken_image_outlined,
          color: ColorHelper.white.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  final file = File(path);
  if (file.existsSync()) {
    return Image.file(
      file,
      fit: fit,
      width: width,
      height: height,
    );
  }

  return ColoredBox(
    color: Color.lerp(ColorHelper.primaryBlue, ColorHelper.white, 0.14)!
        .withValues(alpha: 0.35),
    child: Icon(
      Icons.broken_image_outlined,
      color: ColorHelper.white.withValues(alpha: 0.7),
    ),
  );
}

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
          onPressed: () => logoutToStartingPage(),
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
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

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

  bool get _hasVideo => _hasMediaPath(widget.videoPath);

  bool get _isRemoteVideo =>
      widget.videoPath != null && MediaPathHelper.isRemote(widget.videoPath!);

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
    final path = widget.videoPath!;
    final controller = _isRemoteVideo
        ? VideoPlayerController.networkUrl(Uri.parse(path))
        : VideoPlayerController.file(File(path));
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
         ],
        ),
      ),
    );
  }
}

class VehicleFormSectionLabel extends StatelessWidget {
  const VehicleFormSectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: const EdgeInsets.only(left: AuthFieldLayout.labelInsetLeft),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: FontHelper.poppinsSemiBold,
          color: ColorHelper.white.withValues(alpha: AuthFieldLayout.labelAlpha),
          fontSize: AuthFieldResponsive.labelFontSize(w),
          letterSpacing: AuthFieldLayout.labelLetterSpacing,
          height: AuthFieldLayout.labelLineHeight,
        ),
      ),
    );
  }
}

/// Photo grid: 5 numbered slots first, then an “Add more” tile after the 5th photo.
class VehicleImageSlotGrid extends StatelessWidget {
  const VehicleImageSlotGrid({
    super.key,
    required this.imagePaths,
    required this.onAdd,
    required this.onRemove,
  });

  static const int maxInitialSlots = 5;

  final List<String> imagePaths;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  static const _gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
    childAspectRatio: 1,
  );

  @override
  Widget build(BuildContext context) {
    final photoCount = imagePaths.length;
    final hasFivePhotos = photoCount >= maxInitialSlots;

    // Before 5 photos: show empty slots + one active slot to tap.
    // After 5 photos: show all photos + one trailing “Add more” tile.
    final cellCount = hasFivePhotos ? photoCount + 1 : maxInitialSlots + 1;
    final addMoreCellIndex = hasFivePhotos ? photoCount : maxInitialSlots;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: _gridDelegate,
      itemCount: cellCount,
      itemBuilder: (context, index) {
        if (index == addMoreCellIndex) {
          return _AddMoreImageTile(
            enabled: hasFivePhotos,
            onTap: hasFivePhotos ? onAdd : null,
          );
        }
        if (index < photoCount) {
          return _VehicleImageTile(
            path: imagePaths[index],
            slotNumber: index + 1,
            onRemove: () => onRemove(index),
            onTap: onAdd,
          );
        }
        return _EmptyImageSlot(
          slotNumber: index + 1,
          onTap: index == photoCount ? onAdd : null,
        );
      },
    );
  }
}

/// “+ Add more” cell — fixed at slot 6 until five images exist, then trails the grid.
class _AddMoreImageTile extends StatelessWidget {
  const _AddMoreImageTile({
    required this.enabled,
    this.onTap,
  });

  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: Color.lerp(ColorHelper.primaryBlue, ColorHelper.white, 0.14)!
            .withValues(alpha: enabled ? 0.45 : 0.25),
        border: Border.all(
          color: enabled
              ? ColorHelper.white.withValues(alpha: 0.65)
              : ColorHelper.white.withValues(alpha: 0.25),
          width: enabled ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_circle_outline_rounded,
            size: 34,
            color: ColorHelper.white.withValues(alpha: enabled ? 0.95 : 0.45),
          ),
          const Gap(6),
          Text(
            StringHelper.addMoreImages,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: FontHelper.poppinsSemiBold,
              fontSize: 12,
              color: ColorHelper.white.withValues(alpha: enabled ? 0.95 : 0.45),
            ),
          ),
        ],
      ),
    );

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: enabled && onTap != null
            ? Material(
                color: Colors.transparent,
                child: InkWell(onTap: onTap, child: content),
              )
            : content,
      ),
    );
  }
}

class _EmptyImageSlot extends StatelessWidget {
  const _EmptyImageSlot({
    required this.slotNumber,
    this.onTap,
  });

  final int slotNumber;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = DecoratedBox(
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
            '$slotNumber',
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
      child: onTap != null
          ? GestureDetector(onTap: onTap, child: child)
          : Opacity(opacity: 0.45, child: child),
    );
  }
}

class _VehicleImageTile extends StatelessWidget {
  const _VehicleImageTile({
    required this.path,
    required this.slotNumber,
    required this.onRemove,
    this.onTap,
  });

  final String path;
  final int slotNumber;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final image = _hasMediaPath(path)
        ? _mediaImage(
            path: path,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          )
        : ColoredBox(
            color: Color.lerp(ColorHelper.primaryBlue, ColorHelper.white, 0.14)!
                .withValues(alpha: 0.35),
            child: Icon(
              Icons.broken_image_outlined,
              color: ColorHelper.white.withValues(alpha: 0.7),
            ),
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            image,
            Positioned(
              left: 6,
              bottom: 6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: ColorHelper.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Text(
                    '$slotNumber',
                    style: const TextStyle(
                      fontFamily: FontHelper.poppinsMedium,
                      color: ColorHelper.white,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Material(
                color: ColorHelper.black.withValues(alpha: 0.55),
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onRemove,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      color: ColorHelper.white,
                      size: 18,
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

class VehicleRcUploadSection extends StatelessWidget {
  const VehicleRcUploadSection({
    super.key,
    required this.frontPath,
    required this.backPath,
    required this.onUploadFront,
    required this.onUploadBack,
  });

  final String? frontPath;
  final String? backPath;
  final VoidCallback onUploadFront;
  final VoidCallback onUploadBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VehicleRcSideCard(
          label: StringHelper.rcFrontLabel,
          previewHint: StringHelper.rcFrontPreview,
          imagePath: frontPath,
          uploadLabel: StringHelper.uploadRcFront,
          onUpload: onUploadFront,
        ),
        const Gap(12),
        VehicleRcSideCard(
          label: StringHelper.rcBackLabel,
          previewHint: StringHelper.rcBackPreview,
          imagePath: backPath,
          uploadLabel: StringHelper.uploadRcBack,
          onUpload: onUploadBack,
        ),
      ],
    );
  }
}

class VehicleRcSideCard extends StatelessWidget {
  const VehicleRcSideCard({
    super.key,
    required this.label,
    required this.previewHint,
    required this.imagePath,
    required this.uploadLabel,
    required this.onUpload,
  });

  final String label;
  final String previewHint;
  final String? imagePath;
  final String uploadLabel;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final hasImage = _hasMediaPath(imagePath);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VehicleFormSectionLabel(label: label),
        const Gap(8),
        ClipRRect(
          borderRadius: BorderRadius.circular(AuthFieldLayout.radius),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: GestureDetector(
              onTap: onUpload,
              child: hasImage
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        _mediaImage(path: imagePath!, fit: BoxFit.cover),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: ColorHelper.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.edit_outlined,
                                color: ColorHelper.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          ColorHelper.primaryBlue,
                          ColorHelper.white,
                          0.14,
                        )!
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
                            previewHint,
                            style: TextStyle(
                              fontFamily: FontHelper.poppinsMedium,
                              fontSize: 14,
                              color: ColorHelper.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
        const Gap(8),
        VehicleMediaActionButton(
          label: uploadLabel,
          onPressed: onUpload,
        ),
      ],
    );
  }
}

void showVehicleFormSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
