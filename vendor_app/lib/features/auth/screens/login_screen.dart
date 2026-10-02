import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/auth/controllers/auth_controller.dart';
import 'package:sixvalley_vendor_app/features/auth/screens/create_account_screen.dart';
import 'package:sixvalley_vendor_app/features/auth/screens/forget_password_screen.dart';
import 'package:sixvalley_vendor_app/features/auth/widgets/alline/alline_auth_header.dart';
import 'package:sixvalley_vendor_app/features/auth/widgets/alline/alline_text_field.dart';
import 'package:sixvalley_vendor_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  String? _emailError;
  String? _passwordError;
  String? _statusBannerMessage;
  Color? _statusBannerColor;

  @override
  void initState() {
    super.initState();
    final authController = Provider.of<AuthController>(context, listen: false);

    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    if (!authController.isUnAuthorize) {
      _emailController.text = authController.getUserEmail();
      _passwordController.text = authController.getUserPassword();
      authController.setUnAuthorize(true, update: false);
    }
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _statusBannerMessage = null;
    });

    final identity = _emailController.text.trim();
    final password = _passwordController.text.trim();
    bool isValid = true;

    if (identity.isEmpty) {
      setState(() {
        _emailError = 'يرجى إدخال رقم الهاتف أو البريد الإلكتروني';
      });
      isValid = false;
    }

    if (password.isEmpty) {
      setState(() {
        _passwordError = 'يرجى إدخال كلمة المرور';
      });
      isValid = false;
    } else if (password.length < 6) {
      setState(() {
        _passwordError = 'كلمة المرور يجب ألا تقل عن 6 أحرف أو أرقام';
      });
      isValid = false;
    }

    if (!isValid) return;

    final authProvider = Provider.of<AuthController>(context, listen: false);

    final apiResponse = await authProvider.login(
      context,
      emailAddress: identity,
      password: password,
    );

    if (!mounted) return;

    if (apiResponse.response?.statusCode == 200) {
      if (authProvider.isActiveRememberMe) {
        authProvider.saveUserNumberAndPassword(identity, password);
      } else {
        authProvider.clearUserEmailAndPassword();
      }

      Navigator.pushAndRemoveUntil(
        Get.context!,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );
    } else {
      final errorMsg = apiResponse.error?.toString() ?? 'فشل تسجيل الدخول';
      final lowerError = errorMsg.toLowerCase();

      if (lowerError.contains('pending') || lowerError.contains('under review') || lowerError.contains('قيد المراجعة')) {
        setState(() {
          _statusBannerMessage = 'حساب متجرك قيد المراجعة والاعتماد من قبل إدارة ألين، وسيتم إشعارك فور التفعيل.';
          _statusBannerColor = AllineColors.warning;
        });
      } else if (lowerError.contains('suspended') || lowerError.contains('موقوف')) {
        setState(() {
          _statusBannerMessage = 'تم تعليق هذا الحساب مؤقتاً. يرجى مراجعة إدارة الدعم الفني لألين.';
          _statusBannerColor = AllineColors.error;
        });
      } else if (lowerError.contains('rejected') || lowerError.contains('مرفوض')) {
        setState(() {
          _statusBannerMessage = 'تم رفض طلب التسجيل لهذا المتجر. تواصل مع الدعم للاستفسار.';
          _statusBannerColor = AllineColors.error;
        });
      } else if (lowerError.contains('network') || lowerError.contains('connection')) {
        setState(() {
          _statusBannerMessage = 'تعذر الاتصال بالخادم، يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.';
          _statusBannerColor = AllineColors.error;
        });
      } else {
        showCustomSnackBarWidget(
          errorMsg,
          context,
          sanckBarType: SnackBarType.error,
        );
      }
    }
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
          child: Consumer<AuthController>(
            builder: (context, authProvider, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AllineAuthHeader(
                    title: 'مرحبًا بعودتك 👋',
                    subtitle: 'سجّل الدخول لإدارة متجرك وطلباتك بسهولة.',
                    showBackButton: Navigator.canPop(context),
                    onBackPressed: () => Navigator.pop(context),
                  ),

                  const SizedBox(height: 24),

                  // Account Status Banner (Pending, Suspended, Rejected, Network)
                  if (_statusBannerMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: _statusBannerColor!.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _statusBannerColor!.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: _statusBannerColor,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _statusBannerMessage!,
                              style: TextStyle(
                                fontFamily: 'AllineTajawal',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _statusBannerColor,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Field 1: Phone or Email
                  AllineTextField(
                    label: 'رقم الهاتف أو البريد الإلكتروني',
                    hint: 'أدخل رقم الهاتف أو البريد الإلكتروني',
                    controller: _emailController,
                    focusNode: _emailFocus,
                    nextFocus: _passwordFocus,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.account_circle_outlined,
                    errorText: _emailError,
                    onChanged: (_) {
                      if (_emailError != null) setState(() => _emailError = null);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Field 2: Password
                  AllineTextField(
                    label: 'كلمة المرور',
                    hint: 'أدخل كلمة المرور',
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    isPassword: true,
                    prefixIcon: Icons.lock_outline_rounded,
                    textInputAction: TextInputAction.done,
                    errorText: _passwordError,
                    onChanged: (_) {
                      if (_passwordError != null) setState(() => _passwordError = null);
                    },
                    onSubmitted: (_) => _validateAndSubmit(),
                  ),

                  const SizedBox(height: 12),

                  // Options: Remember Me & Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () => authProvider.toggleRememberMe(),
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: authProvider.isActiveRememberMe
                                      ? AllineColors.primary
                                      : (isDark ? AllineColors.darkCard : AllineColors.white),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: authProvider.isActiveRememberMe
                                        ? AllineColors.primary
                                        : ColorResources.getBorder(context),
                                    width: 1.5,
                                  ),
                                ),
                                child: authProvider.isActiveRememberMe
                                    ? const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'تذكرني على هذا الجهاز',
                                style: TextStyle(
                                  fontFamily: 'AllineTajawal',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: ColorResources.getTextTitle(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            'نسيت كلمة المرور؟',
                            style: TextStyle(
                              fontFamily: 'AllineTajawal',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AllineColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Primary Button: Login
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _validateAndSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AllineColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shadowColor: AllineColors.primary.withValues(alpha: 0.35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'تسجيل الدخول',
                              style: TextStyle(
                                fontFamily: 'AllineTajawal',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Footer: Register as New Merchant
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateAccountScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: RichText(
                        text: TextSpan(
                          text: 'ليس لديك حساب؟ ',
                          style: TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: ColorResources.getTextSubTitle(context),
                          ),
                          children: const [
                            TextSpan(
                              text: 'إنشاء حساب مورد',
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

                  const SizedBox(height: 18),

                  // WhatsApp Direct Support Link
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AllineColors.darkCard : AllineColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ColorResources.getBorder(context)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'تحتاج مساعدة؟ تواصل مع الدعم عبر واتساب',
                          style: TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AllineColors.coolGray,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '+967775667733',
                          style: TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AllineColors.brightBlue : AllineColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
