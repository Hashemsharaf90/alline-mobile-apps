import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';
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
    final colors = context.allineColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back(context);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
            .copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: colors.background),
        child: Scaffold(
          backgroundColor: colors.background,
          body: DecoratedBox(
            decoration: BoxDecoration(color: colors.background),
            child: SafeArea(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
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
                                    backgroundColor: colors.surface,
                                    foregroundColor: AllineColors.primary,
                                    side: BorderSide(color: colors.border),
                                    minimumSize: const Size(44, 44),
                                    maximumSize: const Size(44, 44),
                                    padding: EdgeInsets.zero),
                                icon: const Icon(Icons.arrow_back_rounded,
                                    size: 22))),
                        Image.asset(
                            'assets/images/alline/login_logo_transparent.png',
                            width: 82,
                            height: 82,
                            semanticLabel: 'Alline',
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high),
                        const SizedBox(height: 10),
                        Text(getTranslated('sign_up', context) ?? '',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'AllineTajawal',
                                fontWeight: FontWeight.w700,
                                fontSize: 25,
                                height: 1.25,
                                color: colors.textPrimary)),
                        const SizedBox(height: 6),
                        Text(
                            isArabic
                                ? 'انضم إلى Alline وابدأ التسوّق بسهولة'
                                : 'Join Alline for an easier shopping experience',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'AllineTajawal',
                                fontSize: 14,
                                height: 1.5,
                                color: colors.textSecondary)),
                        const SizedBox(height: 20),
                        Container(
                            padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                            decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: colors.border),
                                boxShadow: [
                                  BoxShadow(
                                      color: isDark
                                          ? Colors.black.withValues(alpha: 0.18)
                                          : AllineColors.primaryDark
                                              .withValues(alpha: .055),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8))
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
