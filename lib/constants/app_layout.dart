import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Global — baseline width, splash, anything shared across the app.
// ---------------------------------------------------------------------------

/// Figma / baseline device width. Used with [MediaQuery] for responsive math.
abstract final class AppLayout {
  AppLayout._();

  static const double designWidth = 390;

  static const Duration splashDisplayDuration = Duration(seconds: 3);

  static const double splashHeroIconSize = 150;
}

// ---------------------------------------------------------------------------
// Typography — pixel sizes at design scale. [FontHelper] turns these into
// [TextStyle] so type sizes live next to layout numbers.
// ---------------------------------------------------------------------------

abstract final class AppTypography {
  AppTypography._();

  static const double headingBold = 22;
  static const double headingBoldHeight = 1.05;
  static const double headingBoldLetterSpacing = 1.4;

  static const double subHeading = 12;
  static const double subHeadingHeight = 1.25;

  static const double button = 14;
  static const double buttonLetterSpacing = 1.1;

  static const double caption = 11;
  static const double captionHeight = 1.2;

  static const double taglineSmall = 13;
  static const double taglineSmallLetterSpacing = 0.2;

  static const double footerLabel = 11;
  static const double footerLabelHeight = 1.15;
}

// ---------------------------------------------------------------------------
// Starting page — values multiplied by layout scale in the UI.
// ---------------------------------------------------------------------------

abstract final class StartingPageLayout {
  StartingPageLayout._();

  static const double horizontalPadding = 22;
  static const double scrollVerticalPadding = 12;
  static const double footerBottomPadding = 12;

  static const double gapAfterLogo = 8;
  static const double gapAfterHeader = 16;
  static const double gapAfterHero = 8;
  static const double gapBeforeRegisterPrompt = 20;
  static const double gapAboveCopyright = 14;
  static const double gapBelowCopyright = 8;

  static const double logoHeight = 160;
  static const double heroBlockHeight = 248;

  static const double heroCanvasWidth = 280;
  static const double heroCanvasHeight = 240;
  static const double heroSkylineBottom = 12;
  static const double heroSkylineHorizontal = 24;

  static const double heroCenterWidth = 150;
  static const double heroCenterHeight = 170;
  static const double heroCardOffsetTop = 8;
  static const double heroCardWidth = 118;
  static const double heroCardHeight = 138;
  static const double heroCardRadius = 14;
  static const double heroCardBorderWidth = 2.4;
  static const double heroCardShadowBlur = 18;
  static const double heroCardShadowOffsetY = 10;
  static const double heroCardInnerTopGap = 18;
  static const int heroCardLineCount = 4;
  static const double heroCardLineSpacingBottom = 10;
  static const double heroCardLineHorizontalInset = 16;
  static const double heroCardLineHeight = 5;
  static const double heroCardLineRadius = 3;

  static const double heroTabWidth = 44;
  static const double heroTabHeight = 22;
  static const double heroTabRadius = 8;

  static const double heroShieldIconInsetRight = 6;
  static const double heroShieldIconBottom = 18;
  static const double heroShieldIconSize = 58;

  static const double heroDotGridSpacing = 22;
  static const double heroDotRadius = 1.2;

  static const double footerBarVerticalPadding = 16;
  static const double footerBarHorizontalPadding = 10;
  static const double footerBarRadius = 14;

  static const double footerShieldStackSize = 28;
  static const double footerShieldLockBottom = 5;
  static const double footerShieldLockSize = 12;

  static const double footerItemIconSize = 26;
  static const double footerItemGapBelowIcon = 8;

  static const double floatingNodeSize = 40;
  static const double floatingNodeRadius = 10;
  static const double floatingNodeShadowBlur = 8;
  static const double floatingNodeShadowOffsetY = 3;
  static const double floatingNodeIconSize = 22;

  static const double skylineBarWidthBase = 10;
  static const double skylineBarWidthStep = 6;
  static const double skylineBarHeightBase = 16;
  static const double skylineBarHeightStep = 8;
  static const double skylineBarRadius = 2;
  static const int skylineBarCount = 9;
}

