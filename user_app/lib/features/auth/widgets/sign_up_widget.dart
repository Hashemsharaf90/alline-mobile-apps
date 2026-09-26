import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/business_pages_model.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/enums/from_page.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/widgets/social_login_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/velidate_check.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:provider/provider.dart';

class SignUpWidget extends StatefulWidget {
  final bool fromLogout;
  final String? fromPage;
  final VoidCallback? onLoginSuccess;
  final String? referCode;

  const SignUpWidget({
    super.key,
    required this.fromLogout,
    this.fromPage,
    this.onLoginSuccess,
    this.referCode,
  });

  @override
  State<SignUpWidget> createState() => SignUpWidgetState();
}

class SignUpWidgetState extends State<SignUpWidget> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer();
    _privacyRecognizer = TapGestureRecognizer();
    final countryCode = Provider.of<SplashController>(context, listen: false)
            .configModel
            ?.countryCode ??
        'YE';
    final dialCode =
        CountryCode.fromCountryCode(countryCode).dialCode ?? '+967';
    Provider.of<AuthController>(context, listen: false)
        .setCountryCode(dialCode, notify: false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  Future<void> _sendOtp(AuthController authController) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final config =
        Provider.of<SplashController>(context, listen: false).configModel;
    if (config == null) {
      showCustomSnackBarWidget(
        getTranslated('server_connection_failed', context) ??
            'Server connection failed',
        context,
        snackBarType: SnackBarType.error,
      );
      return;
    }

    final phone = authController.countryDialCode + _phoneController.text.trim();
    authController.prepareOtpRegistration(
      name: _nameController.text,
      email: _emailController.text,
      referralCode: widget.referCode,
    );

    if (config.customerVerification?.firebase == 1) {
      await authController.firebaseVerifyPhoneNumber(
        phone,
        FromPage.otpRegistration,
        toNavigateScreen: widget.fromPage,
        onLoginSuccess: widget.onLoginSuccess,
      );
    } else {
      await authController.checkPhoneForOtp(
        phone,
        FromPage.otpRegistration,
        toNavigateScreen: widget.fromPage,
        onLoginSuccess: widget.onLoginSuccess,
      );
    }
  }

  static const _blue = AllineColors.primary,
      _brightBlue = AllineColors.brightBlue,
      _error = AllineColors.error;
  TextStyle _text(double size, {Color? color, bool bold = false}) =>
      TextStyle(
          fontFamily: 'AllineTajawal',
          fontSize: size,
          height: 1.4,
          color: color ?? context.allineColors.textPrimary,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400);

  @override
  Widget build(BuildContext context) {
    final configModel = context.read<SplashController>().configModel;
    final socialStatus = configModel?.customerLogin?.socialMediaLoginOptions;
    final showSocial =
        configModel?.customerLogin?.loginOption?.socialMediaLogin == 1 &&
            ((socialStatus?.apple == 1 &&
                    defaultTargetPlatform == TargetPlatform.iOS) ||
                socialStatus?.google == 1);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Consumer<AuthController>(builder: (context, auth, _) {
      final loading = auth.isPhoneNumberVerificationButtonLoading;
      return Form(
          key: _formKey,
          child: AutofillGroup(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                _field(
                    fieldKey: 'signup-name',
                    label: getTranslated('full_name', context)!,
                    hint: getTranslated('full_name', context)!,
                    required: true,
                    controller: _nameController,
                    focus: _nameFocus,
                    next: _phoneFocus,
                    type: TextInputType.name,
                    autofill: AutofillHints.name,
                    capitalization: TextCapitalization.words,
                    icon: Icons.person_outline_rounded,
                    validator: (value) => ValidateCheck.validateEmptyText(
                        value, 'full_name_is_required')),
                _field(
                    fieldKey: 'signup-phone',
                    label:
                        isArabic ? 'الهاتف' : getTranslated('phone', context)!,
                    hint: '7XX XXX XXX',
                    required: true,
                    controller: _phoneController,
                    focus: _phoneFocus,
                    next: _emailFocus,
                    type: TextInputType.phone,
                    autofill: AutofillHints.telephoneNumber,
                    ltr: true,
                    validator: (value) => ValidateCheck.validatePhoneNoText(
                        value, auth.countryDialCode, 'phone_must_be_required'),
                    helper: isArabic
                        ? 'سيتم إرسال رمز تحقق إلى هذا الرقم'
                        : 'A verification code will be sent to this number',
                    prefix: SizedBox(
                        width: 116,
                        child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: Row(children: [
                              Expanded(
                                  child: CountryCodePicker(
                                onChanged: (code) {
                                  _phoneFocus.requestFocus();
                                  auth.setCountryCode(code.dialCode!);
                                },
                                initialSelection: auth.countryDialCode,
                                favorite: [auth.countryDialCode],
                                padding: EdgeInsets.zero,
                                showFlagMain: true,
                                flagWidth: 20,
                                showDropDownButton: false,
                                dialogBackgroundColor: context.allineColors.surface,
                                textStyle: _text(14, bold: true),
                              )),
                              Container(width: 1, height: 24, color: context.allineColors.border),
                              const SizedBox(width: 8),
                            ])))),
                _field(
                    fieldKey: 'signup-email',
                    label: getTranslated('email_optional', context)!,
                    hint: 'name@example.com',
                    controller: _emailController,
                    focus: _emailFocus,
                    type: TextInputType.emailAddress,
                    autofill: AutofillHints.email,
                    ltr: true,
                    icon: Icons.mail_outline_rounded,
                    validator: (value) => (value?.trim().isEmpty ?? true)
                        ? null
                        : ValidateCheck.validateEmail(value)),
                _terms(auth),
                const SizedBox(height: 14),
                ElevatedButton(
                    key: const ValueKey('signup-submit'),
                    onPressed: auth.isAcceptTerms && !loading
                        ? () => _sendOtp(auth)
                        : null,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _blue,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            loading ? _blue : Theme.of(context).disabledColor.withValues(alpha: 0.12),
                        disabledForegroundColor: context.allineColors.textSecondary,
                        overlayColor: _brightBlue,
                        elevation: 0,
                        minimumSize: const Size.fromHeight(54),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))),
                    child: loading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                const SizedBox(
                                    width: 19,
                                    height: 19,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.2, color: Colors.white)),
                                const SizedBox(width: 10),
                                Text(
                                    isArabic
                                        ? 'جارٍ إرسال رمز التحقق...'
                                        : 'Sending verification code...',
                                    style: _text(15,
                                        color: Colors.white, bold: true)),
                              ])
                        : Text(getTranslated('send_otp', context)!,
                            textAlign: TextAlign.center,
                            style: _text(17,
                                color: auth.isAcceptTerms
                                    ? Colors.white
                                    : context.allineColors.textSecondary,
                                bold: true))),
                if (showSocial) ...[
                  const SizedBox(height: 18),
                  Row(children: [
                    Expanded(child: Divider(color: context.allineColors.border)),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(getTranslated('OR', context)!,
                            style: _text(13, color: context.allineColors.textSecondary))),
                    Expanded(child: Divider(color: context.allineColors.border)),
                  ]),
                  const SizedBox(height: 14),
                  if (socialStatus?.google == 1)
                    _socialButton(
                        Images.google,
                        isArabic
                            ? 'تواصل مع Google'
                            : getTranslated('continue_with_google', context)!,
                        () => googleLogin(
                            context, widget.fromPage, widget.onLoginSuccess)),
                  if (socialStatus?.apple == 1 &&
                      defaultTargetPlatform == TargetPlatform.iOS) ...[
                    if (socialStatus?.google == 1) const SizedBox(height: 12),
                    _socialButton(
                        Images.appleLogo,
                        getTranslated('continue_with_apple', context)!,
                        () => appleLogin(
                            context, widget.fromPage, widget.onLoginSuccess)),
                  ],
                ],
                if (!loading) ...[
                  const SizedBox(height: 14),
                  Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(getTranslated('already_have_account', context)!,
                            style: _text(13, color: context.allineColors.textSecondary)),
                        TextButton(
                            onPressed: () {
                              auth.getGuestIdUrl();
                              if (Navigator.of(context).canPop()) {
                                Navigator.pop(context);
                              } else {
                                RouterHelper.getLoginRoute(
                                    action: RouteAction.pushReplacement,
                                    isFromLogout: widget.fromLogout,
                                    fromPage: widget.fromPage,
                                    onLoginSuccess: widget.onLoginSuccess);
                              }
                            },
                            style: TextButton.styleFrom(
                                foregroundColor: _blue,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 12)),
                            child: Text(getTranslated('sign_in', context)!,
                                style: _text(14, color: _blue, bold: true))),
                      ]),
                ],
              ])));
    });
  }

  Widget _socialButton(String image, String label, VoidCallback onTap) =>
      OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
              foregroundColor: context.allineColors.textPrimary,
              minimumSize: const Size.fromHeight(54),
              side: BorderSide(color: context.allineColors.border),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset(image, width: 21, height: 21),
            const SizedBox(width: 10),
            Flexible(
                child: Text(label,
                    textAlign: TextAlign.center, style: _text(14, bold: true))),
          ]));

  Widget _field({
    required String fieldKey,
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focus,
    FocusNode? next,
    TextInputType type = TextInputType.text,
    String? autofill,
    bool required = false,
    bool ltr = false,
    TextCapitalization capitalization = TextCapitalization.none,
    IconData? icon,
    Widget? prefix,
    String? helper,
    String? Function(String?)? validator,
  }) {
    final border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: context.allineColors.border));
    return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text.rich(
              TextSpan(text: label, children: [
                if (required)
                  const TextSpan(text: ' *', style: TextStyle(color: _error)),
              ]),
              style: _text(14, bold: true)),
          const SizedBox(height: 8),
          Semantics(
              label: label,
              child: TextFormField(
                key: ValueKey(fieldKey),
                controller: controller,
                focusNode: focus,
                validator: validator,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: type,
                textInputAction:
                    next != null ? TextInputAction.next : TextInputAction.done,
                onFieldSubmitted: (_) =>
                    next != null ? next.requestFocus() : focus.unfocus(),
                textCapitalization: capitalization,
                autofillHints: autofill == null ? null : [autofill],
                textDirection: ltr ? TextDirection.ltr : null,
                style: _text(15),
                cursorColor: _blue,
                inputFormatters: type == TextInputType.phone
                    ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))]
                    : null,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: _text(14, color: context.allineColors.textSecondary),
                  filled: true,
                  fillColor: context.allineColors.surface,
                  constraints: const BoxConstraints(minHeight: 56),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  prefixIcon: prefix ??
                      (icon != null
                          ? Icon(icon, size: 21, color: context.allineColors.textSecondary)
                          : null),
                  border: border,
                  enabledBorder: border,
                  focusedBorder: border.copyWith(
                      borderSide: const BorderSide(color: _blue, width: 1.5)),
                  errorBorder: border.copyWith(
                      borderSide: const BorderSide(color: _error)),
                  focusedErrorBorder: border.copyWith(
                      borderSide: const BorderSide(color: _error, width: 1.5)),
                  errorStyle: _text(12, color: _error),
                  errorMaxLines: 3,
                ),
              )),
          if (helper != null) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 4),
              child: Text(helper,
                  style: _text(12, color: context.allineColors.textSecondary)),
            ),
          ],
        ]));
  }

  Widget _terms(AuthController auth) {
    BusinessPageModel? terms;
    BusinessPageModel? privacy;
    for (final page in context.read<SplashController>().defaultBusinessPages ??
        <BusinessPageModel>[]) {
      if (page.slug == 'terms-and-conditions') {
        terms = page;
      } else if (page.slug == 'privacy-policy') {
        privacy = page;
      }
    }
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    _termsRecognizer.onTap = terms == null
        ? null
        : () => RouterHelper.getHtmlViewRoute(page: terms!);
    _privacyRecognizer.onTap = privacy == null
        ? null
        : () => RouterHelper.getHtmlViewRoute(page: privacy!);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
          width: 44,
          height: 44,
          child: Checkbox(
              value: auth.isAcceptTerms,
              onChanged: (_) => auth.toggleTermsCheck(),
              activeColor: _blue,
              side: BorderSide(color: context.allineColors.textSecondary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              semanticLabel: getTranslated('i_agree_with_the', context))),
      const SizedBox(width: 2),
      Expanded(
          child: Padding(
        padding: const EdgeInsetsDirectional.only(top: 11),
        child: Text.rich(
          TextSpan(children: [
            TextSpan(text: isArabic ? 'أوافق على ' : 'I agree to the '),
            TextSpan(
                text: getTranslated('terms_condition', context)!,
                style: _text(13, color: _blue, bold: true),
                recognizer: _termsRecognizer),
            TextSpan(text: isArabic ? ' و' : ' and '),
            TextSpan(
                text: getTranslated('privacy_policy', context)!,
                style: _text(13, color: _blue, bold: true),
                recognizer: _privacyRecognizer),
          ]),
          style: _text(13, color: context.allineColors.textSecondary).copyWith(height: 1.65),
        ),
      )),
    ]);
  }
}
