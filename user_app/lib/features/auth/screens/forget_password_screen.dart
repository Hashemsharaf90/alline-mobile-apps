import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/config_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_textfield_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/enums/from_page.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});
  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  TextEditingController? _userInputController;
  String? _countryCode;
  bool _usePhone = true;

  final GlobalKey<ScaffoldMessengerState> _key = GlobalKey();

  final GlobalKey<FormState> forgetFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    _userInputController = TextEditingController();
    final AuthController authProvider =
        Provider.of<AuthController>(context, listen: false);

    authProvider.clearVerificationMessage();
    authProvider.setIsLoading = false;
    authProvider.setIsPhoneVerificationButttonLoading = false;
    authProvider.toggleIsNumberLogin(value: false, isUpdate: false);
    final configuredCountry =
        Provider.of<SplashController>(context, listen: false)
            .configModel
            ?.countryCode;
    _countryCode = CountryCode.fromCountryCode(
            (configuredCountry?.isNotEmpty ?? false) ? configuredCountry! : 'YE')
        .dialCode;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ConfigModel configModel =
        Provider.of<SplashController>(context, listen: false).configModel!;
    return Scaffold(
      key: _key,
      appBar: CustomAppBar(title: getTranslated('forget_password', context)),
      body: Consumer<AuthController>(builder: (context, authProvider, _) {
        return Consumer<SplashController>(
            builder: (context, splashProvider, _) {
          return Form(
            key: forgetFormKey,
            child: ListView(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                children: [
                  Center(
                      child: Padding(
                          padding: const EdgeInsets.all(50),
                          child: Image.asset(Images.logoWithNameImage,
                              height: 150, width: 150))),
                  Text(getTranslated('forget_password', context)!,
                      textAlign: TextAlign.center,
                      style: textBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: Theme.of(context).textTheme.bodyLarge?.color)),
                  Row(children: [
                    _resetModeButton(context, phone: true),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    _resetModeButton(context, phone: false),
                  ]),
                  const SizedBox(height: Dimensions.marginSizeAuthSmall),
                  Text(
                      getTranslated(
                          _usePhone
                              ? 'enter_phone_number_for_password_reset'
                              : 'enter_email_for_password_reset',
                          context)!,
                      textAlign: TextAlign.center,
                      style: textRegular.copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: Dimensions.fontSizeDefault,
                      )),
                  const SizedBox(height: Dimensions.marginSizeAuthSmall),
                  CustomTextFieldWidget(
                    countryDialCode: _usePhone ? _countryCode : null,
                    showCodePicker: _usePhone,
                    onCountryChanged: (CountryCode value) {
                      _countryCode = value.dialCode;
                    },
                    hintText: '',
                    isShowBorder: true,
                    controller: _userInputController,
                    inputType: _usePhone
                        ? TextInputType.phone
                        : TextInputType.emailAddress,
                    labelText:
                        getTranslated(_usePhone ? 'phone' : 'email', context),
                  ),
                  const SizedBox(height: Dimensions.bannerPadding),
                  CustomButton(
                    isLoading: (authProvider.isLoading ||
                        authProvider.isForgotPasswordLoading ||
                        authProvider.resendButtonLoading),
                    buttonText: getTranslated('send', context),
                    onTap: () async {
                      if (forgetFormKey.currentState?.validate() ?? false) {
                        if (_userInputController!.text.isEmpty) {
                          showCustomSnackBarWidget(
                              getTranslated('enter_email_or_phone', context),
                              context,
                              snackBarType: SnackBarType.warning);
                        } else if (!_usePhone &&
                            !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                .hasMatch(_userInputController!.text.trim())) {
                          showCustomSnackBarWidget(
                              getTranslated('email_is_required', context),
                              context,
                              snackBarType: SnackBarType.warning);
                        } else {
                          String userInput = _userInputController!.text.trim();
                          bool isNumber = _usePhone;

                          if (isNumber) {
                            userInput = _countryCode! + userInput;
                          }

                          ResponseModel? response =
                              await authProvider.forgetPassword(
                                  config: configModel,
                                  phoneOrEmail: userInput,
                                  type: isNumber ? 'phone' : 'email');

                          if (response != null && response.isSuccess) {
                            if (isNumber && !authProvider.sendToEmail) {
                              RouterHelper.getVerificationRoute(
                                userInput: userInput,
                                fromPage: FromPage.forgetPassword,
                                action: RouteAction.push,
                              );
                            } else {
                              if (context.mounted) {
                                showCustomSnackBarWidget(
                                    response.message, context,
                                    snackBarType: SnackBarType.warning);
                              }
                            }
                          } else if (response != null && !response.isSuccess) {
                            if (context.mounted) {
                              showCustomSnackBarWidget(
                                  response.message, context,
                                  snackBarType: SnackBarType.warning);
                            }
                          }
                        }
                      }
                    },
                  ),
                ]),
          );
        });
      }),
    );
  }

  Widget _resetModeButton(BuildContext context, {required bool phone}) {
    final selected = _usePhone == phone;
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () => setState(() {
          _usePhone = phone;
          _userInputController?.clear();
        }),
        icon: Icon(phone ? Icons.phone_android_rounded : Icons.email_outlined,
            size: 18),
        label: Text(getTranslated(phone ? 'phone' : 'email', context) ?? ''),
        style: OutlinedButton.styleFrom(
          foregroundColor: selected
              ? Theme.of(context).primaryColor
              : Theme.of(context).hintColor,
          backgroundColor: selected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.08)
              : null,
          side: BorderSide(
              color: selected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).hintColor.withValues(alpha: 0.35)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
