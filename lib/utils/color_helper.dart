import 'package:flutter/material.dart';

class ColorHelper {
  static const primaryBlue = Color(0xFF0E1A35);
  static const navyBlue = primaryBlue;
  static const accentYellow = Color(0xFFE8A419);
  static const goldenYellow = accentYellow;
  static const white = Color(0xFFFFFFFF);
  static const lightGray = Color(0xFFE5E6E7);
  static const mediumGray = Color(0xFF999CA5);
  static const darkGray = Color(0xFF55575B);
  static const black = Color(0xFF010101);
  static const heroBackdrop = Color(0xFFE8ECF2);
  static const footerBarBg = Color(0xFFF3F4F6);
  static const buttonOutline = Color(0xFFD8DADE);
  static const formActionCyan = Color(0xFF26C6DA);
  static const successGreen = Color(0xFF2E7D32);
  static const errorRed = Color(0xFFC62828);

  static final LinearGradient authScreenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.lerp(primaryBlue, white, 0.14)!,
      Color.lerp(primaryBlue, accentYellow, 0.42)!,
      Color.lerp(primaryBlue, accentYellow, 0.12)!,
    ],
    stops: const [0.0, 0.52, 1.0],
  );

  static final LinearGradient authBarHorizontalGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color.lerp(primaryBlue, white, 0.12)!,
      Color.lerp(primaryBlue, accentYellow, 0.48)!,
    ],
  );
}
