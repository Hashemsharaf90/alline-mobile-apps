import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/features/auth/screens/login_screen.dart';
import 'package:sixvalley_delivery_boy/utill/dimensions.dart';
import 'package:sixvalley_delivery_boy/utill/images.dart';
import 'package:sixvalley_delivery_boy/utill/styles.dart';
import 'driver_registration_screen.dart';

class DriverWelcomeScreen extends StatelessWidget {
  const DriverWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF015FC9);
    const Color bgLight = Color(0xFFF4F8FE);

    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),

              // Alline Branding & Logo
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withValues(alpha: 0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    Images.logo,
                    height: 80,
                    width: 80,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.delivery_dining,
                      size: 60,
                      color: primaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'join_alline_team'.tr,
                style: rubikBold.copyWith(
                  fontSize: 24,
                  color: const Color(0xFF1B2430),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'join_alline_subtitle'.tr,
                  style: rubikRegular.copyWith(
                    fontSize: 14,
                    color: const Color(0xFF5D6B82),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 36),

              // Highlight Feature Cards
              _buildFeatureItem(
                icon: Icons.payments_outlined,
                title: 'benefit_income_title'.tr,
                subtitle: 'benefit_income_desc'.tr,
                color: const Color(0xFF04BB7B),
              ),
              const SizedBox(height: 14),

              _buildFeatureItem(
                icon: Icons.near_me_outlined,
                title: 'benefit_nearby_title'.tr,
                subtitle: 'benefit_nearby_desc'.tr,
                color: primaryBlue,
              ),
              const SizedBox(height: 14),

              _buildFeatureItem(
                icon: Icons.support_agent_outlined,
                title: 'benefit_support_title'.tr,
                subtitle: 'benefit_support_desc'.tr,
                color: const Color(0xFFFF9800),
              ),
              const SizedBox(height: 40),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Get.to(() => const DriverRegistrationScreen());
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_add_alt_1, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'create_driver_account'.tr,
                        style: rubikBold.copyWith(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: primaryBlue, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Get.to(() => const LoginScreen());
                  },
                  child: Text(
                    'already_have_driver_account'.tr,
                    style: rubikBold.copyWith(
                      fontSize: 16,
                      color: primaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5EDF8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: rubikBold.copyWith(
                    fontSize: 15,
                    color: const Color(0xFF1B2430),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: rubikRegular.copyWith(
                    fontSize: 12,
                    color: const Color(0xFF757D8A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
