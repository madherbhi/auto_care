import 'package:auto_care/constants/app_layout.dart';
import 'package:flutter/material.dart';

import 'package:auto_care/utils/color_helper.dart';

class FontHelper {
  static const poppinsExtraBold = "Poppins-ExtraBold";
  static const poppinsSemiBold = "Poppins-SemiBold";
  static const poppinsBold = "Poppins-Bold";
  static const poppinsRegular = "Poppins-Regular";
  static const poppinsMedium = "Poppins-Medium";
  static const poppinsExtraLight = "Poppins-ExtraLight";
  static const poppinsLight = "Poppins-Light";
  static const poppinsThin = "Poppins-Thin";

  static TextStyle headingBold([Color? color]) => TextStyle(
        fontFamily: poppinsBold,
        fontSize: AppTypography.headingBold,
        fontWeight: FontWeight.w700,
        height: AppTypography.headingBoldHeight,
        letterSpacing: AppTypography.headingBoldLetterSpacing,
        color: color ?? ColorHelper.primaryBlue,
      );

  static TextStyle subHeading([Color? color]) => TextStyle(
        fontFamily: poppinsRegular,
        fontSize: AppTypography.subHeading,
        height: AppTypography.subHeadingHeight,
        color: color ?? ColorHelper.primaryBlue,
      );

  static TextStyle buttonText([Color? color]) => TextStyle(
        fontFamily: poppinsSemiBold,
        fontSize: AppTypography.button,
        letterSpacing: AppTypography.buttonLetterSpacing,
        color: color ?? ColorHelper.white,
      );

  static TextStyle caption([Color? color]) => TextStyle(
        fontFamily: poppinsRegular,
        fontSize: AppTypography.caption,
        height: AppTypography.captionHeight,
        color: color ?? ColorHelper.mediumGray,
      );

  static TextStyle taglineSmall([Color? color]) => TextStyle(
        fontFamily: poppinsMedium,
        fontSize: AppTypography.taglineSmall,
        letterSpacing: AppTypography.taglineSmallLetterSpacing,
        color: color ?? ColorHelper.primaryBlue,
      );

  static TextStyle footerLabel([Color? color]) => TextStyle(
        fontFamily: poppinsMedium,
        fontSize: AppTypography.footerLabel,
        height: AppTypography.footerLabelHeight,
        color: color ?? ColorHelper.darkGray,
      );
}
