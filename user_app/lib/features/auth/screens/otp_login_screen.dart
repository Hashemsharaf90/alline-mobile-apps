import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/enums/from_page.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/widgets/social_login_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/setting/widgets/select_language_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/business_pages_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/config_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';

class OtpLoginScreen extends StatefulWidget {
  final bool fromLogout;
  final bool showBackButton;
  final String? fromPage;
  final VoidCallback? onLoginSuccess;
  const OtpLoginScreen({
    super.key,
    this.fromLogout = false,
    this.showBackButton = true,
    this.fromPage,
    this.onLoginSuccess,
  });

  @override
  State<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends State<OtpLoginScreen> {
  String? countryCode;
  TextEditingController? _phoneNumberController;

  @override
  void initState() {
    super.initState();
    _phoneNumberController = TextEditingController();

    final ConfigModel? configModel =
        Provider.of<SplashController>(context, listen: false).configModel;
    final String? configuredCountry = configModel?.countryCode;
    countryCode ??= CountryCode.fromCountryCode(
                (configuredCountry?.isNotEmpty ?? false)
                    ? configuredCountry!
                    : 'YE')
            .dialCode ??
        '+967';

    // Automatically ensure terms agreement flag is active for smooth submission
    final authController = Provider.of<AuthController>(context, listen: false);
    if (!authController.isAcceptTerms) {
      authController.toggleTermsCheck();
    }
  }

  @override
  void dispose() {
    _phoneNumberController?.dispose();
    super.dispose();
  }

  BusinessPageModel? _getPageBySlug(
      String slug, List<BusinessPageModel>? pagesList) {
    if (pagesList != null && pagesList.isNotEmpty) {
      for (var page in pagesList) {
        if (page.slug == slug) {
          return page;
        }
      }
    }
    return null;
  }

  Future<void> _handlePhoneSubmit(BuildContext context,
      AuthController authProvider, ConfigModel configModel) async {
    final rawPhone = _phoneNumberController!.text.trim();
    if (rawPhone.isEmpty) {
      showCustomSnackBarWidget(
        getTranslated('enter_phone_number', context) ?? 'يرجى إدخال رقم الهاتف',
        context,
        snackBarType: SnackBarType.warning,
      );
      return;
    }

    if (!authProvider.isAcceptTerms) {
      authProvider.toggleTermsCheck();
    }

    String dial = countryCode ?? '+967';
    String phoneWithCountryCode = dial + rawPhone;

    if (configModel.customerVerification?.firebase == 1) {
      await authProvider.firebaseVerifyPhoneNumber(
        phoneWithCountryCode,
        FromPage.otpLogin,
        toNavigateScreen: widget.fromPage,
        onLoginSuccess: widget.onLoginSuccess,
      );
    } else {
      await authProvider.checkPhoneForOtp(
        phoneWithCountryCode,
        FromPage.otpLogin,
        toNavigateScreen: widget.fromPage,
        onLoginSuccess: widget.onLoginSuccess,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.allineColors;
    final ConfigModel configModel =
        Provider.of<SplashController>(context, listen: false).configModel!;
    final SplashController splashController =
        Provider.of<SplashController>(context, listen: false);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (widget.fromLogout) {
          RouterHelper.getDashboardRoute(
              action: RouteAction.pushNamedAndRemoveUntil);
        } else if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: colors.background,
        body: Stack(
          children: [
            // Soft ambient decorative circles
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AllineColors.primary.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              top: -40,
              left: -60,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AllineColors.brightBlue.withValues(alpha: 0.05),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),

                        // Top bar: Back Button & Language Pill (Start) & Slogan (End)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.showBackButton &&
                                    Navigator.of(context).canPop()) ...[
                                  InkWell(
                                    onTap: () => Navigator.of(context).pop(),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: colors.surface,
                                        shape: BoxShape.circle,
                                        border:
                                            Border.all(color: colors.border),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.04),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          )
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        size: 15,
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],

                                // Language Picker Pill
                                InkWell(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (c) =>
                                          const SelectLanguageBottomSheetWidget(),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: colors.surface,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: colors.border),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.03),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        )
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.language_rounded,
                                            size: 16,
                                            color: colors.textSecondary),
                                        const SizedBox(width: 6),
                                        Consumer<LocalizationController>(
                                          builder: (context, loc, _) {
                                            final currentCode =
                                                loc.locale.languageCode;
                                            final name = currentCode == 'ar'
                                                ? 'العربية'
                                                : 'English';
                                            return Text(
                                              name,
                                              style: textMedium.copyWith(
                                                fontSize: 13,
                                                color: colors.textPrimary,
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(Icons.keyboard_arrow_down_rounded,
                                            size: 16,
                                            color: colors.textSecondary),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Image.asset(
                                Images.loginTopSlogan,
                                height: 36,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Text(
                                  'من اليمن إلى كل احتياجاتك',
                                  textAlign: TextAlign.end,
                                  style: textBold.copyWith(
                                    fontSize: 13.5,
                                    color: AllineColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Logo & Brand Header
                        Center(
                          child: Image.asset(
                            'assets/images/alline/login_logo_transparent.png',
                            width: 120,
                            height: 120,
                            filterQuality: FilterQuality.high,
                            semanticLabel: 'Alline',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            'مرحباً بك في Alline',
                            style: textBold.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: Text(
                            'كل ما تحتاجه في مكان واحد\nتسوق بسهولة .. حياة أسهل',
                            textAlign: TextAlign.center,
                            style: textRegular.copyWith(
                              fontSize: 13,
                              color: colors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Main Form Card
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 24),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: colors.border),
                            boxShadow: [
                              BoxShadow(
                                color: AllineColors.primary
                                    .withValues(alpha: 0.05),
                                blurRadius: 28,
                                offset: const Offset(0, 10),
                                spreadRadius: -2,
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Label: "رقم الهاتف"
                              Text(
                                'رقم الهاتف',
                                style: textBold.copyWith(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Phone Input Container with Yemeni Flag
                              Container(
                                height: 54,
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: colors.border,
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: CountryCodePicker(
                                        padding: EdgeInsets.zero,
                                        onChanged: (CountryCode value) {
                                          setState(() {
                                            countryCode = value.dialCode;
                                          });
                                        },
                                        initialSelection: countryCode ?? '+967',
                                        favorite: const ['+967', 'YE', 'SA'],
                                        showCountryOnly: false,
                                        showOnlyCountryWhenClosed: false,
                                        showFlagMain: true,
                                        showFlag: true,
                                        showFlagDialog: true,
                                        showDropDownButton: true,
                                        flagWidth: 24,
                                        textStyle: textBold.copyWith(
                                          fontSize: 14,
                                          color: colors.textPrimary,
                                        ),
                                        dialogBackgroundColor: colors.surface,
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 26,
                                      color: colors.border,
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: _phoneNumberController,
                                        keyboardType: TextInputType.phone,
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        textDirection: TextDirection.ltr,
                                        style: textBold.copyWith(
                                          fontSize: 15,
                                          letterSpacing: 1.2,
                                          color: colors.textPrimary,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: '7XX XXX XXX',
                                          hintTextDirection: TextDirection.ltr,
                                          hintStyle: textRegular.copyWith(
                                            color: colors.textSecondary,
                                            fontSize: 14,
                                            letterSpacing: 1.2,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Helper notice: "سنرسل لك رمز التحقق عبر رسالة نصية قصيرة (SMS)"
                              Row(
                                children: [
                                  Icon(Icons.info_outline_rounded,
                                      size: 14, color: colors.textSecondary),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'سنرسل لك رمز التحقق عبر رسالة نصية قصيرة (SMS)',
                                      style: textRegular.copyWith(
                                        fontSize: 12,
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // "متابعة" Primary Action Button
                              Consumer<AuthController>(
                                builder: (context, authProvider, _) {
                                  final isLoading = authProvider
                                      .isPhoneNumberVerificationButtonLoading;
                                  return Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: isLoading
                                          ? null
                                          : () => _handlePhoneSubmit(context,
                                              authProvider, configModel),
                                      borderRadius: BorderRadius.circular(14),
                                      child: Ink(
                                        height: 54,
                                        decoration: BoxDecoration(
                                          color: AllineColors.primary,
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AllineColors.primary
                                                  .withValues(alpha: 0.18),
                                              blurRadius: 14,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: isLoading
                                              ? const SizedBox(
                                                  width: 22,
                                                  height: 22,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2.5,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 28,
                                                      height: 28,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.white
                                                            .withValues(
                                                                alpha: 0.2),
                                                      ),
                                                      child: const Icon(
                                                        Icons
                                                            .arrow_back_rounded,
                                                        color: Colors.white,
                                                        size: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      'متابعة',
                                                      style: textBold.copyWith(
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 16),

                              // Divider ("أو")
                              Row(
                                children: [
                                  Expanded(
                                      child: Divider(color: colors.border)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Text(
                                      'أو',
                                      style: textMedium.copyWith(
                                        fontSize: 12.5,
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      child: Divider(color: colors.border)),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Google Sign-in Button
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => googleLogin(context,
                                      widget.fromPage, widget.onLoginSuccess),
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    height: 54,
                                    decoration: BoxDecoration(
                                      color: colors.surface,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: colors.border),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.02),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(Images.google,
                                            width: 22, height: 22),
                                        const SizedBox(width: 10),
                                        Text(
                                          'الدخول باستخدام Google',
                                          style: textBold.copyWith(
                                            fontSize: 14.5,
                                            color: colors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Reuse the existing registration flow.
                              Consumer<AuthController>(
                                builder: (context, authProvider, _) => SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: authProvider.isLoading ||
                                            authProvider
                                                .isPhoneNumberVerificationButtonLoading
                                        ? null
                                        : () => RouterHelper.getAuthScreenRoute(
                                              fromLogout: widget.fromLogout,
                                              fromPage: widget.fromPage,
                                              onLoginSuccess:
                                                  widget.onLoginSuccess,
                                            ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AllineColors.primary,
                                      minimumSize: const Size.fromHeight(50),
                                      side: BorderSide(color: colors.border),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      textStyle:
                                          textBold.copyWith(fontSize: 14.5),
                                    ),
                                    child: Text(
                                      getTranslated('sign_up', context) ??
                                          'إنشاء حساب',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Terms & Privacy Notice
                              Center(
                                child: Text.rich(
                                  TextSpan(
                                    text: 'باستخدامك Alline، أنت توافق على ',
                                    style: textRegular.copyWith(
                                      fontSize: 12,
                                      color: colors.textSecondary,
                                    ),
                                    children: [
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: InkWell(
                                          onTap: () {
                                            final page = _getPageBySlug(
                                                'terms-and-conditions',
                                                splashController
                                                    .defaultBusinessPages);
                                            if (page != null) {
                                              RouterHelper.getHtmlViewRoute(
                                                  page: page);
                                            }
                                          },
                                          child: Text(
                                            'الشروط',
                                            style: textMedium.copyWith(
                                              fontSize: 12,
                                              color: AllineColors.primary,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor:
                                                  AllineColors.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const TextSpan(text: ' و'),
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: InkWell(
                                          onTap: () {
                                            final page = _getPageBySlug(
                                                'privacy-policy',
                                                splashController
                                                    .defaultBusinessPages);
                                            if (page != null) {
                                              RouterHelper.getHtmlViewRoute(
                                                  page: page);
                                            }
                                          },
                                          child: Text(
                                            'سياسة الخصوصية',
                                            style: textMedium.copyWith(
                                              fontSize: 12,
                                              color: AllineColors.primary,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor:
                                                  AllineColors.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Continue as Guest Option
                        Center(
                          child: InkWell(
                            onTap: () {
                              final auth = Provider.of<AuthController>(context,
                                  listen: false);
                              if (!auth.isLoading) {
                                auth.removeGoogleLogIn();
                                auth.getGuestIdUrl();
                                RouterHelper.getDashboardRoute(
                                    action:
                                        RouteAction.pushNamedAndRemoveUntil);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Text(
                                'تصفح كزائر',
                                style: textMedium.copyWith(
                                  fontSize: 13.5,
                                  color: colors.textSecondary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
