import 'dart:io';

import 'package:auto_care/constants/app_layout.dart';
import 'package:auto_care/utils/media_helper.dart';
import 'package:auto_care/starting_page.dart';
import 'package:auto_care/utils/color_helper.dart';
import 'package:auto_care/utils/font_helper.dart';
import 'package:auto_care/utils/string_helper.dart';
import 'package:auto_care/widgets/auth_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

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
              MaterialPageRoute<void>(builder: (_) => const StartingPage()),
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

class VehicleVideoPreview extends StatelessWidget {
  const VehicleVideoPreview({
    super.key,
    this.videoPath,
    this.ownerContact,
  });

  final String? videoPath;
  final String? ownerContact;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AuthFieldLayout.radius),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (videoPath != null && File(videoPath!).existsSync())
              const ColoredBox(
                color: ColorHelper.black,
                child: Center(
                  child: Icon(
                    Icons.play_circle_fill_rounded,
                    color: ColorHelper.white,
                    size: 56,
                  ),
                ),
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
            if (ownerContact != null && ownerContact!.isNotEmpty)
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
  });

  final List<String> imagePaths;
  final int maxSlots;

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
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: hasImage && path != null && File(path).existsSync()
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
                ),
        );
      },
    );
  }
}

class VehicleLicencePreview extends StatelessWidget {
  const VehicleLicencePreview({super.key, this.licenceImagePath});

  final String? licenceImagePath;

  @override
  Widget build(BuildContext context) {
    final hasImage =
        licenceImagePath != null && File(licenceImagePath!).existsSync();
    return ClipRRect(
      borderRadius: BorderRadius.circular(AuthFieldLayout.radius),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: hasImage
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
