import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/domain/models/signup_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/domain/models/user_log_data.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/enums/from_page.dart';
import 'package:flutter_sixvalley_ecommerce/features/order_details/controllers/order_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/config_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/email_checker_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/number_checker_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class VerificationScreen extends StatefulWidget {
  final String? userInput;
  final FromPage fromPage;
  final bool fromDigitalProduct;
  final int? orderId;
  final String? session;
  final String? toNavigateScreen;
  final VoidCallback? onLoginSuccess;

  const VerificationScreen(
    this.userInput,
    this.fromPage, {
    super.key,
    this.session,
    this.fromDigitalProduct = false,
    this.orderId,
    this.toNavigateScreen,
    this.onLoginSuccess,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  // Alline Design Tokens (per ALLINE_LOGIN_DESIGN.md)
  static const Color primaryBlue = Color(0xFF015FC9);
  static const Color darkBlue = Color(0xFF032C75);
  static const Color primaryText = Color(0xFF071B49);
  static const Color secondaryText = Color(0xFF6D85AF);
  static const Color borderColor = Color(0xFFE1E8F2);
  static const Color errorColor = Color(0xFFD9363E);
  static const Color buttonDisabled = Color(0xFFB8C9DE);

  Timer? _timer;
  int _seconds = 45;
  bool _isPhone = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isPhone = EmailCheckerHelper.isNotValid(widget.userInput.toString());
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    final config = Provider.of<SplashController>(context, listen: false).configModel;
    final int configuredTime = config?.otpResendTime ?? 45;
    _seconds = configuredTime > 1 ? configuredTime : 45;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_seconds <= 1) {
        timer.cancel();
        setState(() => _seconds = 0);
      } else {
        setState(() => _seconds -= 1);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return '+967 7XX XXX XXX';
    String clean = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (clean.startsWith('+967') && clean.length >= 13) {
      return '+967 ${clean.substring(4, 7)} ${clean.substring(7, 10)} ${clean.substring(10)}';
    } else if (clean.startsWith('967') && clean.length >= 12) {
      return '+967 ${clean.substring(3, 6)} ${clean.substring(6, 9)} ${clean.substring(9)}';
    } else if (clean.length == 9) {
      return '+967 ${clean.substring(0, 3)} ${clean.substring(3, 6)} ${clean.substring(6)}';
    }
    return phone;
  }

  void _handleVerify(
    AuthController authProvider,
    ConfigModel config,
    bool isPhone,
    bool isFirebaseOTP,
  ) {
    if (authProvider.verificationCode.length < 6) return;

    setState(() {
      _hasError = false;
      _errorMessage = null;
    });

    if (widget.fromDigitalProduct) {
      Provider.of<OrderDetailsController>(context, listen: false)
          .verifyDigitalProductOtp(
        orderId: widget.orderId!,
        otp: authProvider.verificationCode,
      )
          .then((value) {
        if (value.response?.statusCode == 200) {
          if (mounted) Navigator.of(context).pop();
        } else {
          if (mounted) {
            setState(() {
              _hasError = true;
              _errorMessage = getTranslated('input_valid_otp', context) ?? 'رمز التحقق غير صحيح';
            });
            showCustomSnackBarWidget(
              _errorMessage!,
              context,
              snackBarType: SnackBarType.warning,
            );
          }
        }
      });
      return;
    }

    if (widget.fromPage == FromPage.login) {
      if (config.customerVerification?.status == 1) {
        if (isPhone && isFirebaseOTP) {
          authProvider.firebaseOtpLogin(
            phoneNumber: widget.userInput ?? '',
            session: '${widget.session}',
            otp: authProvider.verificationCode,
          );
        } else if (isPhone && config.customerVerification?.phone == 1) {
          authProvider.verifyPhone(widget.userInput ?? '', '').then((value) {
            if (value.isSuccess && mounted) {
              authProvider.navigateToHome(widget.toNavigateScreen, widget.onLoginSuccess);
            } else if (mounted) {
              setState(() {
                _hasError = true;
                _errorMessage = value.message ?? 'رمز التحقق غير صحيح';
              });
            }
          });
        } else if (!isPhone && config.customerVerification?.email == 1) {
          authProvider.verifyEmail(widget.userInput ?? '').then((value) {
            if (value.isSuccess && mounted) {
              authProvider.navigateToHome(widget.toNavigateScreen, widget.onLoginSuccess);
            } else if (mounted) {
              setState(() {
                _hasError = true;
                _errorMessage = value.message ?? 'رمز التحقق غير صحيح';
              });
            }
          });
        }
      }
    } else if (widget.fromPage == FromPage.otpLogin ||
        widget.fromPage == FromPage.otpRegistration) {
      if (config.customerVerification?.firebase == 1) {
        authProvider.firebaseOtpLogin(
          phoneNumber: widget.userInput ?? '',
          session: authProvider.verificationID ?? '',
          otp: authProvider.verificationCode,
          toNavigateScreen: widget.toNavigateScreen,
          onLoginSuccess: widget.onLoginSuccess,
        );
      } else {
        authProvider.verifyPhoneForOtp(widget.userInput ?? '').then((value) {
          final (responseModel, tempToken) = value;
          if ((responseModel != null && responseModel.isSuccess) && tempToken == null) {
            if (widget.fromPage == FromPage.otpRegistration) {
              authProvider.clearPendingOtpRegistration();
            }
            if (authProvider.isActiveRememberMe) {
              String userCountryCode =
                  NumberCheckerHelper.getCountryCode(widget.userInput) ?? '+967';
              authProvider.saveUserEmailAndPassword(UserLogData(
                countryCode: userCountryCode,
                phoneNumber: widget.userInput?.substring(userCountryCode.length),
                email: null,
                password: null,
              ));
            } else {
              authProvider.clearUserEmailAndPassword();
            }
            if (mounted) {
              authProvider.navigateToHome(widget.toNavigateScreen, widget.onLoginSuccess);
            }
          } else if ((responseModel != null && responseModel.isSuccess) && tempToken != null) {
            if (widget.fromPage == FromPage.otpRegistration) {
              authProvider
                  .completePendingOtpRegistration(
                temporaryToken: tempToken,
                phone: widget.userInput ?? '',
              )
                  .then((registrationResponse) {
                if (registrationResponse.isSuccess && mounted) {
                  authProvider.navigateToHome(
                    widget.toNavigateScreen,
                    widget.onLoginSuccess,
                    isNewUser: true,
                  );
                } else if (mounted) {
                  RouterHelper.getOtpRegistrationRoute(
                    tempToken: tempToken,
                    userInput: widget.userInput ?? '',
                    action: RouteAction.push,
                    toNavigateScreen: widget.toNavigateScreen,
                    onLoginSuccess: widget.onLoginSuccess,
                  );
                }
              });
            } else if (mounted) {
              RouterHelper.getOtpRegistrationRoute(
                tempToken: tempToken,
                userInput: widget.userInput ?? '',
                action: RouteAction.push,
                toNavigateScreen: widget.toNavigateScreen,
                onLoginSuccess: widget.onLoginSuccess,
              );
            }
          } else if (mounted) {
            setState(() {
              _hasError = true;
              _errorMessage = responseModel?.message ?? 'رمز التحقق غير صحيح';
            });
            showCustomSnackBarWidget(
              _errorMessage!,
              context,
              snackBarType: SnackBarType.warning,
            );
          }
        });
      }
    } else if (widget.fromPage == FromPage.profile) {
      String type = isPhone ? 'phone' : 'email';
      authProvider.verifyProfileInfo(widget.userInput!, type).then((value) {
        if (value.isSuccess && mounted) {
          RouterHelper.getProfileScreen1Route(action: RouteAction.pushNamedAndRemoveUntil);
        } else if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = value.message ?? 'رمز التحقق غير صحيح';
          });
        }
      });
    } else {
      // Forget password
      if (isFirebaseOTP && isPhone) {
        authProvider.firebaseOtpLogin(
          phoneNumber: widget.userInput ?? '',
          session: '${widget.session}',
          otp: authProvider.verificationCode,
          isForgetPassword: true,
        );
      } else {
        authProvider.verifyToken(widget.userInput ?? '').then((value) {
          if (value.isSuccess && mounted) {
            RouterHelper.getResetPasswordRoute(
              mobileNumber: widget.userInput ?? '',
              otp: authProvider.verificationCode,
              action: RouteAction.push,
            );
          } else {
            if (mounted) {
              setState(() {
                _hasError = true;
                _errorMessage = value.message ?? 'رمز التحقق غير صحيح';
              });
              showCustomSnackBarWidget(
                _errorMessage!,
                context,
                snackBarType: SnackBarType.warning,
              );
            }
          }
        });
      }
    }
  }

  void _handleResend(
    AuthController authProvider,
    ConfigModel config,
    bool isPhone,
  ) async {
    setState(() {
      _hasError = false;
      _errorMessage = null;
    });

    if (widget.fromPage != FromPage.forgetPassword) {
      await authProvider.sendVerificationCode(
        config,
        SignUpModel(
          phone: widget.userInput,
          email: widget.userInput,
        ),
        type: isPhone ? 'phone' : 'email',
        fromPage: FromPage.verification,
        isResend: true,
      );
      _startTimer();
    } else {
      _startTimer();
      final value = await authProvider.forgetPassword(
        config: config,
        phoneOrEmail: widget.userInput ?? '',
        type: isPhone ? 'phone' : 'email',
        isResend: true,
      );
      if (value != null && value.isSuccess && mounted) {
        showCustomSnackBarWidget(
          getTranslated('resend_code_successful', context) ??
              'تمت إعادة إرسال رمز التحقق بنجاح',
          context,
          snackBarType: SnackBarType.success,
        );
      } else if (value != null && mounted) {
        showCustomSnackBarWidget(
          value.message ?? 'فشل إعادة إرسال الرمز',
          context,
          snackBarType: SnackBarType.warning,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ConfigModel config =
        Provider.of<SplashController>(context, listen: false).configModel ?? ConfigModel();
    final bool isFirebaseOTP =
        config.customerVerification?.status == 1 && config.customerVerification?.firebase == 1;

    int minutes = (_seconds / 60).truncate();
    int sec = _seconds % 60;
    String timerStr =
        '${minutes.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFFFFFFF),
                Color(0xFFF4F8FE),
              ],
              stops: [0.0, 0.7, 1.0],
            ),
          ),
          child: SafeArea(
            child: Consumer<AuthController>(
              builder: (context, authProvider, _) {
                final bool isVerifying =
                    authProvider.isPhoneNumberVerificationButtonLoading ||
                    authProvider.isLoading;
                final bool canSubmit =
                    authProvider.verificationCode.length == 6 && !isVerifying;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Top Navigation: Back Button in RTL (Top Right)
                      Align(
                        alignment: AlignmentDirectional.topStart,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: borderColor, width: 1.2),
                              boxShadow: [
                                BoxShadow(
                                  color: darkBlue.withOpacity(0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                size: 22,
                                color: primaryBlue,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Original Alline Logo
                      Image.asset(
                        'assets/images/alline/login_logo_transparent.png',
                        width: 88,
                        height: 88,
                        fit: BoxFit.contain,
                      ),

                      const SizedBox(height: 24),

                      // Main Heading
                      const Text(
                        'التحقق من رقم الهاتف',
                        style: TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 27,
                          fontWeight: FontWeight.w700,
                          color: darkBlue,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 10),

                      // Supporting Text
                      const Text(
                        'أدخل رمز التحقق المرسل إلى',
                        style: TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: secondaryText,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 6),

                      // Phone Number in LTR
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          _formatPhoneNumber(widget.userInput),
                          style: const TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: primaryText,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Error message if code is incorrect
                      if (_hasError && _errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontFamily: 'AllineTajawal',
                              color: errorColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // Six-digit OTP input
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: PinCodeTextField(
                          length: 6,
                          appContext: context,
                          obscureText: false,
                          showCursor: true,
                          autoFocus: true,
                          cursorColor: primaryBlue,
                          keyboardType: TextInputType.number,
                          animationType: AnimationType.fade,
                          mainAxisAlignment: MainAxisAlignment.center,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            fieldHeight: 56,
                            fieldWidth: 48,
                            fieldOuterPadding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            borderWidth: 1.5,
                            borderRadius: BorderRadius.circular(14),
                            selectedColor: primaryBlue,
                            selectedFillColor: Colors.white,
                            inactiveFillColor: Colors.white,
                            inactiveColor: _hasError ? errorColor : borderColor,
                            activeColor: primaryBlue,
                            activeFillColor: Colors.white,
                            errorBorderColor: errorColor,
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 23,
                            fontWeight: FontWeight.w700,
                            color: primaryText,
                          ),
                          animationDuration: const Duration(milliseconds: 200),
                          backgroundColor: Colors.transparent,
                          enableActiveFill: true,
                          onChanged: (code) {
                            if (_hasError) {
                              setState(() {
                                _hasError = false;
                                _errorMessage = null;
                              });
                            }
                            authProvider.updateVerificationCode(code);
                          },
                          onCompleted: (code) {
                            authProvider.updateVerificationCode(code);
                            _handleVerify(
                              authProvider,
                              config,
                              _isPhone,
                              isFirebaseOTP,
                            );
                          },
                          beforeTextPaste: (text) => true,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Resend Section
                      const Text(
                        'لم يصلك الرمز؟',
                        style: TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: secondaryText,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 6),

                      if (_seconds > 0)
                        Text(
                          'إعادة إرسال الرمز بعد $timerStr',
                          style: const TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: secondaryText,
                          ),
                          textAlign: TextAlign.center,
                        )
                      else
                        authProvider.resendButtonLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(primaryBlue),
                                ),
                              )
                            : InkWell(
                                onTap: () => _handleResend(
                                  authProvider,
                                  config,
                                  _isPhone,
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                  child: Text(
                                    'إعادة إرسال الرمز',
                                    style: TextStyle(
                                      fontFamily: 'AllineTajawal',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: primaryBlue,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),

                      const SizedBox(height: 24),

                      // Primary CTA: Verify Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: canSubmit
                              ? () => _handleVerify(
                                    authProvider,
                                    config,
                                    _isPhone,
                                    isFirebaseOTP,
                                  )
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            disabledBackgroundColor: buttonDisabled,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isVerifying
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'جارٍ التحقق...',
                                      style: TextStyle(
                                        fontFamily: 'AllineTajawal',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                )
                              : const Text(
                                  'تحقق',
                                  style: TextStyle(
                                    fontFamily: 'AllineTajawal',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Change Phone Number
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'رقم الهاتف غير صحيح؟ ',
                                style: TextStyle(
                                  fontFamily: 'AllineTajawal',
                                  fontSize: 14,
                                  color: secondaryText,
                                ),
                              ),
                              TextSpan(
                                text: 'تغيير الرقم',
                                style: TextStyle(
                                  fontFamily: 'AllineTajawal',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: primaryBlue,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Security Hint
                      const Icon(
                        Icons.shield_outlined,
                        size: 26,
                        color: secondaryText,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'رمز التحقق صالح لفترة محدودة ولا تشاركه مع أي شخص.',
                        style: TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 12.5,
                          color: secondaryText,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