/// Design-pixel offsets for hero “floating” icons (scaled in the widget).
abstract final class StartingHeroFloatingOffsets {
  StartingHeroFloatingOffsets._();

  static const double cameraTop = 18;
  static const double cameraLeft = 12;

  static const double carBottom = 52;
  static const double carLeft = 0;

  static const double truckTop = 28;
  static const double truckRight = 8;

  static const double factoryBottom = 48;
  static const double factoryRight = 0;
}

// ---------------------------------------------------------------------------
// Primary CTA on starting page (scaled).
// ---------------------------------------------------------------------------

abstract final class StartingPrimaryButtonLayout {
  StartingPrimaryButtonLayout._();

  static const double height = 52;
  static const double radius = 12;
  static const double horizontalPadding = 18;
  static const double iconSize = 22;
  static const double gapIconToLabel = 12;
}

// ---------------------------------------------------------------------------
// Auth screens (login / register) — responsive padding, gaps, type scale.
// ---------------------------------------------------------------------------

abstract final class AuthScreenLayout {
  AuthScreenLayout._();

  static const double screenPadWidthFraction = 0.08;
  static const double screenPadHMin = 20;
  static const double screenPadHMax = 40;

  static const double screenPadHeightFraction = 0.03;
  static const double screenPadVMin = 12;
  static const double screenPadVMax = 28;

  static const double formMaxWidthFraction = 0.92;
  static const double formMaxWidthMin = 280;
  static const double formMaxWidthMax = 420;

  static const double scrollBottomExtra = 8;

  static const double loginFormMinHeightFraction = 0.72;
  static const double registerFormMinHeightFraction = 0.65;

  static const double titleFontDesignLogin = 32;
  static const double titleFontDesignRegister = 28;
  static const double titleWidthScaleMin = 0.85;
  static const double titleWidthScaleMax = 1.15;
  static const double titleSizeMinLogin = 26;
  static const double titleSizeMaxLogin = 38;
  static const double titleSizeMinRegister = 24;
  static const double titleSizeMaxRegister = 34;

  static const double subtitleFontDesign = 13;
  static const double subtitleWidthScaleMin = 0.85;
  static const double subtitleWidthScaleMax = 1.12;
  static const double subtitleSizeMin = 12;
  static const double subtitleSizeMax = 15;

  static const double titleLineHeight = 1.1;
  static const double titleLetterSpacing = 0.3;
  static const double subtitleLineHeight = 1.3;
  static const double subtitleAlpha = 0.78;

  static const double gapAfterTitleFraction = 0.008;
  static const double gapAfterTitleMin = 4;
  static const double gapAfterTitleMax = 10;

  static const double gapBeforeFieldsLoginFraction = 0.038;
  static const double gapBeforeFieldsLoginMin = 20;
  static const double gapBeforeFieldsLoginMax = 34;

  static const double gapBeforeFieldsRegisterFraction = 0.032;
  static const double gapBeforeFieldsRegisterMin = 18;
  static const double gapBeforeFieldsRegisterMax = 30;

  static const double gapFieldBlockFraction = 0.028;
  static const double gapFieldBlockMin = 16;
  static const double gapFieldBlockMax = 28;

  static const double gapFieldBlockMedRegisterFraction = 0.022;
  static const double gapFieldBlockMedRegisterMin = 14;
  static const double gapFieldBlockMedRegisterMax = 24;

  static const double gapFieldBlockMedLoginFraction = 0.028;
  static const double gapFieldBlockMedLoginMin = 14;
  static const double gapFieldBlockMedLoginMax = 26;

  static const double gapAfterFieldsLoginFraction = 0.045;
  static const double gapAfterFieldsLoginMin = 22;
  static const double gapAfterFieldsLoginMax = 38;

  static const double gapAfterFieldsRegisterFraction = 0.038;
  static const double gapAfterFieldsRegisterMin = 20;
  static const double gapAfterFieldsRegisterMax = 34;

  static const double gapForgotPasswordFraction = 0.014;
  static const double gapForgotPasswordMin = 6;
  static const double gapForgotPasswordMax = 14;

  static const double forgotPasswordHitVertical = 4;
  static const double forgotPasswordHitHorizontal = 4;

