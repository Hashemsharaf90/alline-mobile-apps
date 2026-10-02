import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/auth/controllers/auth_controller.dart';
import 'package:sixvalley_vendor_app/features/auth/screens/create_account_screen.dart';
import 'package:sixvalley_vendor_app/features/auth/screens/login_screen.dart';
import 'package:sixvalley_vendor_app/features/auth/widgets/alline/alline_feature_tile.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<AuthController>(context, listen: false).isActiveRememberMe;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: ColorResources.getScaffoldBg(context),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),

              // Centered Alline Logo
              Center(
                child: Container(
                  width: 82,
                  height: 82,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? AllineColors.darkCard : AllineColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AllineColors.primary.withValues(alpha: 0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    Images.allineLogoClean,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Image.asset(
                      Images.logo,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Merchant Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AllineColors.darkBlue, AllineColors.primary],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AllineColors.primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'بوابة التاجر • SELLER',
                  style: TextStyle(
                    fontFamily: 'AllineTajawal',
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Hero Title
              Text(
                'ابدأ البيع مع Alline',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: ColorResources.getTextTitle(context),
                  height: 1.25,
                ),
              ),

              const SizedBox(height: 8),

              // Supporting Text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'وصّل منتجاتك إلى عملاء أكثر، وأدر متجرك وطلباتك بسهولة من مكان واحد.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: ColorResources.getTextSubTitle(context),
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Hero Illustration Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AllineColors.darkCard : AllineColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ColorResources.getBorder(context)),
                  boxShadow: [
                    BoxShadow(
                      color: AllineColors.primaryDark.withValues(alpha: 0.05),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    Images.welcomeHero,
                    height: 160,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox(
                      height: 120,
                      child: Icon(
                        Icons.store_rounded,
                        size: 64,
                        color: AllineColors.primary,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 3 Compact Benefits Rows
              AllineFeatureTile(
                icon: const Icon(
                  Icons.inventory_2_rounded,
                  color: AllineColors.primary,
                  size: 20,
                ),
                iconBgColor: AllineColors.primary.withValues(alpha: 0.1),
                title: 'إدارة المنتجات',
                subtitle: 'أضف منتجاتك وتابع مخزونك بسهولة.',
              ),
              const SizedBox(height: 10),

              AllineFeatureTile(
                icon: const Icon(
                  Icons.local_shipping_rounded,
                  color: AllineColors.orange,
                  size: 20,
                ),
                iconBgColor: AllineColors.orange.withValues(alpha: 0.12),
                title: 'إدارة الطلبات',
                subtitle: 'تابع الطلبات وتعامل معها من مكان واحد.',
              ),
              const SizedBox(height: 10),

              AllineFeatureTile(
                icon: const Icon(
                  Icons.trending_up_rounded,
                  color: AllineColors.primary,
                  size: 20,
                ),
                iconBgColor: AllineColors.primary.withValues(alpha: 0.1),
                title: 'تابع أداء متجرك',
                subtitle: 'راقب المبيعات والأداء بشكل واضح.',
              ),

              const SizedBox(height: 28),

              // Primary CTA: "إنشاء حساب مورد"
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateAccountScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AllineColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shadowColor: AllineColors.primary.withValues(alpha: 0.35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'إنشاء حساب مورد',
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Secondary action: "لديك حساب بالفعل؟ تسجيل الدخول"
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: RichText(
                    text: TextSpan(
                      text: 'لديك حساب بالفعل؟ ',
                      style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: ColorResources.getTextSubTitle(context),
                      ),
                      children: const [
                        TextSpan(
                          text: 'تسجيل الدخول',
                          style: TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AllineColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
