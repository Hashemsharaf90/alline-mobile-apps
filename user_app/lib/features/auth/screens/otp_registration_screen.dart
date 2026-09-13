import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_textfield_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/domain/models/signup_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/domain/models/user_log_data.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/enums/from_page.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/number_checker_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/responsive_helper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';

class OtpRegistrationScreen extends StatefulWidget {
  final String tempToken;
  final String userInput;
  final String? userName;
  final String? toNavigateScreen;
  final VoidCallback? onLoginSuccess;
  const OtpRegistrationScreen(
      {super.key,
      required this.tempToken,
      required this.userInput,
      this.userName,
      this.toNavigateScreen,
      this.onLoginSuccess});

  @override
  State<OtpRegistrationScreen> createState() => _OtpRegistrationScreenState();
}

class _OtpRegistrationScreenState extends State<OtpRegistrationScreen> {
  TextEditingController? _emailController;
  TextEditingController? _nameController;
  TextEditingController? _phoneNumberController;
  TextEditingController? _passwordController;
  TextEditingController? _confirmPasswordController;
  String? countryCode;
  bool _addPassword = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _nameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    final configuredCountry =
        Provider.of<SplashController>(context, listen: false)
            .configModel
            ?.countryCode;
    countryCode ??= CountryCode.fromCountryCode(
            (configuredCountry?.isNotEmpty ?? false) ? configuredCountry! : 'YE')
        .dialCode;