  static const double appBarBackIconSize = 22;
  static const double appBarLeadingMinWidth = 40;
  static const double appBarLeadingMinHeight = 40;

  static const double linkPromptAlpha = 0.82;
}

/// Shared field chrome for [AuthLoginField] / [AuthLoginDropdown].
abstract final class AuthFieldLayout {
  AuthFieldLayout._();

  static const double radius = 18;

  static const double labelFontDesign = 11;
  static const double labelWidthScaleMin = 0.85;
  static const double labelWidthScaleMax = 1.15;
  static const double labelSizeMin = 10;
  static const double labelSizeMax = 13;

  static const double hintFontDesign = 13;
  static const double hintWidthScaleMin = 0.85;
  static const double hintWidthScaleMax = 1.12;
  static const double hintSizeMin = 12;
  static const double hintSizeMax = 15;

  static const double labelLetterSpacing = 1.6;
  static const double labelLineHeight = 1.2;
  static const double labelAlpha = 0.85;
  static const double readOnlyTextAlpha = 0.72;

  static const double gapLabelToFieldFraction = 0.028;
  static const double gapLabelToFieldMin = 8;
  static const double gapLabelToFieldMax = 12;

  static const double contentPadLWithPrefix = 4;
  static const double contentPadLDefault = 16;
  static const double contentPadVertical = 16;
  static const double contentPadRWithSuffix = 6;
  static const double contentPadRDefault = 16;
  static const double contentPadREmptyDropdown = 12;

  static const double prefixIconLeft = 14;
  static const double prefixIconRight = 10;
  static const double prefixIconSize = 22;

  static const double suffixIconSize = 22;
  static const double suffixIconMinWidth = 40;
  static const double suffixIconMinHeight = 36;

  static const double dropdownTrailingIconSize = 26;

  static const double outlineEnabledWidth = 1.0;
  static const double outlineFocusedWidth = 1.2;

  static const double labelInsetLeft = 4;

  static const double fillLerpBlue = 0.08;
  static const double fillAlpha = 0.55;
  static const double outlineEnabledAlpha = 0.18;
  static const double outlineFocusedAlpha = 0.55;
  static const double hintAlpha = 0.6;
  static const double accentIconLerp = 0.15;

  static const double menuSurfaceLerpBlack = 0.35;

  static const double rowLabelFontDesign = 12;
  static const double rowLabelWidthScaleMin = 0.85;
  static const double rowLabelWidthScaleMax = 1.12;
  static const double rowLabelSizeMin = 11;
  static const double rowLabelSizeMax = 14;

  static const double rowFieldFontDesign = 13;
  static const double rowFieldSizeMin = 12;
  static const double rowFieldSizeMax = 15;

  static const double rowLabelLineHeight = 1.25;
  static const double rowGapFraction = 0.02;
  static const double rowFieldBottomPadding = 6;
  static const double rowUnderlineWidth = 1.0;

  static const double emptyDropdownHintAlpha = 0.45;
  static const double emptyDropdownIconAlpha = 0.35;
  static const double dropdownIconAlpha = 0.85;
}

abstract final class AuthPillButtonLayout {
  AuthPillButtonLayout._();

  static const double heightFractionCompact = 0.048;
  static const double heightMinCompact = 40;
  static const double heightMaxCompact = 48;

  static const double heightFraction = 0.062;
  static const double heightMin = 48;
  static const double heightMax = 58;

  static const double fontDesignCompact = 13;
  static const double fontDesign = 14;
  static const double fontWidthScaleMin = 0.9;
  static const double fontWidthScaleMax = 1.1;

  static const double horizontalPaddingFraction = 0.06;
  static const double letterSpacingCompact = 0.6;
  static const double letterSpacing = 1.0;
}

abstract final class AuthGradientLayout {
  AuthGradientLayout._();

  static const double padWidthFraction = 0.08;
  static const double padWidthMin = 20;
  static const double padWidthMax = 40;

  static const double padHeightFraction = 0.03;
  static const double padHeightMin = 12;
  static const double padHeightMax = 28;
}

// ---------------------------------------------------------------------------
// Responsive helpers (keep formulas next to the constants they use).
// ---------------------------------------------------------------------------

