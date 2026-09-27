import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/auth/screens/login_screen.dart';
import 'package:sixvalley_vendor_app/features/auth/screens/merchant_onboarding_screen.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final colors = Theme.of(context).brightness == Brightness.dark
        ? const _AuthColors.dark()
        : const _AuthColors.light();

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                IconButton(
                  onPressed: () => Navigator.maybePop(context),
                  icon: Icon(Icons.arrow_back_rounded, color: colors.title),
                  tooltip: isArabic ? 'رجوع' : 'Back',
                ),
                const Spacer(),
                Image.asset(Images.logo, width: 42, height: 42),
                const SizedBox(width: 9),
                Text('Alline', style: TextStyle(color: colors.title, fontSize: 21, fontWeight: FontWeight.w800)),
                const SizedBox(width: 12),
              ]),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: colors.border),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 22, offset: const Offset(0, 10))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text(isArabic ? 'مرحبًا بعودتك' : 'Welcome back', textAlign: TextAlign.center, style: TextStyle(color: colors.title, fontSize: 27, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(isArabic ? 'سجّل الدخول لإدارة متجرك وطلباتك.' : 'Sign in to manage your shop and orders.', textAlign: TextAlign.center, style: TextStyle(color: colors.muted, fontSize: 14, height: 1.4)),
                  const SizedBox(height: 18),
                  const LoginScreen(),
                  const SizedBox(height: 2),
                  Divider(color: colors.border),
                  const SizedBox(height: 14),
                  Text(isArabic ? 'هل أنت بائع جديد؟' : 'New to selling on Alline?', textAlign: TextAlign.center, style: TextStyle(color: colors.muted, fontSize: 13)),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MerchantOnboardingScreen())),
                    icon: const Icon(Icons.storefront_rounded, size: 19),
                    label: Text(isArabic ? 'إنشاء حساب بائع' : 'Create seller account'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AllineColors.primary,
                      side: const BorderSide(color: AllineColors.primary),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 18),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.verified_user_outlined, size: 16, color: colors.muted),
                const SizedBox(width: 6),
                Text(isArabic ? 'بياناتك محمية مع Alline' : 'Your data is protected with Alline', style: TextStyle(color: colors.muted, fontSize: 12)),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthColors {
  final Color background;
  final Color surface;
  final Color border;
  final Color title;
  final Color muted;
  const _AuthColors({required this.background, required this.surface, required this.border, required this.title, required this.muted});
  const _AuthColors.light() : this(background: AllineColors.softBlue, surface: AllineColors.white, border: AllineColors.border, title: AllineColors.navyText, muted: AllineColors.coolGray);
  const _AuthColors.dark() : this(background: Color(0xFF101A2A), surface: Color(0xFF1B2A40), border: Color(0xFF30445F), title: Colors.white, muted: Color(0xFFB9C7D9));
}
