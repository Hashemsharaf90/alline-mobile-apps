import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_textfield_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/enums/from_page.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/widgets/condition_check_box_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/widgets/social_login_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/config_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/velidate_check.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
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

  @override
  Widget build(BuildContext context) {
    final ConfigModel? configModel =
        Provider.of<SplashController>(context, listen: false).configModel;
    final SocialMediaLoginOptions? socialStatus =
        configModel?.customerLogin?.socialMediaLoginOptions;
    final bool showSocial =
        (configModel?.customerLogin?.loginOption?.socialMediaLogin == 1) &&
            ((socialStatus?.apple == 1 &&
                    defaultTargetPlatform == TargetPlatform.iOS) ||
                socialStatus?.google == 1);

    return Consumer<AuthController>(builder: (context, authController, _) {
      return Form(
        key: _formKey,
        child: Column(children: [
          _fieldContainer(
            child: CustomTextFieldWidget(
              hintText: getTranslated('full_name', context),
              labelText: getTranslated('full_name', context),
              labelTextStyle: textRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              inputType: TextInputType.name,
              required: true,
              focusNode: _nameFocus,
              nextFocus: _phoneFocus,
              prefixIcon: Images.username,
              capitalization: TextCapitalization.words,
              controller: _nameController,
              validator: (value) => ValidateCheck.validateEmptyText(
                value,
                'full_name_is_required',
              ),
            ),
          ),
          _fieldContainer(
            child: CustomTextFieldWidget(
              hintText: getTranslated('enter_mobile_number', context),
              labelText: getTranslated('enter_mobile_number', context),
              labelTextStyle: textRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              controller: _phoneController,
              focusNode: _phoneFocus,
              nextFocus: _emailFocus,
              required: true,
              showCodePicker: true,
              countryDialCode: authController.countryDialCode,
              onCountryChanged: (CountryCode countryCode) {
                _phoneFocus.requestFocus();
                authController.setCountryCode(countryCode.dialCode!);
              },
              isAmount: true,
              validator: (value) => ValidateCheck.validatePhoneNoText(
                value,
                authController.countryDialCode,
                'phone_must_be_required',
              ),
              inputAction: TextInputAction.next,
              inputType: TextInputType.phone,
            ),
          ),
          _fieldContainer(
            child: CustomTextFieldWidget(
              hintText: getTranslated('email_optional', context),
              labelText: getTranslated('email_optional', context),
              labelTextStyle: textRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              focusNode: _emailFocus,
              nextFocus: _referFocus,
              inputType: TextInputType.emailAddress,
              controller: _emailController,
              prefixIcon: Images.email,
              validator: (value) => (value?.trim().isEmpty ?? true)
                  ? null
                  : ValidateCheck.validateEmail(value),
            ),
          ),
          if (Provider.of<SplashController>(context, listen: false)
                  .configModel
                  ?.refEarningStatus ==
              '1')
            _fieldContainer(
              child: CustomTextFieldWidget(
                hintText: getTranslated('enter_refer_code', context),
                labelText: getTranslated('referral_code', context),
                labelTextStyle: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                controller: _referController,
                focusNode: _referFocus,
                prefixIcon: Images.referImage,
                prefixColor: Theme.of(context).primaryColor,
                inputAction: TextInputAction.done,
              ),
            ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          const ConditionCheckBox(),
          Container(
            margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: CustomButton(
              isLoading: authController.isPhoneNumberVerificationButtonLoading,
              onTap: authController.isAcceptTerms
                  ? () => _sendOtp(authController)
                  : null,
              buttonText: getTranslated('send_otp', context),
            ),
          ),
          if (showSocial) ...[
            Center(
              child: Text(
                getTranslated('or', context)!,
                style: titilliumRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
              ),
              child: SocialLoginWidget(
                fromPage: widget.fromPage,
                onLoginSuccess: widget.onLoginSuccess,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
          ],
          if (!authController.isPhoneNumberVerificationButtonLoading)
            Padding(
              padding: const EdgeInsets.only(
                bottom: Dimensions.paddingSizeExtraLarge,
              ),
              child: InkWell(
                onTap: () {
                  authController.getGuestIdUrl();
                  Navigator.pop(context);
                },
                child: Column(children: [
                  Text(
                    getTranslated('already_have_account', context)!,
                    style: titleRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                  Text(
                    getTranslated('sign_in', context)!,
                    style: titilliumRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ]),
              ),
            ),
        ]),
      );
    });
  }

  Widget _fieldContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(
        left: Dimensions.marginSizeDefault,
        right: Dimensions.marginSizeDefault,
        top: Dimensions.marginSizeSmall,
      ),
      child: child,
    );
  }
}