abstract final class AuthResponsive {
  AuthResponsive._();

  static double _widthScale(double width) => width / AppLayout.designWidth;

  static double horizontalPadding(double screenWidth) =>
      (screenWidth * AuthScreenLayout.screenPadWidthFraction).clamp(
        AuthScreenLayout.screenPadHMin,
        AuthScreenLayout.screenPadHMax,
      );

  static double verticalPadding(double screenHeight) =>
      (screenHeight * AuthScreenLayout.screenPadHeightFraction).clamp(
        AuthScreenLayout.screenPadVMin,
        AuthScreenLayout.screenPadVMax,
      );

  static double formMaxWidth(double screenWidth) =>
      (screenWidth * AuthScreenLayout.formMaxWidthFraction).clamp(
        AuthScreenLayout.formMaxWidthMin,
        AuthScreenLayout.formMaxWidthMax,
      );

  static double loginTitleSize(double width) =>
      (AuthScreenLayout.titleFontDesignLogin *
              _widthScale(width).clamp(
                AuthScreenLayout.titleWidthScaleMin,
                AuthScreenLayout.titleWidthScaleMax,
              ))
          .clamp(
            AuthScreenLayout.titleSizeMinLogin,
            AuthScreenLayout.titleSizeMaxLogin,
          );

  static double registerTitleSize(double width) =>
      (AuthScreenLayout.titleFontDesignRegister *
              _widthScale(width).clamp(
                AuthScreenLayout.titleWidthScaleMin,
                AuthScreenLayout.titleWidthScaleMax,
              ))
          .clamp(
            AuthScreenLayout.titleSizeMinRegister,
            AuthScreenLayout.titleSizeMaxRegister,
          );

  static double authSubtitleSize(double width) =>
      (AuthScreenLayout.subtitleFontDesign *
              _widthScale(width).clamp(
                AuthScreenLayout.subtitleWidthScaleMin,
                AuthScreenLayout.subtitleWidthScaleMax,
              ))
          .clamp(
            AuthScreenLayout.subtitleSizeMin,
            AuthScreenLayout.subtitleSizeMax,
          );

  static double gapFieldBlock(double height) =>
      (height * AuthScreenLayout.gapFieldBlockFraction).clamp(
        AuthScreenLayout.gapFieldBlockMin,
        AuthScreenLayout.gapFieldBlockMax,
      );

  static double gapMedLogin(double height) =>
      (height * AuthScreenLayout.gapFieldBlockMedLoginFraction).clamp(
        AuthScreenLayout.gapFieldBlockMedLoginMin,
        AuthScreenLayout.gapFieldBlockMedLoginMax,
      );

  static double gapMedRegister(double height) =>
      (height * AuthScreenLayout.gapFieldBlockMedRegisterFraction).clamp(
        AuthScreenLayout.gapFieldBlockMedRegisterMin,
        AuthScreenLayout.gapFieldBlockMedRegisterMax,
      );

  static double gapAfterFieldsLogin(double height) =>
      (height * AuthScreenLayout.gapAfterFieldsLoginFraction).clamp(
        AuthScreenLayout.gapAfterFieldsLoginMin,
        AuthScreenLayout.gapAfterFieldsLoginMax,
      );

  static double gapAfterFieldsRegister(double height) =>
      (height * AuthScreenLayout.gapAfterFieldsRegisterFraction).clamp(
        AuthScreenLayout.gapAfterFieldsRegisterMin,
        AuthScreenLayout.gapAfterFieldsRegisterMax,
      );

  static double gapAfterTitle(double height) =>
      (height * AuthScreenLayout.gapAfterTitleFraction).clamp(
        AuthScreenLayout.gapAfterTitleMin,
        AuthScreenLayout.gapAfterTitleMax,
      );

  static double gapBeforeFieldsLogin(double height) =>
      (height * AuthScreenLayout.gapBeforeFieldsLoginFraction).clamp(
        AuthScreenLayout.gapBeforeFieldsLoginMin,
        AuthScreenLayout.gapBeforeFieldsLoginMax,
      );

