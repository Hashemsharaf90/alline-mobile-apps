import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/enums/from_page.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/screens/auth_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/config_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/business_pages_model.dart';
import 'package:flutter_sixvalley_ecommerce/localization/app_localization.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';

class _Auth extends ChangeNotifier implements AuthController {
  bool accepted = false, loading = false;
  String? submittedPhone, submittedName, submittedEmail, submittedReferral;
  FromPage? submittedFrom;
  @override
  String countryDialCode = '+967';
  @override
  bool get isAcceptTerms => accepted;
  @override
  bool get isPhoneNumberVerificationButtonLoading => loading;
  @override
  void toggleTermsCheck() {
    accepted = !accepted;
    notifyListeners();
  }

  @override
  void setCountryCode(String code, {bool notify = true}) {
    countryDialCode = code;
    if (notify) notifyListeners();
  }

  @override
  void prepareOtpRegistration(
      {required String name, String? email, String? referralCode}) {
    submittedName = name;
    submittedEmail = email;
    submittedReferral = referralCode;
  }

  @override
  Future<ResponseModel> checkPhoneForOtp(String phone, FromPage fromPage,
      {String? toNavigateScreen, VoidCallback? onLoginSuccess}) async {
    submittedPhone = phone;
    submittedFrom = fromPage;
    return ResponseModel('test only', true);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Splash extends ChangeNotifier implements SplashController {
  @override
  final ConfigModel configModel = ConfigModel(
      countryCode: 'YE',
      refEarningStatus: '1',
      customerLogin: CustomerLogin(
          loginOption: LoginOption(socialMediaLogin: 1),
          socialMediaLoginOptions: SocialMediaLoginOptions(google: 1)));
  @override
  List<BusinessPageModel> get defaultBusinessPages =>
      [BusinessPageModel(slug: 'terms-and-conditions')];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
      'Registration preserves validation, terms gating and OTP data; supports narrow layouts',
      (tester) async {
    final auth = _Auth();
    final splash = _Splash();
    final captureKey = GlobalKey();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 1020);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      await (FontLoader('AllineTajawal')
            ..addFont(
                rootBundle.load('assets/fonts/tajawal/Tajawal-Regular.ttf'))
            ..addFont(rootBundle.load('assets/fonts/tajawal/Tajawal-Bold.ttf')))
          .load();
      await (FontLoader('MaterialIcons')
            ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
          .load();
    });
    Widget app(String locale, double scale) => MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthController>.value(value: auth),
              ChangeNotifierProvider<SplashController>.value(value: splash),
            ],
            child: MaterialApp(
                navigatorKey: navigatorKey,
                locale: Locale(locale),
                supportedLocales: const [Locale('ar'), Locale('en')],
                localizationsDelegates: const [
                  AppLocalization.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate
                ],
                builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: TextScaler.linear(scale)),
                    child: child!),
                home: RepaintBoundary(
                    key: captureKey,
                    child: const AuthScreen(referCode: 'WELCOME'))));
    await tester.pumpWidget(app('ar', 1));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final context = tester.element(find.byType(AuthScreen));
      await precacheImage(
          const AssetImage('assets/images/alline/login_logo_transparent.png'),
          context);
    });
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final submit = find.byKey(const ValueKey('signup-submit'));
    expect(tester.widget<ElevatedButton>(submit).onPressed, isNull);
    final capture = Platform.environment['SIGNUP_CAPTURE'];
    if (capture != null) {
      await tester.runAsync(() async {
        final image = await (captureKey.currentContext!.findRenderObject()
                as RenderRepaintBoundary)
            .toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(capture).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(auth.submittedPhone, isNull);
    expect(tester.state<FormState>(find.byType(Form)).validate(), isFalse);
    await tester.enterText(
        find.byKey(const ValueKey('signup-name')), 'Test Customer');
    await tester.enterText(
        find.byKey(const ValueKey('signup-phone')), '777123456');
    expect(tester.state<FormState>(find.byType(Form)).validate(), isTrue);
    await tester.enterText(
        find.byKey(const ValueKey('signup-email')), 'bad-email');
    expect(tester.state<FormState>(find.byType(Form)).validate(), isFalse);
    await tester.enterText(find.byKey(const ValueKey('signup-email')), '');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(auth.submittedPhone, '+967777123456');
    expect(auth.submittedName, 'Test Customer');
    expect(auth.submittedEmail, '');
    expect(auth.submittedReferral, 'WELCOME');
    expect(auth.submittedFrom, FromPage.otpRegistration);
    auth.loading = true;
    auth.notifyListeners();
    await tester.pump();
    expect(tester.widget<ElevatedButton>(submit).onPressed, isNull);
    auth.loading = false;
    auth.notifyListeners();
    for (final locale in ['ar', 'en']) {
      tester.view.physicalSize = const Size(320, 568);
      await tester.pumpWidget(app(locale, 1.4));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
      await tester.pumpAndSettle();
      await tester.ensureVisible(submit);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
