import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/auth/controllers/auth_controller.dart';
import 'package:sixvalley_vendor_app/features/auth/screens/login_screen.dart';
import 'package:sixvalley_vendor_app/features/auth/screens/otp_verification_screen.dart';
import 'package:sixvalley_vendor_app/features/auth/widgets/alline/alline_auth_header.dart';
import 'package:sixvalley_vendor_app/features/auth/widgets/alline/alline_step_indicator.dart';
import 'package:sixvalley_vendor_app/features/auth/widgets/alline/alline_text_field.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _shopNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _shopNameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  String? _shopNameError;
  String? _phoneError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _termsError;

  bool _isTermsAccepted = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _shopNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _shopNameFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _validateAndProceed() {
    setState(() {
      _shopNameError = null;
      _phoneError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _termsError = null;
    });

    final shopName = _shopNameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    bool isValid = true;

    // 1. Shop Name
    if (shopName.isEmpty) {
      setState(() => _shopNameError = 'يرجى إدخال اسم المتجر');
      isValid = false;
    }

    // 2. Phone Number (Yemen format: 9 digits starting with 7)
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-+]'), '');
    if (phone.isEmpty) {
      setState(() => _phoneError = 'يرجى إدخال رقم الهاتف');
      isValid = false;
    } else if (cleanPhone.length < 9) {
      setState(() => _phoneError = 'رقم الهاتف يجب أن يتكون من 9 أرقام (مثال: 77XXXXXXX)');
      isValid = false;
    }

    // 3. Email (Optional)
    if (email.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        setState(() => _emailError = 'يرجى إدخال بريد إلكتروني صالح');
        isValid = false;
      }
    }

    // 4. Password
    if (password.isEmpty) {
      setState(() => _passwordError = 'يرجى إدخال كلمة المرور');
      isValid = false;
    } else if (password.length < 8) {
      setState(() => _passwordError = 'كلمة المرور يجب ألا تقل عن 8 خانات');
      isValid = false;
    }

    // 5. Confirm Password
    if (confirmPassword.isEmpty) {
      setState(() => _confirmPasswordError = 'يرجى تأكيد كلمة المرور');
      isValid = false;
    } else if (password != confirmPassword) {
      setState(() => _confirmPasswordError = 'كلمتا المرور غير متطابقتين');
      isValid = false;
    }

    // 6. Terms
    if (!_isTermsAccepted) {
      setState(() => _termsError = 'يجب الموافقة على شروط الاستخدام وسياسة الخصوصية للمتابعة');
      isValid = false;
    }

    if (!isValid) return;

    setState(() => _isSubmitting = true);

    // Format phone with Yemen code
    final formattedPhone = cleanPhone.startsWith('967') ? cleanPhone : '967$cleanPhone';

    // Store in controller for registration flow
    final authController = Provider.of<AuthController>(context, listen: false);
    authController.shopNameController.text = shopName;
    authController.phoneController.text = cleanPhone;
    authController.emailController.text = email;
    authController.passwordController.text = password;
    authController.confirmPasswordController.text = confirmPassword;

    setState(() => _isSubmitting = false);

    // Proceed to Screen 4 — OTP Verification
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerificationScreen(
          formattedPhone,
          shopName: shopName,
          password: password,
          email: email,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: ColorResources.getScaffoldBg(context),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AllineAuthHeader(
                title: 'أنشئ حساب مورد',
                subtitle: 'أنشئ حسابك وابدأ خطوات إعداد متجرك على Alline.',
                showBackButton: Navigator.canPop(context),
                onBackPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 18),

              // Lightweight Progress Indicator (● الحساب ○ بيانات المتجر ○ التحقق ○ المراجعة)
              const AllineStepIndicator(currentStep: 0),

              const SizedBox(height: 24),

              // 1. Shop Name
              AllineTextField(
                label: 'اسم المتجر',
                hint: 'مثال: متجر صنعاء للأجهزة',
                controller: _shopNameController,
                focusNode: _shopNameFocus,
                nextFocus: _phoneFocus,
                prefixIcon: Icons.storefront_outlined,
                errorText: _shopNameError,
                onChanged: (_) {
                  if (_shopNameError != null) setState(() => _shopNameError = null);
                },
              ),

              const SizedBox(height: 16),

              // 2. Phone Number
              AllineTextField(
                label: 'رقم الهاتف',
                hint: '77XXXXXXX',
                controller: _phoneController,
                focusNode: _phoneFocus,
                nextFocus: _emailFocus,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                prefixWidget: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  margin: const EdgeInsetsDirectional.only(end: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '🇾🇪 +967',
                        style: TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AllineColors.primaryDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 1,
                        height: 20,
                        color: ColorResources.getBorder(context),
                      ),
                    ],
                  ),
                ),
                errorText: _phoneError,
                onChanged: (_) {
                  if (_phoneError != null) setState(() => _phoneError = null);
                },
              ),

              const SizedBox(height: 16),

              // 3. Email (Optional)
              AllineTextField(
                label: 'البريد الإلكتروني',
                hint: 'name@example.com (اختياري)',
                controller: _emailController,
                focusNode: _emailFocus,
                nextFocus: _passwordFocus,
                keyboardType: TextInputType.emailAddress,
                isOptional: true,
                prefixIcon: Icons.email_outlined,
                errorText: _emailError,
                onChanged: (_) {
                  if (_emailError != null) setState(() => _emailError = null);
                },
              ),

              const SizedBox(height: 16),

              // 4. Password
              AllineTextField(
                label: 'كلمة المرور',
                hint: '8 خانات على الأقل',
                controller: _passwordController,
                focusNode: _passwordFocus,
                nextFocus: _confirmPasswordFocus,
                isPassword: true,
                prefixIcon: Icons.lock_outline_rounded,
                errorText: _passwordError,
                onChanged: (_) {
                  if (_passwordError != null) setState(() => _passwordError = null);
                },
              ),

              const SizedBox(height: 16),

              // 5. Confirm Password
              AllineTextField(
                label: 'تأكيد كلمة المرور',
                hint: 'أعد إدخال كلمة المرور',
                controller: _confirmPasswordController,
                focusNode: _confirmPasswordFocus,
                isPassword: true,
                prefixIcon: Icons.lock_reset_rounded,
                textInputAction: TextInputAction.done,
                errorText: _confirmPasswordError,
                onChanged: (_) {
                  if (_confirmPasswordError != null) setState(() => _confirmPasswordError = null);
                },
                onSubmitted: (_) => _validateAndProceed(),
              ),

              const SizedBox(height: 16),

              // Terms & Conditions Checkbox
              InkWell(
                onTap: () {
                  setState(() {
                    _isTermsAccepted = !_isTermsAccepted;
                    if (_isTermsAccepted && _termsError != null) {
                      _termsError = null;
                    }
                  });
                },
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: _isTermsAccepted
                              ? AllineColors.primary
                              : (isDark ? AllineColors.darkCard : AllineColors.white),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: _isTermsAccepted
                                ? AllineColors.primary
                                : (_termsError != null ? AllineColors.error : ColorResources.getBorder(context)),
                            width: 1.5,
                          ),
                        ),
                        child: _isTermsAccepted
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: 'أوافق على ',
                            style: TextStyle(
                              fontFamily: 'AllineTajawal',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: ColorResources.getTextTitle(context),
                              height: 1.4,
                            ),
                            children: const [
                              TextSpan(
                                text: 'شروط استخدام Alline',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AllineColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(text: ' و '),
                              TextSpan(
                                text: 'سياسة الخصوصية',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AllineColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_termsError != null) ...[
                const SizedBox(height: 6),
                Text(
                  _termsError!,
                  style: const TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AllineColors.error,
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // Primary CTA: "إرسال رمز التحقق"
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _validateAndProceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AllineColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shadowColor: AllineColors.primary.withValues(alpha: 0.35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'إرسال رمز التحقق',
                          style: TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Already have an account link
              Center(
                child: InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: RichText(
                      text: TextSpan(
                        text: 'لديك حساب بالفعل؟ ',
                        style: TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: ColorResources.getTextSubTitle(context),
                        ),
                        children: const [
                          TextSpan(
                            text: 'تسجيل الدخول',
                            style: TextStyle(
                              fontFamily: 'AllineTajawal',
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AllineColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
