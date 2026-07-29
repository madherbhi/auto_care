import 'package:auto_care/constants/app_layout.dart';
import 'package:auto_care/utils/font_helper.dart';
import 'package:auto_care/utils/starting_layout_scale.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CustomActionButton extends StatelessWidget {
  const CustomActionButton({super.key, 
    required this.label,
    required this.leading,
    required this.trailing,
    required this.background,
    required this.foreground,
    this.border,
    this.onTap,
  });

  final String label;
  final IconData leading;
  final IconData trailing;
  final Color background;
  final Color foreground;
  final BorderSide? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const s = StartingLayoutScope.s;
    final textStyle = StartingLayoutScope.text(
      context,
      FontHelper.buttonText(foreground),
    );

    return SizedBox(
      height: s(context, StartingPrimaryButtonLayout.height),
      child: Material(
        color: background,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(s(context, StartingPrimaryButtonLayout.radius)),
          side: border ?? BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(s(context, StartingPrimaryButtonLayout.radius)),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: s(context, StartingPrimaryButtonLayout.horizontalPadding),
            ),
            child: Row(
              children: [
                Icon(
                  leading,
                  color: foreground,
                  size: s(context, StartingPrimaryButtonLayout.iconSize),
                ),
                Gap(s(context, StartingPrimaryButtonLayout.gapIconToLabel)),
                Text(
                    label,
                    textAlign: TextAlign.center,
                    style: textStyle,
                  ),
                const Spacer(),
                Icon(
                  trailing,
                  color: foreground,
                  size: s(context, StartingPrimaryButtonLayout.iconSize),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
