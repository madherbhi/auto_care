import 'package:auto_care/constants/app_layout.dart';
import 'package:auto_care/utils/color_helper.dart';
import 'package:auto_care/utils/font_helper.dart';
import 'package:auto_care/utils/string_helper.dart';
import 'package:auto_care/widgets/auth_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const List<String> _banks = [
    'Axis Bank',
    'HDFC Bank',
    'ICICI Bank',
    'State Bank of India',
  ];

  static const Map<String, List<String>> _bankIdsByBank = {
    'Axis Bank': ['AXIS-MUM-001', 'AXIS-DEL-042', 'AXIS-BLR-108'],
    'HDFC Bank': ['HDFC-HO-9001', 'HDFC-PUN-2204'],
    'ICICI Bank': ['ICICI-CHN-5510', 'ICICI-HYD-3302', 'ICICI-KOL-7711'],
    'State Bank of India': ['SBI-NEW-0001', 'SBI-MUM-0144'],
  };

  final _userName = TextEditingController();
  final _password = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedBank;
  String? _selectedBankId;
  bool _obscurePassword = true;

  List<String> get _bankIdOptions =>
      _selectedBank != null ? (_bankIdsByBank[_selectedBank] ?? []) : [];

  @override
  void dispose() {
    _userName.dispose();
    _password.dispose();
    _mobile.dispose();
    _email.dispose();
    super.dispose();
  }

  void _onBankChanged(String? bank) {
    setState(() {
      _selectedBank = bank;
      _selectedBankId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padH = AuthResponsive.horizontalPadding(size.width);
    final padV = AuthResponsive.verticalPadding(size.height);
    final w = size.width;
    final h = size.height;
    final gapLarge = AuthResponsive.gapFieldBlock(h);
    final gapMed = AuthResponsive.gapMedRegister(h);
    final gapAfterFields = AuthResponsive.gapAfterFieldsRegister(h);
    final titleSize = AuthResponsive.registerTitleSize(w);
    final subtitleSize = AuthResponsive.authSubtitleSize(w);
    final scrollBottomPad = MediaQuery.viewInsetsOf(context).bottom;

    final bankIdItems = _bankIdOptions;
    final bankIdHint = bankIdItems.isEmpty
        ? StringHelper.selectBankFirst
        : StringHelper.selectBankId;

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
                        minHeight:
                            h * AuthScreenLayout.registerFormMinHeightFraction,
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
                                StringHelper.createAccount,
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
                                StringHelper.registerFillDetails,
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
                              Gap(AuthResponsive.gapBeforeFieldsRegister(h)),
                              AuthLoginField(
                                label: StringHelper.username,
                                hint: StringHelper.enterUsername,
                                controller: _userName,
                                prefixIcon: Icons.person_outline_rounded,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.name,
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
                                textInputAction: TextInputAction.next,
                              ),
                              Gap(gapLarge),
                              AuthLoginField(
                                label: StringHelper.mobile,
                                hint: StringHelper.enterMobile,
                                controller: _mobile,
                                prefixIcon: Icons.phone_android_rounded,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.phone,
                              ),
                              Gap(gapLarge),
                              AuthLoginField(
                                label: StringHelper.email,
                                hint: StringHelper.enterEmail,
                                controller: _email,
                                prefixIcon: Icons.mail_outline_rounded,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              Gap(gapLarge),
                              AuthLoginDropdown(
                                label: StringHelper.bankLabel,
                                hint: StringHelper.selectBank,
                                items: _banks,
                                value: _selectedBank,
                                prefixIcon: Icons.account_balance_outlined,
                                onChanged: _onBankChanged,
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Required' : null,
                              ),
                              Gap(gapLarge),
                              AuthLoginDropdown(
                                label: StringHelper.bankIdLabel,
                                hint: bankIdHint,
                                items: bankIdItems,
                                value: _selectedBankId,
                                prefixIcon: Icons.tag_outlined,
                                onChanged: bankIdItems.isEmpty
                                    ? (_) {}
                                    : (id) =>
                                        setState(() => _selectedBankId = id),
                                validator: bankIdItems.isEmpty
                                    ? null
                                    : (v) => v == null || v.isEmpty
                                        ? 'Required'
                                        : null,
                              ),
                              Gap(gapAfterFields),
                              AuthPillButton(
                                label: StringHelper.registerSignUp,
                                foreground: ColorHelper.primaryBlue,
                                onPressed: () {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    FocusScope.of(context).unfocus();
                                  }
                                },
                              ),
                              Gap(gapMed),
                              Center(
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      StringHelper.alreadyHaveAccountPrompt,
                                      textAlign: TextAlign.center,
                                      style: FontHelper.taglineSmall(
                                        ColorHelper.white.withValues(
                                          alpha: AuthScreenLayout.linkPromptAlpha,
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
