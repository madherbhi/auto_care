import 'package:auto_care/utils/color_helper.dart';
import 'package:auto_care/utils/font_helper.dart';
import 'package:flutter/material.dart';

abstract final class AppSnackbar {
  AppSnackbar._();

  static void success(BuildContext context, String message) {
    _show(context, message, backgroundColor: ColorHelper.successGreen);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, backgroundColor: ColorHelper.errorRed);
  }

  static void _show(
    BuildContext context,
    String message, {
    required Color backgroundColor,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: FontHelper.poppinsMedium,
              color: ColorHelper.white,
            ),
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
