import 'package:flutter/material.dart';

class ColorHelper {
  /// Navy brand blue (logo, primary actions, body text).
  static const primaryBlue = Color(0xFF0E1A35);
  static const navyBlue = primaryBlue;

  /// Golden accent (INSPECT wordmark, logo “N”, highlights).
  static const accentYellow = Color(0xFFE8A419);
  static const goldenYellow = accentYellow;

  static const white = Color(0xFFFFFFFF);
  static const lightGray = Color(0xFFE5E6E7);
  static const mediumGray = Color(0xFF999CA5);
  static const darkGray = Color(0xFF55575B);
  static const black = Color(0xFF010101);

  /// Subtle skyline / decoration behind the hero.
  static const heroBackdrop = Color(0xFFE8ECF2);

  /// Footer feature strip background.
  static const footerBarBg = Color(0xFFF3F4F6);

  /// Very light outline for secondary buttons.
  static const buttonOutline = Color(0xFFD8DADE);

  /// Full-screen auth gradient using only the Starting page palette
  /// ([primaryBlue], [accentYellow], [white] via interpolation).
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

  /// Horizontal bar gradient (e.g. post-login headers) using the same palette
  /// as [authScreenGradient].
  static final LinearGradient authBarHorizontalGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color.lerp(primaryBlue, white, 0.12)!,
      Color.lerp(primaryBlue, accentYellow, 0.48)!,
    ],
  );
}