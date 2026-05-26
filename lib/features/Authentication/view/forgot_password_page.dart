import 'package:auto_care/constants/app_layout.dart';
import 'package:auto_care/utils/color_helper.dart';
import 'package:auto_care/utils/font_helper.dart';
import 'package:auto_care/utils/string_helper.dart';
import 'package:auto_care/widgets/auth_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _email = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _email.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_newPassword.text != _confirmPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(StringHelper.passwordsDoNotMatch),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(StringHelper.passwordResetSuccess),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padH = AuthResponsive.horizontalPadding(size.width);
    final padV = AuthResponsive.verticalPadding(size.height);
    final w = size.width;
    final h = size.height;
    final gapLarge = AuthResponsive.gapFieldBlock(h);
    final gapMed = AuthResponsive.gapMedLogin(h);
    final gapAfterFields = AuthResponsive.gapAfterFieldsLogin(h);
    final titleSize = AuthResponsive.loginTitleSize(w);
    final subtitleSize = AuthResponsive.authSubtitleSize(w);
    final scrollBottomPad = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: ColorHelper.primaryBlue,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: ColorHelper.primaryBlue,
        foregroundColor: ColorHelper.white,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: ColorHelper.white,
            size: AuthScreenLayout.appBarBackIconSize,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: AuthScreenLayout.appBarLeadingMinWidth,
            minHeight: AuthScreenLayout.appBarLeadingMinHeight,
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: ColorHelper.primaryBlue,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(padH, padV, padH, padV),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom:
                          scrollBottomPad + AuthScreenLayout.scrollBottomExtra,
                    ),
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            h * AuthScreenLayout.loginFormMinHeightFraction,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: AuthResponsive.formMaxWidth(size.width),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                StringHelper.forgotPasswordTitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: FontHelper.poppinsBold,
                                  color: ColorHelper.white,
                                  fontSize: titleSize,
                                  height: AuthScreenLayout.titleLineHeight,
                                  letterSpacing:
                                      AuthScreenLayout.titleLetterSpacing,
                                ),
                              ),
                              Gap(AuthResponsive.gapAfterTitle(h)),
                              Text(
                                StringHelper.forgotPasswordSubtitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: FontHelper.poppinsRegular,
                                  color: ColorHelper.white.withValues(
                                    alpha: AuthScreenLayout.subtitleAlpha,
                                  ),
                                  fontSize: subtitleSize,
                                  height: AuthScreenLayout.subtitleLineHeight,
                                ),
                              ),
                              Gap(AuthResponsive.gapBeforeFieldsLogin(h)),
                              AuthLoginField(
                                label: StringHelper.email,
                                hint: StringHelper.enterEmail,
                                controller: _email,
                                prefixIcon: Icons.mail_outline_rounded,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              Gap(gapLarge),
                              AuthLoginField(
                                label: StringHelper.newPassword,
                                hint: StringHelper.enterNewPassword,
                                controller: _newPassword,
                                prefixIcon: Icons.lock_outline_rounded,
                                obscureText: _obscureNewPassword,
                                showVisibilityToggle: true,
                                onVisibilityToggle: () => setState(
                                  () => _obscureNewPassword =
                                      !_obscureNewPassword,
                                ),
                                textInputAction: TextInputAction.next,
                              ),
                              Gap(gapLarge),
                              AuthLoginField(
                                label: StringHelper.confirmPassword,
                                hint: StringHelper.enterConfirmPassword,
                                controller: _confirmPassword,
                                prefixIcon: Icons.lock_outline_rounded,
                                obscureText: _obscureConfirmPassword,
                                showVisibilityToggle: true,
                                onVisibilityToggle: () => setState(
                                  () => _obscureConfirmPassword =
                                      !_obscureConfirmPassword,
                                ),
                                textInputAction: TextInputAction.done,
                              ),
                              Gap(gapAfterFields),
                              AuthPillButton(
                                label: StringHelper.resetPassword,
                                foreground: ColorHelper.primaryBlue,
                                onPressed: _onSubmit,
                              ),
                              Gap(gapMed),
                              Center(
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment:
                                      WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      StringHelper.backToLoginPrompt,
                                      textAlign: TextAlign.center,
                                      style: FontHelper.taglineSmall(
                                        ColorHelper.white.withValues(
                                          alpha:
                                              AuthScreenLayout.linkPromptAlpha,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () =>
                                          Navigator.of(context).maybePop(),
                                      child: Text(
                                        StringHelper.login,
                                        style: FontHelper.taglineSmall(
                                          ColorHelper.accentYellow,
                                        ).copyWith(
                                          decoration: TextDecoration.underline,
                                          decorationColor:
                                              ColorHelper.accentYellow,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