    if (widget.userName != null && widget.userName!.isNotEmpty) {
      _nameController?.text = widget.userName!;
    }
  }

  @override
  void dispose() {
    _emailController?.dispose();
    _nameController?.dispose();
    _phoneNumberController?.dispose();
    _passwordController?.dispose();
    _confirmPasswordController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final Size size = MediaQuery.of(context).size;

    bool isNumber = NumberCheckerHelper.isNumber(
        widget.userInput.trim().replaceAll('+', ''));
    final configModel =
        Provider.of<SplashController>(context, listen: false).configModel!;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(height: size.height * 0.05),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: Container(
                    width: width > 600 ? 400 : width,
                    margin:
                        const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                    padding: width > 600
                        ? const EdgeInsets.all(Dimensions.paddingSizeDefault)
                        : null,
                    decoration: width > 600
                        ? BoxDecoration(
                            color: Theme.of(context).canvasColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color!
                                      .withValues(alpha: 0.07),
                                  blurRadius: 30,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 10))
                            ],
                          )
                        : null,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: ResponsiveHelper.isDesktop(context)
                                ? size.height * 0.05
                                : size.height * 0.14,
                          ),
                          const Directionality(
                            textDirection: TextDirection.ltr,
                            child: CustomAssetImageWidget(
                              Images.logoWithNameImage,
                              width: 150,
                              height: 140,
                              fit: BoxFit.scaleDown,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeExtraLarge),
                            child: Center(
                              child: Column(children: [
                                Text(
                                  getTranslated(
                                      'just_one_step_away_will_help_make_your_profile',
                                      context)!,
                                  textAlign: TextAlign.center,
                                  style: titilliumRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                                const SizedBox(height: 30),
                                CustomTextFieldWidget(
                                  isShowBorder: true,
                                  controller: _nameController,
                                  inputType: TextInputType.emailAddress,
                                  showLabelText: true,
                                  labelText: getTranslated('name', context)!,
                                  required: true,
                                  prefixIcon: Images.userSvg,
                                  prefixColor: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(
                                    height: Dimensions.paddingSizeLarge),
                                isNumber
                                    ? CustomTextFieldWidget(
                                        //hintText: getTranslated('demo_gmail', context),
                                        isShowBorder: true,
                                        hintText: '',
                                        controller: _emailController,
                                        inputType: TextInputType.emailAddress,
                                        labelText:
                                            getTranslated('email', context)!,
                                        prefixIcon: Images.mailIconSvg,
                                        prefixColor:
                                            Theme.of(context).primaryColor,
                                      )
                                    : CustomTextFieldWidget(
                                        showCodePicker: true,
                                        countryDialCode: countryCode,
                                        onCountryChanged: (CountryCode value) {
                                          countryCode = value.dialCode;
                                        },
                                        //hintText: getTranslated('demo_gmail', context),
                                        isShowBorder: true,
                                        hintText: '',
                                        controller: _phoneNumberController,
                                        inputType: TextInputType.phone,
                                        labelText: getTranslated(
                                            'mobile_number', context)!,
                                        prefixColor:
                                            Theme.of(context).primaryColor,
                                      ),
                                const SizedBox(
                                    height: Dimensions.paddingSizeLarge),
                                SwitchListTile.adaptive(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                      getTranslated('password', context) ?? ''),
                                  subtitle: Text(
                                      getTranslated('password_hint', context) ??
                                          ''),
                                  value: _addPassword,
                                  activeColor: Theme.of(context).primaryColor,
                                  onChanged: (value) =>
                                      setState(() => _addPassword = value),
                                ),
                                if (_addPassword) ...[
                                  CustomTextFieldWidget(
                                    isShowBorder: true,
                                    controller: _passwordController,
                                    inputType: TextInputType.visiblePassword,
                                    labelText:
                                        getTranslated('password', context),
                                    isPassword: true,
                                    required: true,
                                    prefixIcon: Images.lockSvg,
                                    prefixColor: Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(
                                      height: Dimensions.paddingSizeLarge),
                                  CustomTextFieldWidget(
                                    isShowBorder: true,
                                    controller: _confirmPasswordController,
                                    inputType: TextInputType.visiblePassword,
                                    labelText: getTranslated(
                                        'confirm_password', context),
                                    isPassword: true,
                                    required: true,
                                    prefixIcon: Images.lockSvg,
                                    prefixColor: Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(
                                      height: Dimensions.paddingSizeLarge),
                                ],
                                Consumer<AuthController>(
                                    builder: (context, authProvider, child) {
                                  return CustomButton(
                                    isLoading: authProvider
                                        .isPhoneNumberVerificationButtonLoading,
                                    buttonText: getTranslated('done', context)!,
                                    textColor: Theme.of(context).cardColor,
                                    fontSize: Dimensions.fontSizeDefault,
                                    onTap: () {
                                      String name =
                                          _nameController!.text.trim();
                                      String email =
                                          _emailController!.text.trim();
                                      String phone =
                                          _phoneNumberController!.text.trim();
                                      String password =
                                          _passwordController!.text.trim();
                                      String confirmPassword =
                                          _confirmPasswordController!.text
                                              .trim();

                                      if (_nameController!.text.isEmpty) {
                                        showCustomSnackBarWidget(
                                            getTranslated(
                                                'please_enter_your_name',
                                                context),
                                            context,
                                            snackBarType: SnackBarType.warning);
                                      } else if (!isNumber && phone.isEmpty) {
                                        showCustomSnackBarWidget(
                                            getTranslated(
                                                'enter_phone_number', context),
                                            context,
                                            snackBarType: SnackBarType.warning);
                                      } else if (_addPassword &&
                                          password.length < 8) {
                                        showCustomSnackBarWidget(
                                            getTranslated(
                                                'minimum_password_length',
                                                context),
                                            context,
                                            snackBarType: SnackBarType.warning);
                                      } else if (_addPassword &&
                                          password != confirmPassword) {
                                        showCustomSnackBarWidget(
                                            getTranslated(
                                                'password_did_not_match',
                                                context),
                                            context,
                                            snackBarType: SnackBarType.warning);
                                      } else {
                                        if (isNumber) {
                                          authProvider
                                              .registerWithOtp(name,
                                                  email: email,
                                                  phone: widget.userInput,
                                                  password: _addPassword
                                                      ? password
                                                      : null)
                                              .then((value) {
                                            if (value.isSuccess) {
                                              if (authProvider
                                                  .isActiveRememberMe) {
                                                String userCountryCode =
                                                    NumberCheckerHelper
                                                        .getCountryCode(
                                                            widget.userInput)!;
                                                authProvider
                                                    .saveUserEmailAndPassword(
                                                        UserLogData(
                                                  countryCode: userCountryCode,
                                                  phoneNumber: widget.userInput
                                                      .substring(userCountryCode
                                                          .length),
                                                  email: email,
                                                  password: _addPassword
                                                      ? password
                                                      : null,
                                                ));
                                              } else {
                                                authProvider
                                                    .clearUserEmailAndPassword();
                                              }
                                              if (context.mounted) {
                                                authProvider.navigateToHome(
                                                    widget.toNavigateScreen,
                                                    widget.onLoginSuccess);
                                              }
                                            }
                                          });
                                        } else {
                                          phone = countryCode! + phone;

                                          authProvider
                                              .registerWithSocialMedia(name,
                                                  email: widget.userInput,
                                                  phone: phone)
                                              .then((value) {
                                            final (responseModel, tempToken) =
                                                value;
                                            if (responseModel.isSuccess &&
                                                tempToken == null) {
                                              authProvider
                                                  .saveUserEmailAndPassword(
                                                      UserLogData(
                                                countryCode: countryCode,
                                                phoneNumber: phone,
                                                email: widget.userInput,
                                                password: null,
                                              ));

                                              if (context.mounted) {
                                                authProvider.navigateToHome(
                                                    widget.toNavigateScreen,
                                                    widget.onLoginSuccess);
                                              }
                                            } else if (responseModel
                                                    .isSuccess &&
                                                tempToken != null) {
                                              authProvider.sendVerificationCode(
                                                configModel,
                                                SignUpModel(phone: phone),
                                                type: 'phone',
                                                fromPage: FromPage.login,
                                              );
                                            }
                                          });
                                        }
                                      }
                                    },
                                  );
                                }),
                              ]),
                            ),
                          ),
                          if (ResponsiveHelper.isDesktop(context))
                            SizedBox(height: size.height * 0.05),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
