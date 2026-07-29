import 'package:auto_care/constants/app_layout.dart';
import 'package:auto_care/utils/color_helper.dart';
import 'package:auto_care/utils/font_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

class AuthGradientBackground extends StatelessWidget {
  const AuthGradientBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padH = AuthGradientResponsive.horizontalPadding(size);
    final padV = AuthGradientResponsive.verticalPadding(size);

    return DecoratedBox(
      decoration: BoxDecoration(gradient: ColorHelper.authScreenGradient),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(padH, padV, padH, padV),
          child: child,
        ),
      ),
    );
  }
}

class AuthLoginField extends StatelessWidget {
  const AuthLoginField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.showVisibilityToggle = false,
    this.onVisibilityToggle,
    this.prefixIcon,
    this.validator,
    this.readOnly = false,
    this.inputFormatters,
    this.textCapitalization,
  }) : assert(
          !showVisibilityToggle || onVisibilityToggle != null,
          'onVisibilityToggle is required when showVisibilityToggle is true',
        );

  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool showVisibilityToggle;
  final VoidCallback? onVisibilityToggle;
  final IconData? prefixIcon;
  final FormFieldValidator<String>? validator;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization? textCapitalization;

  static const _white = ColorHelper.white;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final labelSize = AuthFieldResponsive.labelFontSize(w);
    final hintSize = AuthFieldResponsive.hintFontSize(w);

    final fillColor = Color.lerp(
      ColorHelper.primaryBlue,
      ColorHelper.white,
      AuthFieldLayout.fillLerpBlue,
    )!
        .withValues(alpha: AuthFieldLayout.fillAlpha);
    final accentIconColor = Color.lerp(
      ColorHelper.accentYellow,
      ColorHelper.white,
      AuthFieldLayout.accentIconLerp,
    )!;

    final enabledOutline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AuthFieldLayout.radius),
      borderSide: BorderSide(
        color: _white.withValues(alpha: AuthFieldLayout.outlineEnabledAlpha),
        width: AuthFieldLayout.outlineEnabledWidth,
      ),
    );
    final focusedOutline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AuthFieldLayout.radius),
      borderSide: BorderSide(
        color: _white.withValues(alpha: AuthFieldLayout.outlineFocusedAlpha),
        width: AuthFieldLayout.outlineFocusedWidth,
      ),
    );
    final errorOutline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AuthFieldLayout.radius),
      borderSide: BorderSide(color: Colors.red.shade300, width: AuthFieldLayout.outlineFocusedWidth),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AuthFieldLayout.labelInsetLeft),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: FontHelper.poppinsSemiBold,
              color: _white.withValues(alpha: AuthFieldLayout.labelAlpha),
              fontSize: labelSize,
              letterSpacing: AuthFieldLayout.labelLetterSpacing,
              height: AuthFieldLayout.labelLineHeight,
            ),
          ),
        ),
        Gap(AuthFieldResponsive.labelToFieldGap(w)),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          readOnly: readOnly,
          validator: validator,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization ?? TextCapitalization.none,
          style: TextStyle(
            fontFamily: FontHelper.poppinsRegular,
            color: _white.withValues(
              alpha: readOnly
                  ? AuthFieldLayout.readOnlyTextAlpha
                  : 1,
            ),
            fontSize: hintSize,
          ),
          cursorColor: _white,
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor,
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: FontHelper.poppinsRegular,
              color: _white.withValues(alpha: AuthFieldLayout.hintAlpha),
              fontSize: hintSize,
            ),
            isDense: true,
            contentPadding: EdgeInsets.fromLTRB(
              prefixIcon != null
                  ? AuthFieldLayout.contentPadLWithPrefix
                  : AuthFieldLayout.contentPadLDefault,
              AuthFieldLayout.contentPadVertical,
              showVisibilityToggle
                  ? AuthFieldLayout.contentPadRWithSuffix
                  : AuthFieldLayout.contentPadRDefault,
              AuthFieldLayout.contentPadVertical,
            ),
            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(
                      left: AuthFieldLayout.prefixIconLeft,
                      right: AuthFieldLayout.prefixIconRight,
                    ),
                    child: Icon(
                      prefixIcon,
                      color: accentIconColor,
                      size: AuthFieldLayout.prefixIconSize,
                    ),
                  )
                : null,
            prefixIconConstraints: prefixIcon != null
                ? const BoxConstraints(minWidth: 0, minHeight: 0)
                : null,
            suffixIcon: showVisibilityToggle && onVisibilityToggle != null
                ? IconButton(
                    onPressed: onVisibilityToggle,
                    tooltip: obscureText ? 'Show password' : 'Hide password',
                    style: IconButton.styleFrom(
                      foregroundColor: _white.withValues(alpha: AuthFieldLayout.labelAlpha),
                    ),
                    icon: Icon(
                      obscureText
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      size: AuthFieldLayout.suffixIconSize,
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: AuthFieldLayout.suffixIconMinWidth,
                      minHeight: AuthFieldLayout.suffixIconMinHeight,
                    ),
                  )
                : null,
            suffixIconConstraints: showVisibilityToggle
                ? const BoxConstraints(
                    minWidth: AuthFieldLayout.suffixIconMinWidth,
                    minHeight: AuthFieldLayout.suffixIconMinHeight,
                  )
                : null,
            enabledBorder: enabledOutline,
            focusedBorder: focusedOutline,
            errorBorder: errorOutline,
            focusedErrorBorder: errorOutline,
            border: enabledOutline,
          ),
        ),
      ],
    );
  }
}

