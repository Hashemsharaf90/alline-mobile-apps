import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  final TextEditingController _referController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _referFocus = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final countryCode = Provider.of<SplashController>(context, listen: false)
            .configModel
            ?.countryCode ??
        'YE';
    final dialCode =
        CountryCode.fromCountryCode(countryCode).dialCode ?? '+967';
    Provider.of<AuthController>(context, listen: false)
        .setCountryCode(dialCode, notify: false);
    _referController.text = widget.referCode ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _referController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _referFocus.dispose();
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
      referralCode: _referController.text,
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

  static const _blue = Color(0xFF0866F5),
      _ink = Color(0xFF10244A),
      _muted = Color(0xFF6B7D99);
  TextStyle _text(double size, {Color color = _ink, bool bold = false}) =>
      TextStyle(
          fontFamily: 'AllineTajawal',
          fontSize: size,
          height: 1.4,
          color: color,
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
    final showReferral = configModel?.refEarningStatus == '1';
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
                    label: getTranslated('phone', context)!,
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
                    prefix: SizedBox(
                        width: 116,
                        child: Directionality(
                            textDirection: TextDirection.ltr,
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
                              dialogBackgroundColor: Colors.white,
                              textStyle: _text(14, bold: true),
                            )))),
                _field(
                    fieldKey: 'signup-email',
                    label: getTranslated('email_optional', context)!,
                    hint: 'name@example.com',
                    controller: _emailController,
                    focus: _emailFocus,
                    next: showReferral ? _referFocus : null,
                    type: TextInputType.emailAddress,
                    autofill: AutofillHints.email,
                    ltr: true,
                    icon: Icons.mail_outline_rounded,
                    validator: (value) => (value?.trim().isEmpty ?? true)
                        ? null
                        : ValidateCheck.validateEmail(value)),
                if (showReferral)
                  _field(
                      fieldKey: 'signup-referral',
                      label: getTranslated('referral_code', context)!,
                      hint: getTranslated('enter_refer_code', context)!,
                      controller: _referController,
                      focus: _referFocus,
                      icon: Icons.card_giftcard_rounded),
                _terms(auth),
                const SizedBox(height: 18),
                ElevatedButton(
                    key: const ValueKey('signup-submit'),
                    onPressed: auth.isAcceptTerms && !loading
                        ? () => _sendOtp(auth)
                        : null,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _blue,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFE7EFFA),
                        disabledForegroundColor: const Color(0xFF7183A0),
                        elevation: 0,
                        minimumSize: const Size.fromHeight(54),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))),
                    child: loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: _blue))
                        : Text(getTranslated('send_otp', context)!,
                            textAlign: TextAlign.center,
                            style: _text(17,
                                color: auth.isAcceptTerms
                                    ? Colors.white
                                    : const Color(0xFF7183A0),
                                bold: true))),
                if (showSocial) ...[
                  const SizedBox(height: 20),
                  Row(children: [
                    const Expanded(child: Divider(color: Color(0xFFE4ECF7))),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(getTranslated('OR', context)!,
                            style: _text(13, color: _muted))),
                    const Expanded(child: Divider(color: Color(0xFFE4ECF7))),
                  ]),
                  const SizedBox(height: 16),
                  if (socialStatus?.google == 1)
                    _socialButton(
                        Images.google,
                        'continue_with_google',
                        () => googleLogin(
                            context, widget.fromPage, widget.onLoginSuccess)),
                  if (socialStatus?.apple == 1 &&
                      defaultTargetPlatform == TargetPlatform.iOS) ...[
                    if (socialStatus?.google == 1) const SizedBox(height: 12),
                    _socialButton(
                        Images.appleLogo,
                        'continue_with_apple',
                        () => appleLogin(
                            context, widget.fromPage, widget.onLoginSuccess)),
                  ],
                ],
                if (!loading) ...[
                  const SizedBox(height: 18),
                  Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(getTranslated('already_have_account', context)!,
                            style: _text(13, color: _muted)),
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
              foregroundColor: _ink,
              side: const BorderSide(color: Color(0xFFDEE7F3)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset(image, width: 21, height: 21),
            const SizedBox(width: 10),
            Flexible(
                child: Text(getTranslated(label, context)!,
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
    String? Function(String?)? validator,
  }) {
    final border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDEE7F3)));
    return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text.rich(
              TextSpan(text: label, children: [
                if (required)
                  const TextSpan(
                      text: ' *', style: TextStyle(color: Color(0xFFC33C42))),
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
                  hintStyle: _text(14, color: const Color(0xFF98A7BB)),
                  filled: true,
                  fillColor: const Color(0xFFFAFCFF),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  prefixIcon: prefix ??
                      (icon != null
                          ? Icon(icon, size: 21, color: _muted)
                          : null),
                  border: border,
                  enabledBorder: border,
                  focusedBorder: border.copyWith(
                      borderSide: const BorderSide(color: _blue, width: 1.5)),
                  errorBorder: border.copyWith(
                      borderSide: const BorderSide(color: Color(0xFFC33C42))),
                  focusedErrorBorder: border.copyWith(
                      borderSide: const BorderSide(
                          color: Color(0xFFC33C42), width: 1.5)),
                  errorStyle: _text(12, color: const Color(0xFFC33C42)),
                  errorMaxLines: 3,
                ),
              )),
        ]));
  }

  Widget _terms(AuthController auth) {
    BusinessPageModel? terms;
    for (final page in context.read<SplashController>().defaultBusinessPages ??
        <BusinessPageModel>[]) {
      if (page.slug == 'terms-and-conditions') {
        terms = page;
        break;
      }
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
          width: 36,
          height: 44,
          child: Checkbox(
              value: auth.isAcceptTerms,
              onChanged: (_) => auth.toggleTermsCheck(),
              activeColor: _blue,
              side: const BorderSide(color: Color(0xFFAABDD7)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              semanticLabel: getTranslated('i_agree_with_the', context))),
      const SizedBox(width: 4),
      Expanded(
          child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
        Text(getTranslated('i_agree_with_the', context)!,
            style: _text(13, color: _muted)),
        TextButton(
            onPressed: terms == null
                ? null
                : () => RouterHelper.getHtmlViewRoute(page: terms!),
            style: TextButton.styleFrom(
                foregroundColor: _blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 10)),
            child: Text(getTranslated('terms_condition', context)!,
                style: _text(13, color: _blue, bold: true)
                    .copyWith(decoration: TextDecoration.underline))),
      ])),
    ]);
  }
}
