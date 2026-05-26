import 'package:auto_care/constants/app_layout.dart';
import 'package:auto_care/features/Authentication/controllers/auth_controller.dart';
import 'package:auto_care/features/Authentication/view/forgot_password_page.dart';
import 'package:auto_care/features/Authentication/view/register_page.dart';
import 'package:auto_care/features/Home/home_page.dart';
import 'package:auto_care/utils/color_helper.dart';
import 'package:auto_care/utils/font_helper.dart';
import 'package:auto_care/utils/navigation_helper.dart';
import 'package:auto_care/utils/string_helper.dart';
import 'package:auto_care/widgets/auth_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = Get.put(AuthController(), permanent: true);
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
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
                      bottom: scrollBottomPad + AuthScreenLayout.scrollBottomExtra,
                    ),
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: h * AuthScreenLayout.loginFormMinHeightFraction,
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
                                StringHelper.welcomeBack,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: FontHelper.poppinsBold,
                                  color: ColorHelper.white,
                                  fontSize: titleSize,
                                  height: AuthScreenLayout.titleLineHeight,
                                  letterSpacing: AuthScreenLayout.titleLetterSpacing,
                                ),
                              ),
                              Gap(AuthResponsive.gapAfterTitle(h)),
                              Text(
                                StringHelper.loginToContinue,
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
                                label: StringHelper.username,
                                hint: StringHelper.enterUsername,
                                controller: _username,
                                prefixIcon: Icons.person_outline_rounded,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.text,
                              ),
                              Gap(gapLarge),
                              AuthLoginField(
                                label: StringHelper.password,
                                hint: StringHelper.enterPassword,
                                controller: _password,
                                prefixIcon: Icons.lock_outline_rounded,
                                obscureText: _obscurePassword,
                                showVisibilityToggle: true,
                                onVisibilityToggle: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                textInputAction: TextInputAction.done,
                              ),
                              Gap(AuthResponsive.gapForgotPassword(h)),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      appRoute<void>(
                                        const ForgotPasswordPage(),
                                      ),
                                    );
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical:
                                          AuthScreenLayout.forgotPasswordHitVertical,
                                      horizontal: AuthScreenLayout
                                          .forgotPasswordHitHorizontal,
                                    ),
                                    child: Text(
                                      StringHelper.forgotPassword,
                                      style: FontHelper.taglineSmall(
                                        ColorHelper.accentYellow,
                                      ).copyWith(
                                        fontFamily: FontHelper.poppinsSemiBold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Gap(gapAfterFields),
                              Obx(
                                () => AuthPillButton(
                                  label: _authController.isLoggingIn.value
                                      ? 'Logging in...'
                                      : StringHelper.login,
                                  foreground: ColorHelper.primaryBlue,
                                  onPressed: _authController.isLoggingIn.value
                                      ? null
                                      : () async {
                                          if (!(_formKey.currentState
                                                  ?.validate() ??
                                              true)) {
                                            return;
                                          }
                                          FocusScope.of(context).unfocus();
                                          final navigator = Navigator.of(context);
                                          final success =
                                              await _authController.login(
                                            username: _username.text,
                                            password: _password.text,
                                          );
                                          if (!mounted) return;
                                          if (success) {
                                            navigator.pushAndRemoveUntil(
                                              appRoute<void>(
                                                const HomeRequestListPage(),
                                              ),
                                              (_) => false,
                                            );
                                          } else {
                                            final message =
                                                _authController.errorMessage
                                                    .value;
                                            if (message != null &&
                                                message.isNotEmpty) {
                                              Get.snackbar(
                                                'Login failed',
                                                message,
                                                snackPosition:
                                                    SnackPosition.BOTTOM,
                                              );
                                            }
                                          }
                                        },
                                ),
                              ),
                              Gap(gapMed),
                              Center(
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment:
                                      WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      StringHelper.dontHaveAccountPrompt,
                                      textAlign: TextAlign.center,
                                      style: FontHelper.taglineSmall(
                                        ColorHelper.white.withValues(
                                          alpha: AuthScreenLayout.linkPromptAlpha,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          appRoute<void>(const RegisterPage()),
                                        );
                                      },
                                      child: Text(
                                        StringHelper.registerLink,
                                        style: FontHelper.taglineSmall(
                                          ColorHelper.accentYellow,
                                        ).copyWith(
                                          decoration:
                                              TextDecoration.underline,
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