/// Same chrome as [AuthLoginField], for dropdown selection.
class AuthLoginDropdown extends StatelessWidget {
  const AuthLoginDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    this.value,
    required this.onChanged,
    this.prefixIcon,
    this.validator,
  });

  final String label;
  final String hint;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  final IconData? prefixIcon;
  final FormFieldValidator<String>? validator;

  static const _white = ColorHelper.white;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final labelSize = AuthFieldResponsive.labelFontSize(w);
    final hintSize = AuthFieldResponsive.hintFontSize(w);

    final fillColor = Color.lerp(
      ColorHelper.primaryBlue,
      ColorHelper.white,
      AuthFieldLayout.fillLerpBlue,
    )!
        .withValues(alpha: AuthFieldLayout.fillAlpha);
    final accentIconColor = Color.lerp(
      ColorHelper.accentYellow,
      ColorHelper.white,
      AuthFieldLayout.accentIconLerp,
    )!;

    final enabledOutline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AuthFieldLayout.radius),
      borderSide: BorderSide(
        color: _white.withValues(alpha: AuthFieldLayout.outlineEnabledAlpha),
        width: AuthFieldLayout.outlineEnabledWidth,
      ),
    );
    final focusedOutline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AuthFieldLayout.radius),
      borderSide: BorderSide(
        color: _white.withValues(alpha: AuthFieldLayout.outlineFocusedAlpha),
        width: AuthFieldLayout.outlineFocusedWidth,
      ),
    );
    final errorOutline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AuthFieldLayout.radius),
      borderSide: BorderSide(
        color: Colors.red.shade300,
        width: AuthFieldLayout.outlineFocusedWidth,
      ),
    );

    final menuSurface = Color.lerp(
      ColorHelper.primaryBlue,
      Colors.black,
      AuthFieldLayout.menuSurfaceLerpBlack,
    )!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AuthFieldLayout.labelInsetLeft),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: FontHelper.poppinsSemiBold,
              color: _white.withValues(alpha: AuthFieldLayout.labelAlpha),
              fontSize: labelSize,
              letterSpacing: AuthFieldLayout.labelLetterSpacing,
              height: AuthFieldLayout.labelLineHeight,
            ),
          ),
        ),
        Gap(AuthFieldResponsive.labelToFieldGap(w)),
        if (items.isEmpty)
          InputDecorator(
            decoration: InputDecoration(
              filled: true,
              fillColor: fillColor,
              isDense: true,
              contentPadding: EdgeInsets.fromLTRB(
                prefixIcon != null
                    ? AuthFieldLayout.contentPadLWithPrefix
                    : AuthFieldLayout.contentPadLDefault,
                AuthFieldLayout.contentPadVertical,
                AuthFieldLayout.contentPadREmptyDropdown,
                AuthFieldLayout.contentPadVertical,
              ),
              prefixIcon: prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(
                        left: AuthFieldLayout.prefixIconLeft,
                        right: AuthFieldLayout.prefixIconRight,
                      ),
                      child: Icon(
                        prefixIcon,
                        color: accentIconColor,
                        size: AuthFieldLayout.prefixIconSize,
                      ),
                    )
                  : null,
              prefixIconConstraints: prefixIcon != null
                  ? const BoxConstraints(minWidth: 0, minHeight: 0)
                  : null,
              enabledBorder: enabledOutline,
              focusedBorder: focusedOutline,
              errorBorder: errorOutline,
              focusedErrorBorder: errorOutline,
              border: enabledOutline,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FontHelper.poppinsRegular,
                      color: _white.withValues(
                        alpha: AuthFieldLayout.emptyDropdownHintAlpha,
                      ),
                      fontSize: hintSize,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _white.withValues(
                    alpha: AuthFieldLayout.emptyDropdownIconAlpha,
                  ),
                  size: AuthFieldLayout.dropdownTrailingIconSize,
                ),
              ],
            ),
          )
        else
          DropdownButtonFormField<String>(
            initialValue:
                value != null && items.contains(value) ? value : null,
            isExpanded: true,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _white.withValues(alpha: AuthFieldLayout.dropdownIconAlpha),
              size: AuthFieldLayout.dropdownTrailingIconSize,
            ),
            dropdownColor: menuSurface,
            borderRadius: BorderRadius.circular(AuthFieldLayout.radius),
            style: TextStyle(
              fontFamily: FontHelper.poppinsRegular,
              color: _white,
              fontSize: hintSize,
            ),
            hint: Text(
              hint,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: FontHelper.poppinsRegular,
                color: _white.withValues(alpha: AuthFieldLayout.hintAlpha),
                fontSize: hintSize,
              ),
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: fillColor,
              isDense: true,
              contentPadding: EdgeInsets.fromLTRB(
                prefixIcon != null
                    ? AuthFieldLayout.contentPadLWithPrefix
                    : AuthFieldLayout.contentPadLDefault,
                AuthFieldLayout.contentPadVertical,
                AuthFieldLayout.contentPadREmptyDropdown,
                AuthFieldLayout.contentPadVertical,
              ),
              prefixIcon: prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(
                        left: AuthFieldLayout.prefixIconLeft,
                        right: AuthFieldLayout.prefixIconRight,
                      ),
                      child: Icon(
                        prefixIcon,
                        color: accentIconColor,
                        size: AuthFieldLayout.prefixIconSize,
                      ),
                    )
                  : null,
              prefixIconConstraints: prefixIcon != null
                  ? const BoxConstraints(minWidth: 0, minHeight: 0)
                  : null,
              enabledBorder: enabledOutline,
              focusedBorder: focusedOutline,
              errorBorder: errorOutline,
              focusedErrorBorder: errorOutline,
              border: enabledOutline,
            ),
            selectedItemBuilder: (context) {
              return items
                  .map(
                    (e) => Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        e,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: FontHelper.poppinsRegular,
                          color: _white,
                          fontSize: hintSize,
                        ),
                      ),
                    ),
                  )
                  .toList();
            },
            items: items
                .map(
                  (e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(
                      e,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: FontHelper.poppinsRegular,
                        color: _white,
                        fontSize: hintSize,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
            validator: validator,
          ),
      ],
    );
  }
}