  static double gapBeforeFieldsRegister(double height) =>
      (height * AuthScreenLayout.gapBeforeFieldsRegisterFraction).clamp(
        AuthScreenLayout.gapBeforeFieldsRegisterMin,
        AuthScreenLayout.gapBeforeFieldsRegisterMax,
      );

  static double gapForgotPassword(double height) =>
      (height * AuthScreenLayout.gapForgotPasswordFraction).clamp(
        AuthScreenLayout.gapForgotPasswordMin,
        AuthScreenLayout.gapForgotPasswordMax,
      );
}

abstract final class AuthFieldResponsive {
  AuthFieldResponsive._();

  static double _wFrac(double width) => width / AppLayout.designWidth;

  static double labelFontSize(double width) =>
      (AuthFieldLayout.labelFontDesign *
              _wFrac(width).clamp(
                AuthFieldLayout.labelWidthScaleMin,
                AuthFieldLayout.labelWidthScaleMax,
              ))
          .clamp(
            AuthFieldLayout.labelSizeMin,
            AuthFieldLayout.labelSizeMax,
          );

  static double hintFontSize(double width) =>
      (AuthFieldLayout.hintFontDesign *
              _wFrac(width).clamp(
                AuthFieldLayout.hintWidthScaleMin,
                AuthFieldLayout.hintWidthScaleMax,
              ))
          .clamp(
            AuthFieldLayout.hintSizeMin,
            AuthFieldLayout.hintSizeMax,
          );

  static double labelToFieldGap(double width) =>
      (width * AuthFieldLayout.gapLabelToFieldFraction).clamp(
        AuthFieldLayout.gapLabelToFieldMin,
        AuthFieldLayout.gapLabelToFieldMax,
      );

  static double rowLabelSize(double width) =>
      (AuthFieldLayout.rowLabelFontDesign *
              _wFrac(width).clamp(
                AuthFieldLayout.rowLabelWidthScaleMin,
                AuthFieldLayout.rowLabelWidthScaleMax,
              ))
          .clamp(
            AuthFieldLayout.rowLabelSizeMin,
            AuthFieldLayout.rowLabelSizeMax,
          );

  static double rowFieldSize(double width) =>
      (AuthFieldLayout.rowFieldFontDesign *
              _wFrac(width).clamp(
                AuthFieldLayout.rowLabelWidthScaleMin,
                AuthFieldLayout.rowLabelWidthScaleMax,
              ))
          .clamp(
            AuthFieldLayout.rowFieldSizeMin,
            AuthFieldLayout.rowFieldSizeMax,
          );

  static double rowGap(double width) => width * AuthFieldLayout.rowGapFraction;
}

abstract final class AuthPillResponsive {
  AuthPillResponsive._();

  static double _wFrac(double width) => width / AppLayout.designWidth;

  static double height(double screenHeight, {required bool compact}) {
    if (compact) {
      return (screenHeight * AuthPillButtonLayout.heightFractionCompact).clamp(
        AuthPillButtonLayout.heightMinCompact,
        AuthPillButtonLayout.heightMaxCompact,
      );
    }
    return (screenHeight * AuthPillButtonLayout.heightFraction).clamp(
      AuthPillButtonLayout.heightMin,
      AuthPillButtonLayout.heightMax,
    );
  }

  static double fontSize(double width, {required bool compact}) {
    final base = compact
        ? AuthPillButtonLayout.fontDesignCompact
        : AuthPillButtonLayout.fontDesign;
    return base *
        _wFrac(width).clamp(
          AuthPillButtonLayout.fontWidthScaleMin,
          AuthPillButtonLayout.fontWidthScaleMax,
        );
  }
}

abstract final class AuthGradientResponsive {
  AuthGradientResponsive._();

  static double horizontalPadding(Size size) =>
      (size.width * AuthGradientLayout.padWidthFraction).clamp(
        AuthGradientLayout.padWidthMin,
        AuthGradientLayout.padWidthMax,
      );

  static double verticalPadding(Size size) =>
      (size.height * AuthGradientLayout.padHeightFraction).clamp(
        AuthGradientLayout.padHeightMin,
        AuthGradientLayout.padHeightMax,
      );
}
