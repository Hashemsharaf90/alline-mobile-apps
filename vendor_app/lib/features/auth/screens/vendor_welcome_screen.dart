import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/auth/screens/auth_screen.dart';
import 'package:sixvalley_vendor_app/features/auth/screens/merchant_onboarding_screen.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';

class VendorWelcomeScreen extends StatelessWidget {
  const VendorWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final size = MediaQuery.sizeOf(context);
    final colors = Theme.of(context).brightness == Brightness.dark
        ? const _WelcomeColors.dark()
        : const _WelcomeColors.light();

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.border),
                    ),
                    child: Image.asset(Images.logo),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Alline',
                    style: TextStyle(
                      color: colors.title,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.5,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    isArabic ? 'للبائعين' : 'For sellers',
                    style: TextStyle(
                      color: colors.muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                height: size.height < 700 ? 260 : 315,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [AllineColors.secondary, AllineColors.primary],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AllineColors.primary.withValues(alpha: .22),
                      blurRadius: 26,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -55,
                      left: -40,
                      child: _GlowCircle(color: Colors.white.withValues(alpha: .08), size: 180),
                    ),
                    Positioned(
                      bottom: -75,
                      right: -30,
                      child: _GlowCircle(color: AllineColors.orange.withValues(alpha: .20), size: 210),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Image.asset(
                          Images.onBoardingOne,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text(
                isArabic ? 'كبّر تجارتك مع Alline' : 'Grow your business with Alline',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.title,
                  fontSize: 28,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isArabic
                    ? 'أدر متجرك، استقبل الطلبات، وتابع أرباحك من مكان واحد.'
                    : 'Manage your shop, receive orders, and track your earnings in one place.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.muted, fontSize: 15, height: 1.55),
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  _FeaturePill(icon: Icons.receipt_long_rounded, label: isArabic ? 'إدارة الطلبات' : 'Orders', colors: colors),
                  _FeaturePill(icon: Icons.inventory_2_rounded, label: isArabic ? 'منتجاتك' : 'Products', colors: colors),
                  _FeaturePill(icon: Icons.insights_rounded, label: isArabic ? 'أرباحك' : 'Earnings', colors: colors),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AllineColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                  ),
                  child: Text(isArabic ? 'تسجيل الدخول' : 'Sign in', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 54,
                child: OutlinedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MerchantOnboardingScreen())),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AllineColors.primary,
                    side: const BorderSide(color: AllineColors.primary, width: 1.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                  ),
                  child: Text(isArabic ? 'إنشاء حساب بائع' : 'Create seller account', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                isArabic ? 'ابدأ بخطوة بسيطة، واترك الباقي علينا.' : 'Start with one simple step — we will help with the rest.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.muted, fontSize: 12.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final _WelcomeColors colors;
  const _FeaturePill({required this.icon, required this.label, required this.colors});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: AllineColors.orange, size: 17),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: colors.title, fontSize: 12.5, fontWeight: FontWeight.w700)),
        ]),
      );
}

class _GlowCircle extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowCircle({required this.color, required this.size});
  @override
  Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color));
}

class _WelcomeColors {
  final Color background;
  final Color surface;
  final Color border;
  final Color title;
  final Color muted;
  const _WelcomeColors({required this.background, required this.surface, required this.border, required this.title, required this.muted});
  const _WelcomeColors.light() : this(background: AllineColors.softBlue, surface: AllineColors.white, border: AllineColors.border, title: AllineColors.navyText, muted: AllineColors.coolGray);
  const _WelcomeColors.dark() : this(background: Color(0xFF101A2A), surface: Color(0xFF1B2A40), border: Color(0xFF30445F), title: Colors.white, muted: Color(0xFFB9C7D9));
}
