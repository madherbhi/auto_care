import 'package:auto_care/constants/app_layout.dart';
import 'package:auto_care/features/Authentication/login_page.dart';
import 'package:auto_care/features/Authentication/register_page.dart';
import 'package:auto_care/widgets/custom_action_button.dart';
import 'package:flutter/material.dart';

import 'package:auto_care/utils/color_helper.dart';
import 'package:auto_care/utils/font_helper.dart';
import 'package:auto_care/utils/image_helper.dart';
import 'package:auto_care/utils/starting_layout_scale.dart';
import 'package:auto_care/utils/string_helper.dart';
import 'package:gap/gap.dart';

class StartingPage extends StatelessWidget {
  const StartingPage({super.key}); 

  @override
  Widget build(BuildContext context) {
    final scale = StartingLayoutScope.fromScreenWidth(
      MediaQuery.sizeOf(context).width,
    );

    return StartingLayoutScope(
      scale: scale,
      child: Scaffold(
        backgroundColor: ColorHelper.white,
        body: SafeArea(
          child: Builder(
            builder: (innerCtx) {
              final horizontalPad = StartingPageLayout.horizontalPadding * scale;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPad,
                        StartingPageLayout.scrollVerticalPadding * scale,
                        horizontalPad,
                        StartingPageLayout.scrollVerticalPadding * scale,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Gap(StartingPageLayout.gapAfterLogo * scale),
                          const _HeaderBlock(),
                          Gap(StartingPageLayout.gapAfterHeader * scale),
                          SizedBox(
                            height: StartingPageLayout.heroBlockHeight * scale,
                            child: const Center(child: _HeroIllustration()),
                          ),
                          Gap(StartingPageLayout.gapAfterHero * scale),
                          CustomActionButton(
                            label: StringHelper.login,
                            leading: Icons.person_outline_rounded,
                            trailing: Icons.arrow_forward_rounded,
                            background: ColorHelper.primaryBlue,
                            foreground: ColorHelper.white,
                            border: null,
                            onTap: () {
                              Navigator.of(innerCtx).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const LoginPage(),
                                ),
                              );
                            },
                          ),
                          Gap(StartingPageLayout.gapBeforeRegisterPrompt * scale),
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  StringHelper.dontHaveAccountPrompt,
                                  textAlign: TextAlign.center,
                                  style: StartingLayoutScope.text(
                                    innerCtx,
                                    FontHelper.taglineSmall(
                                      ColorHelper.darkGray,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(innerCtx).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => const RegisterPage(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    StringHelper.registerLink,
                                    style: StartingLayoutScope.text(
                                      innerCtx,
                                      FontHelper.taglineSmall(
                                        ColorHelper.primaryBlue,
                                      ).copyWith(
                                        decoration: TextDecoration.underline,
                                        decorationColor:
                                            ColorHelper.primaryBlue,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPad,
                      0,
                      horizontalPad,
                      StartingPageLayout.footerBottomPadding * scale,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _FooterFeatureBar(),
                        Gap(StartingPageLayout.gapAboveCopyright * scale),
                        Text(
                          StringHelper.copyright,
                          textAlign: TextAlign.center,
                          style: StartingLayoutScope.text(
                            innerCtx,
                            FontHelper.caption(ColorHelper.mediumGray),
                          ),
                        ),
                        Gap(StartingPageLayout.gapBelowCopyright * scale),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HeaderBlock extends StatelessWidget {
  const _HeaderBlock();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
          ImageHelper.logo,
          width: double.infinity,
          height:
              StartingPageLayout.logoHeight * StartingLayoutScope.scaleOf(context),
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
        ));
      
  }
}

class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration();

  @override
  Widget build(BuildContext context) {
    const s = StartingLayoutScope.s;
    final w = s(context, StartingPageLayout.heroCanvasWidth);
    final h = s(context, StartingPageLayout.heroCanvasHeight);

    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _HeroBackdropPainter(StartingLayoutScope.scaleOf(context)),
            ),
          ),
          Positioned(
            bottom: s(context, StartingPageLayout.heroSkylineBottom),
            left: s(context, StartingPageLayout.heroSkylineHorizontal),
            right: s(context, StartingPageLayout.heroSkylineHorizontal),
            child: _skylineRow(context),
          ),
          const _FloatingNode(
            dTop: StartingHeroFloatingOffsets.cameraTop,
            dLeft: StartingHeroFloatingOffsets.cameraLeft,
            icon: Icons.photo_camera_outlined,
          ),
          const _FloatingNode(
            dBottom: StartingHeroFloatingOffsets.carBottom,
            dLeft: StartingHeroFloatingOffsets.carLeft,
            icon: Icons.directions_car_outlined,
          ),
          const _FloatingNode(
            dTop: StartingHeroFloatingOffsets.truckTop,
            dRight: StartingHeroFloatingOffsets.truckRight,
            icon: Icons.local_shipping_outlined,
          ),
          const _FloatingNode(
            dBottom: StartingHeroFloatingOffsets.factoryBottom,
            dRight: StartingHeroFloatingOffsets.factoryRight,
            icon: Icons.precision_manufacturing_outlined,
          ),
          Center(
            child: SizedBox(
              width: s(context, StartingPageLayout.heroCenterWidth),
              height: s(context, StartingPageLayout.heroCenterHeight),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: s(context, StartingPageLayout.heroCardOffsetTop),
                    child: Container(
                      width: s(context, StartingPageLayout.heroCardWidth),
                      height: s(context, StartingPageLayout.heroCardHeight),
                      decoration: BoxDecoration(
                        color: ColorHelper.white,
                        borderRadius: BorderRadius.circular(
                          s(context, StartingPageLayout.heroCardRadius),
                        ),
                        border: Border.all(
                          color: ColorHelper.primaryBlue,
                          width: s(context, StartingPageLayout.heroCardBorderWidth),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ColorHelper.primaryBlue.withValues(alpha: 0.08),
                            blurRadius:
                                s(context, StartingPageLayout.heroCardShadowBlur),
                            offset: Offset(
                              0,
                              s(context, StartingPageLayout.heroCardShadowOffsetY),
                            ),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: s(context, StartingPageLayout.heroCardInnerTopGap),
                          ),
                          ...List.generate(
                            StartingPageLayout.heroCardLineCount,
                            (_) => Padding(
                              padding: EdgeInsets.only(
                                bottom: s(
                                  context,
                                  StartingPageLayout.heroCardLineSpacingBottom,
                                ),
                                left: s(
                                  context,
                                  StartingPageLayout.heroCardLineHorizontalInset,
                                ),
                                right: s(
                                  context,
                                  StartingPageLayout.heroCardLineHorizontalInset,
                                ),
                              ),
                              child: Container(
                                height: s(context, StartingPageLayout.heroCardLineHeight),
                                decoration: BoxDecoration(
                                  color: ColorHelper.accentYellow,
                                  borderRadius: BorderRadius.circular(
                                    s(context, StartingPageLayout.heroCardLineRadius),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    child: Container(
                      width: s(context, StartingPageLayout.heroTabWidth),
                      height: s(context, StartingPageLayout.heroTabHeight),
                      decoration: BoxDecoration(
                        color: ColorHelper.primaryBlue,
                        borderRadius: BorderRadius.circular(
                          s(context, StartingPageLayout.heroTabRadius),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -s(context, StartingPageLayout.heroShieldIconInsetRight),
                    bottom: s(context, StartingPageLayout.heroShieldIconBottom),
                    child: ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) => const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          ColorHelper.accentYellow,
                          ColorHelper.primaryBlue,
                        ],
                      ).createShader(bounds),
                      child: Icon(
                        Icons.shield_rounded,
                        size: s(context, StartingPageLayout.heroShieldIconSize),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skylineRow(BuildContext context) {
    const s = StartingLayoutScope.s;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(
        StartingPageLayout.skylineBarCount,
        (i) => Container(
          width: s(
            context,
            StartingPageLayout.skylineBarWidthBase +
                (i % 3) * StartingPageLayout.skylineBarWidthStep,
          ),
          height: s(
            context,
            StartingPageLayout.skylineBarHeightBase +
                (i % 4) * StartingPageLayout.skylineBarHeightStep,
          ),
          decoration: BoxDecoration(
            color: ColorHelper.heroBackdrop.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(
              s(context, StartingPageLayout.skylineBarRadius),
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingNode extends StatelessWidget {
  const _FloatingNode({
    required this.icon,
    this.dTop,
    this.dBottom,
    this.dLeft,
    this.dRight,
  });

  final IconData icon;
  final double? dTop;
  final double? dBottom;
  final double? dLeft;
  final double? dRight;

  @override
  Widget build(BuildContext context) {
    const s = StartingLayoutScope.s;
    final child = Container(
      width: s(context, StartingPageLayout.floatingNodeSize),
      height: s(context, StartingPageLayout.floatingNodeSize),
      decoration: BoxDecoration(
        color: ColorHelper.white,
        borderRadius: BorderRadius.circular(
          s(context, StartingPageLayout.floatingNodeRadius),
        ),
        border: Border.all(color: ColorHelper.lightGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: s(context, StartingPageLayout.floatingNodeShadowBlur),
            offset: Offset(0, s(context, StartingPageLayout.floatingNodeShadowOffsetY)),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: s(context, StartingPageLayout.floatingNodeIconSize),
        color: ColorHelper.primaryBlue,
      ),
    );

    return Positioned(
      top: dTop != null ? s(context, dTop!) : null,
      bottom: dBottom != null ? s(context, dBottom!) : null,
      left: dLeft != null ? s(context, dLeft!) : null,
      right: dRight != null ? s(context, dRight!) : null,
      child: child,
    );
  }
}

class _HeroBackdropPainter extends CustomPainter {
  _HeroBackdropPainter(this.scale);

  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = ColorHelper.heroBackdrop.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    final spacing = StartingPageLayout.heroDotGridSpacing * scale;
    final radius = StartingPageLayout.heroDotRadius * scale;
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HeroBackdropPainter oldDelegate) =>
      oldDelegate.scale != scale;
}

class _FooterFeatureBar extends StatelessWidget {
  const _FooterFeatureBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: StartingPageLayout.footerBarVerticalPadding,
        horizontal: StartingPageLayout.footerBarHorizontalPadding,
      ),
      decoration: BoxDecoration(
        color: ColorHelper.footerBarBg,
        borderRadius: BorderRadius.circular(StartingPageLayout.footerBarRadius),
      ),
      child: const Row(
        children: [
          Expanded(
            child: _FooterItem(
              iconWidget: _ShieldLockIcon(),
              label: StringHelper.secureFeature,
            ),
          ),
          Expanded(
            child: _FooterItem(
              icon: Icons.access_time_rounded,
              label: StringHelper.realtimeReports,
            ),
          ),
          Expanded(
            child: _FooterItem(
              icon: Icons.cloud_upload_outlined,
              label: StringHelper.easySimple,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShieldLockIcon extends StatelessWidget {
  const _ShieldLockIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: StartingPageLayout.footerShieldStackSize,
      width: StartingPageLayout.footerShieldStackSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.shield_outlined,
            size: StartingPageLayout.footerShieldStackSize,
            color: ColorHelper.primaryBlue,
          ),
          Positioned(
            bottom: StartingPageLayout.footerShieldLockBottom,
            child: Icon(
              Icons.lock_outline_rounded,
              size: StartingPageLayout.footerShieldLockSize,
              color: ColorHelper.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterItem extends StatelessWidget {
  const _FooterItem({
    this.icon,
    this.iconWidget,
    required this.label,
  }) : assert(icon != null || iconWidget != null);

  final IconData? icon;
  final Widget? iconWidget;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconWidget ??
            Icon(
              icon,
              size: StartingPageLayout.footerItemIconSize,
              color: ColorHelper.primaryBlue,
            ),
        const SizedBox(height: StartingPageLayout.footerItemGapBelowIcon),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: FontHelper.footerLabel(ColorHelper.darkGray),
        ),
      ],
    );
  }
}
