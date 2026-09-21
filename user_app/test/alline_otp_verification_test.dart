import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/enums/from_page.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/screens/otp_verification_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/config_model.dart';
import 'package:provider/provider.dart';

class MockSplashController extends ChangeNotifier implements SplashController {
  @override
  ConfigModel? get configModel => ConfigModel(
        otpResendTime: 45,
        customerVerification: CustomerVerification(status: 1, phone: 1, firebase: 0),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAuthController extends ChangeNotifier implements AuthController {
  String _verificationCode = '';

  @override
  String get verificationCode => _verificationCode;

  @override
  void updateVerificationCode(String code) {
    _verificationCode = code;
    notifyListeners();
  }

  @override
  bool get isPhoneNumberVerificationButtonLoading => false;

  @override
  bool get isLoading => false;

  @override
  bool get resendButtonLoading => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('OTP Verification Screen renders Alline visual elements accurately',
      (WidgetTester tester) async {
    final mockSplash = MockSplashController();
    final mockAuth = MockAuthController();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SplashController>.value(value: mockSplash),
          ChangeNotifierProvider<AuthController>.value(value: mockAuth),
        ],
        child: const MaterialApp(
          home: VerificationScreen(
            '+967777123456',
            FromPage.login,
          ),
        ),
      ),
    );

    await tester.pump();

    // Verify Main Heading
    expect(find.text('التحقق من رقم الهاتف'), findsOneWidget);

    // Verify Supporting Text
    expect(find.text('أدخل رمز التحقق المرسل إلى'), findsOneWidget);

    // Verify formatted phone number
    expect(find.text('+967 777 123 456'), findsOneWidget);

    // Verify Verify CTA Button
    expect(find.text('تحقق'), findsOneWidget);

    // Verify Resend elements
    expect(find.text('لم يصلك الرمز؟'), findsOneWidget);

    // Verify Change Phone Number Action
    expect(find.textContaining('تغيير الرقم'), findsOneWidget);

    // Verify Security Hint
    expect(
        find.text('رمز التحقق صالح لفترة محدودة ولا تشاركه مع أي شخص.'),
        findsOneWidget);
  });
}