class AuthRegisterRowField extends StatelessWidget {
  const AuthRegisterRowField({
    super.key,
    required this.label,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
  });

  final String label;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  static const _white = ColorHelper.white;

  InputBorder get _underline => const UnderlineInputBorder(
        borderSide:  BorderSide(
          color: _white,
          width: AuthFieldLayout.rowUnderlineWidth,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final labelSize = AuthFieldResponsive.rowLabelSize(w);
    final fieldSize = AuthFieldResponsive.rowFieldSize(w);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: FontHelper.poppinsMedium,
            color: _white,
            fontSize: labelSize,
            height: AuthFieldLayout.rowLabelLineHeight,
          ),
        ),
        Gap(AuthFieldResponsive.rowGap(w)),
        Expanded(
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            style: TextStyle(
              fontFamily: FontHelper.poppinsRegular,
              color: _white,
              fontSize: fieldSize,
            ),
            cursorColor: _white,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.only(
                bottom: AuthFieldLayout.rowFieldBottomPadding,
              ),
              enabledBorder: _underline,
              focusedBorder: _underline,
              errorBorder: _underline,
              focusedErrorBorder: _underline,
              border: _underline,
            ),
          ),
        ),
      ],
    );
  }
}

class AuthPillButton extends StatelessWidget {
  const AuthPillButton({
    super.key,
    required this.label,
    required this.foreground,
    this.onPressed,
    this.compact = false,
  });

  final String label;
  final Color foreground;
  final VoidCallback? onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final h = MediaQuery.sizeOf(context).height;
    final height = AuthPillResponsive.height(h, compact: compact);
    final fontSize = AuthPillResponsive.fontSize(w, compact: compact);

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor:
              const WidgetStatePropertyAll(ColorHelper.white),
          foregroundColor: WidgetStatePropertyAll(foreground),
          shape: const WidgetStatePropertyAll(StadiumBorder()),
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: w * AuthPillButtonLayout.horizontalPaddingFraction,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: FontHelper.poppinsSemiBold,
            fontSize: fontSize,
            letterSpacing: compact
                ? AuthPillButtonLayout.letterSpacingCompact
                : AuthPillButtonLayout.letterSpacing,
          ),
        ),
      ),
    );
  }
}
