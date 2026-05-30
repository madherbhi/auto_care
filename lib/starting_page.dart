import 'package:auto_care/constants/app_layout.dart';
import 'package:auto_care/features/Authentication/view/login_page.dart';
import 'package:auto_care/features/Authentication/view/register_page.dart';
import 'package:auto_care/widgets/custom_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) SystemNavigator.pop();
      },
      child: StartingLayoutScope(
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
                                MaterialPageRoute(builder: (context) =>LoginPage()),
                              );
                            },
                          ),
                          Gap(StartingPageLayout.gapBeforeRegisterPrompt * scale),
                               CustomActionButton(
                            label: StringHelper.register,
                            leading: Icons.person_add_outlined,
                            trailing: Icons.arrow_forward_rounded,
                            background: ColorHelper.white,
                            foreground: ColorHelper.primaryBlue,
                            border: const BorderSide(color: ColorHelper.buttonOutline),
                            onTap: () {
                              Navigator.of(innerCtx).push(
                           MaterialPageRoute(builder: (context) => RegisterPage()),
                              );
                            },
                          ),
                     
                          // Center(
                          //   child: Wrap(
                          //     alignment: WrapAlignment.center,
                          //     crossAxisAlignment: WrapCrossAlignment.center,
                          //     children: [
                          //       Text(
                          //         StringHelper.dontHaveAccountPrompt,
                          //         textAlign: TextAlign.center,
                          //         style: StartingLayoutScope.text(
                          //           innerCtx,
                          //           FontHelper.taglineSmall(
                          //             ColorHelper.darkGray,
                          //           ),
                          //         ),
                          //       ),
                          //       GestureDetector(
                          //         onTap: () {
                          //           Navigator.of(innerCtx).push(
                          //             MaterialPageRoute<void>(
                          //               builder: (_) => const RegisterPage(),
                          //             ),
                          //           );
                          //         },
                          //         child: Text(
                          //           StringHelper.registerLink,
                          //           style: StartingLayoutScope.text(
                          //             innerCtx,
                          //             FontHelper.taglineSmall(
                          //               ColorHelper.primaryBlue,
                          //             ).copyWith(
                          //               decoration: TextDecoration.underline,
                          //               decorationColor:
                          //                   ColorHelper.primaryBlue,
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                       
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
      ),
    );
      
  }
}

class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      ImageHelper.shield,
      width: double.infinity,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
  }
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
