import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/auth/controllers/auth_controller.dart';
import 'package:sixvalley_vendor_app/features/auth/enums/from_page.dart';
import 'package:sixvalley_vendor_app/features/auth/screens/login_screen.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_dialog_widget.dart';
import 'package:sixvalley_vendor_app/features/auth/widgets/alline/alline_auth_header.dart';
import 'package:sixvalley_vendor_app/features/auth/widgets/reset_password_widget.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

class VerificationScreen extends StatefulWidget {
  final String mobileNumber;
  final String? session;
  final String? shopName;
  final String? password;
  final String? email;
  final FromPage fromPage;

  const VerificationScreen(
    this.mobileNumber, {
    super.key,
    this.session,
    this.shopName,
    this.password,
    this.email,
    this.fromPage = FromPage.login,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  Timer? _timer;
  int _seconds = 112; // 01:52 as requested
  String _currentOtp = '';
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initTimer();
  }

  void _initTimer() {
    final configResendTime =
        Provider.of<SplashController>(context, listen: false).configModel?.otpResendTime;
    if (configResendTime != null && configResendTime > 0) {
      _seconds = configResendTime;
    } else {
      _seconds = 112; // default 01:52
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() {
          _seconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTimer(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _getMaskedPhone(String phone) {
    if (phone.length <= 4) return phone;
    // Format e.g. +967 77***119
    if (phone.startsWith('967') && phone.length >= 11) {
      final prefix = phone.substring(0, 5); // 96777
      final suffix = phone.substring(phone.length - 3);
      return '+$prefix****$suffix';
    } else if (phone.length >= 7) {
      final prefix = phone.substring(0, 3);
      final suffix = phone.substring(phone.length - 2);
      return '$prefix****$suffix';
    }
    return phone;
  }

  void _resendCode() async {
    if (_seconds > 0) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authController = Provider.of<AuthController>(context, listen: false);
    final config = Provider.of<SplashController>(context, listen: false).configModel;

    await authController.forgotPassword(
      widget.mobileNumber,
      true,
      config,
      fromPage: FromPage.verification,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _seconds = 112;
    });
    _initTimer();

    showCustomSnackBarWidget(
      'تم إعادة إرسال رمز التحقق بنجاح',
      context,
      isError: false,
      sanckBarType: SnackBarType.success,
    );
  }

  void _verifyOtp() async {
    if (_currentOtp.length != 6) {
      setState(() {
        _errorMessage = 'يرجى إدخال رمز التحقق كاملاً (6 أرقام)';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authController = Provider.of<AuthController>(context, listen: false);

    // Call verifyOtp on controller
    final responseModel = await authController.verifyOtp(widget.mobileNumber);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (responseModel.isSuccess) {
      // Check flow origin
      if (widget.fromPage == FromPage.forgetPassword) {
        showAnimatedDialogWidget(
          context,
          ResetPasswordWidget(
            mobileNumber: widget.mobileNumber,
            otp: _currentOtp,
          ),
          dismissible: false,
          isFlip: true,
        );
      } else {
        // Successful verification
        showCustomSnackBarWidget(
          'تم التحقق من رقم الهاتف بنجاح',
          context,
          isError: false,
          sanckBarType: SnackBarType.success,
        );

        // Navigate to login or dashboard
        Navigator.pushAndRemoveUntil(
          Get.context!,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } else {
      final msg = responseModel.message ?? 'رمز التحقق غير صحيح، يرجى المحاولة مجدداً';
      setState(() {
        _errorMessage = msg;
      });
      showCustomSnackBarWidget(
        msg,
        context,
        sanckBarType: SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isComplete = _currentOtp.length == 6;

    return Scaffold(
      backgroundColor: ColorResources.getScaffoldBg(context),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AllineAuthHeader(
                title: 'تحقق من رقم هاتفك',
                subtitle: 'أرسلنا رمز تحقق إلى ${_getMaskedPhone(widget.mobileNumber)}',
                showBackButton: Navigator.canPop(context),
                onBackPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 10),

              // Action: Change Phone Number
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 14,
                        color: AllineColors.primary,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'تغيير رقم الهاتف',
                        style: TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AllineColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 6-Digit OTP Field
              Directionality(
                textDirection: TextDirection.ltr,
                child: PinCodeTextField(
                  length: 6,
                  appContext: context,
                  autoFocus: true,
                  obscureText: false,
                  showCursor: true,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,
                  textStyle: TextStyle(
                    fontFamily: 'AllineTajawal',
                    color: ColorResources.getTextTitle(context),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    fieldHeight: 52,
                    fieldWidth: 46,
                    borderWidth: 1.5,
                    borderRadius: BorderRadius.circular(14),
                    selectedColor: AllineColors.primary,
                    selectedFillColor: isDark ? AllineColors.darkCard : AllineColors.white,
                    inactiveFillColor: isDark ? AllineColors.darkCard : AllineColors.white,
                    inactiveColor: _errorMessage != null
                        ? AllineColors.error
                        : ColorResources.getBorder(context),
                    activeColor: _errorMessage != null
                        ? AllineColors.error
                        : AllineColors.primary,
                    activeFillColor: isDark ? AllineColors.darkCard : AllineColors.white,
                  ),
                  animationDuration: const Duration(milliseconds: 200),
                  backgroundColor: Colors.transparent,
                  enableActiveFill: true,
                  onChanged: (value) {
                    setState(() {
                      _currentOtp = value;
                      if (_errorMessage != null) {
                        _errorMessage = null;
                      }
                    });
                    Provider.of<AuthController>(context, listen: false)
                        .updateVerificationCode(value);
                  },
                  beforeTextPaste: (text) {
                    return text != null && text.length == 6 && int.tryParse(text) != null;
                  },
                ),
              ),

              // Error display
              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 14,
                      color: AllineColors.error,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AllineColors.error,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              // Timer / Resend Button
              Center(
                child: _seconds > 0
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 15,
                            color: AllineColors.coolGray,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'إعادة إرسال الرمز خلال ${_formatTimer(_seconds)}',
                            style: const TextStyle(
                              fontFamily: 'AllineTajawal',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AllineColors.coolGray,
                            ),
                          ),
                        ],
                      )
                    : InkWell(
                        onTap: _resendCode,
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          child: Text(
                            'إعادة إرسال الرمز',
                            style: TextStyle(
                              fontFamily: 'AllineTajawal',
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AllineColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 36),

              // Primary CTA: "التحقق والمتابعة"
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isComplete && !_isLoading ? _verifyOtp : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AllineColors.primary,
                    disabledBackgroundColor: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFE2E8F0),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                    elevation: isComplete ? 3 : 0,
                    shadowColor: AllineColors.primary.withValues(alpha: 0.35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'التحقق والمتابعة',
                          style: TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
