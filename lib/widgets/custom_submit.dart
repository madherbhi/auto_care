import 'package:flutter/material.dart';
import 'package:auto_care/utils/color_helper.dart';

class SubmitButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String title;
  final bool isLoading;
  final double padding;
  final double height;
  final Color bgColor;
  final double? elevation;
  final Color? textColor;
  final bool capitalizeText;
  final double? fontSize;
  final FontWeight? fontWeight;

  const SubmitButton({
    super.key,
    this.onPressed,
    required this.title,
    this.isLoading = false,
    this.padding = 35.0,
    this.height = 50.0,
    this.bgColor = ColorHelper.primaryBlue,
    this.elevation,
    this.textColor,
    this.capitalizeText = true,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        style: TextButton.styleFrom(
            foregroundColor: ColorHelper.primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                10,
              ),
            ),
            backgroundColor: !isLoading ? bgColor : Colors.grey,
            disabledBackgroundColor: Colors.grey[300],
            elevation: elevation),
        onPressed: !isLoading ? onPressed : null,
        child: Padding(
          padding: EdgeInsets.only(left: padding, right: padding),
          child: isLoading
              ? Container(
                  width: 24,
                  height: 24,
                  padding: const EdgeInsets.all(2.0),
                  child: const CircularProgressIndicator(
                    color: ColorHelper.white,
                    strokeWidth: 3,
                  ),
                )
              : Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: ColorHelper.white, fontSize: 16),
                ),
        ),
      ),
    );
  }
}
