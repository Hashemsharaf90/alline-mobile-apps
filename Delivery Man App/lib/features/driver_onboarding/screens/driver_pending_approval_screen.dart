import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sixvalley_delivery_boy/utill/dimensions.dart';
import 'package:sixvalley_delivery_boy/utill/styles.dart';
import '../controllers/driver_onboarding_controller.dart';

class DriverPendingApprovalScreen extends StatelessWidget {
  const DriverPendingApprovalScreen({super.key});

  Future<void> _contactSupport() async {
    const String whatsappUrl = 'https://wa.me/967770000000';
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF015FC9);
    const Color bgLight = Color(0xFFF4F8FE);

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'application_status_title'.tr,
          style: rubikBold.copyWith(fontSize: 18, color: const Color(0xFF1B2430)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            tooltip: 'logout'.tr,
            onPressed: () => Get.find<DriverOnboardingController>().logoutCandidate(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // Pending Animation / Icon
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  size: 56,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 28),

              Text(
                'driver_pending_approval'.tr,
                style: rubikBold.copyWith(fontSize: 22, color: const Color(0xFF1B2430)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'driver_pending_approval_desc'.tr,
                  style: rubikRegular.copyWith(
                    fontSize: 14,
                    color: const Color(0xFF5D6B82),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 36),

              // Status Card
              Container(
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
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.info_outline, color: Color(0xFF856404), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'status_under_review'.tr,
                            style: rubikBold.copyWith(fontSize: 14, color: const Color(0xFF1B2430)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'estimated_review_time'.tr,
                            style: rubikRegular.copyWith(fontSize: 12, color: const Color(0xFF757D8A)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Action Buttons
              GetBuilder<DriverOnboardingController>(
                builder: (controller) {
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: controller.isLoading ? null : () => controller.pollStatus(),
                      icon: controller.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh, color: Colors.white, size: 20),
                      label: Text(
                        controller.isLoading ? 'checking_status'.tr : 'check_status_now'.tr,
                        style: rubikBold.copyWith(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFDDE4EE)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _contactSupport,
                  icon: const Icon(Icons.support_agent, color: primaryBlue, size: 20),
                  label: Text(
                    'contact_support'.tr,
                    style: rubikBold.copyWith(fontSize: 15, color: primaryBlue),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
