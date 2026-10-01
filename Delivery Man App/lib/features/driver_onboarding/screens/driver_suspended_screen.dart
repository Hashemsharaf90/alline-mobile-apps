import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sixvalley_delivery_boy/utill/dimensions.dart';
import 'package:sixvalley_delivery_boy/utill/styles.dart';
import '../controllers/driver_onboarding_controller.dart';

class DriverSuspendedScreen extends StatelessWidget {
  final String? reviewNote;

  const DriverSuspendedScreen({super.key, this.reviewNote});

  Future<void> _contactSupport() async {
    const String whatsappUrl = 'https://wa.me/967770000000';
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color orangeColor = Color(0xFFFF9800);
    const Color bgLight = Color(0xFFF4F8FE);
    const Color primaryBlue = Color(0xFF015FC9);

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'account_status_title'.tr,
          style: rubikBold.copyWith(fontSize: 18, color: const Color(0xFF1B2430)),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),

              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: orangeColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.block_outlined,
                  size: 54,
                  color: orangeColor,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'driver_suspended'.tr,
                style: rubikBold.copyWith(fontSize: 22, color: const Color(0xFF1B2430)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              Text(
                'driver_suspended_desc'.tr,
                style: rubikRegular.copyWith(fontSize: 14, color: const Color(0xFF5D6B82)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Note Card
              if (reviewNote != null && reviewNote!.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7E6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFD591)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: orangeColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'suspension_reason_label'.tr,
                            style: rubikBold.copyWith(fontSize: 14, color: const Color(0xFFD46B08)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        reviewNote!,
                        style: rubikMedium.copyWith(fontSize: 14, color: const Color(0xFF873800), height: 1.5),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _contactSupport,
                  icon: const Icon(Icons.support_agent, color: Colors.white, size: 20),
                  label: Text(
                    'contact_support'.tr,
                    style: rubikBold.copyWith(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFDDE4EE)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Get.find<DriverOnboardingController>().logoutCandidate();
                  },
                  child: Text(
                    'logout'.tr,
                    style: rubikBold.copyWith(fontSize: 15, color: const Color(0xFF5D6B82)),
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
}
