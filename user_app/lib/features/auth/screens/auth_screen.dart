import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/widgets/sign_up_widget.dart';

class AuthScreen extends StatelessWidget {
  final bool fromLogout;
  final String? fromPage;
  final VoidCallback? onLoginSuccess;
  final String? referCode;
  const AuthScreen(
      {super.key,
      this.fromLogout = false,
      this.fromPage,
      this.onLoginSuccess,
      this.referCode});

  void _back(BuildContext context) {
    if (referCode != null) {
      RouterHelper.getDashboardRoute(
          action: RouteAction.pushNamedAndRemoveUntil);
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      RouterHelper.getLoginRoute(
          action: RouteAction.pushReplacement,
          isFromLogout: fromLogout,
          fromPage: fromPage,
          onLoginSuccess: onLoginSuccess);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back(context);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: const Color(0xFFF5F9FF)),
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F9FF),
          body: DecoratedBox(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                  Color(0xFFEAF2FF),
                  Color(0xFFF8FAFF),
                  Color(0xFFF5F9FF)
                ])),
            child: SafeArea(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: Center(
                    child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: IconButton.filledTonal(
                                onPressed: () => _back(context),
                                tooltip: MaterialLocalizations.of(context)
                                    .backButtonTooltip,
                                style: IconButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF10244A),
                                    side: const BorderSide(
                                        color: Color(0xFFDFE8F5))),
                                icon: const Icon(Icons.arrow_back_rounded,
                                    size: 22))),
                        Image.asset(
                            'assets/images/alline/login_logo_transparent.png',
                            width: 92,
                            height: 92,
                            semanticLabel: 'Alline',
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high),
                        const SizedBox(height: 12),
                        Text(getTranslated('sign_up', context) ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontFamily: 'AllineTajawal',
                                fontWeight: FontWeight.w700,
                                fontSize: 28,
                                color: Color(0xFF10244A))),
                        const SizedBox(height: 6),
                        Text(
                            isArabic
                                ? 'انضم إلى Alline وابدأ التسوّق بسهولة'
                                : 'Join Alline for an easier shopping experience',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontFamily: 'AllineTajawal',
                                fontSize: 14,
                                height: 1.5,
                                color: Color(0xFF6B7D99))),
                        const SizedBox(height: 24),
                        Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(26),
                                border:
                                    Border.all(color: const Color(0xFFE4ECF7)),
                                boxShadow: [
                                  BoxShadow(
                                      color: const Color(0xFF164989)
                                          .withValues(alpha: .06),
                                      blurRadius: 28,
                                      offset: const Offset(0, 10))
                                ]),
                            child: SignUpWidget(
                                fromLogout: fromLogout,
                                fromPage: fromPage,
                                onLoginSuccess: onLoginSuccess,
                                referCode: referCode)),
                      ]),
                )),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
