import 'package:auto_care/constants/app_layout.dart';
import 'package:flutter/material.dart';

class StartingLayoutScope extends InheritedWidget {
  const StartingLayoutScope({
    super.key,
    required this.scale,
    required super.child,
  });

  final double scale;

  static double scaleOf(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<StartingLayoutScope>();
    assert(scope != null, 'StartingLayoutScope missing above this context');
    return scope!.scale;
  }

  static double s(BuildContext context, double designPixels) =>
      designPixels * scaleOf(context);

  static TextStyle text(BuildContext context, TextStyle designStyle) {
    final sc = scaleOf(context);
    return designStyle.copyWith(
      fontSize: (designStyle.fontSize ?? 12) * sc,
      letterSpacing: designStyle.letterSpacing != null
          ? designStyle.letterSpacing! * sc
          : null,
    );
  }

  static double fromScreenWidth(double width) =>
      (width / AppLayout.designWidth).clamp(0.76, 1.38);

  @override
  bool updateShouldNotify(StartingLayoutScope oldWidget) =>
      oldWidget.scale != scale;
}
