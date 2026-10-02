import 'package:sixvalley_delivery_boy/features/help_and_support/screens/help_and_support_screen.dart';
import 'package:sixvalley_delivery_boy/theme/alline/alline_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/utill/dimensions.dart';
import 'package:sixvalley_delivery_boy/utill/styles.dart';
import '../controllers/driver_onboarding_controller.dart';

class DriverPendingApprovalScreen extends StatelessWidget {
  const DriverPendingApprovalScreen({super.key});

  Future<void> _contactSupport() async {
    Get.to(() => const HelpAndSupportScreen());
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = AllineColors.primaryBlue;
    final Color bgLight = Get.theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Get.theme.colorScheme.surface,
        elevation: 0.5,
        title: Text(
          'application_status_title'.tr,
          style: rubikBold.copyWith(
              fontSize: 18, color: Get.theme.colorScheme.onSurface),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            tooltip: 'logout'.tr,
            onPressed: () =>
                Get.find<DriverOnboardingController>().logoutCandidate(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(child: Padding(
          padding: EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height:24),

              // Pending Animation / Icon
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hourglass_top_rounded,
                  size: 56,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'driver_pending_approval'.tr,
                style: rubikBold.copyWith(
                    fontSize: 22, color: Get.theme.colorScheme.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'driver_pending_approval_desc'.tr,
                  style: rubikRegular.copyWith(
                    fontSize: 14,
                    color: Get.theme.colorScheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),

              // Status Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Get.theme.colorScheme.outline),
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
                        color: Get.theme.colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.info_outline,
                          color: AllineColors.warning, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'status_under_review'.tr,
                            style: rubikBold.copyWith(
                                fontSize: 14,
                                color: Get.theme.colorScheme.onSurface),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'estimated_review_time'.tr,
                            style: rubikRegular.copyWith(
                                fontSize: 12,
                                color: Get.theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height:24),

              // Action Buttons
              GetBuilder<DriverOnboardingController>(
                builder: (controller) {
                  return SizedBox(
                    width: double.infinity,
                    
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: controller.isLoading
                          ? null
                          : () => controller.pollStatus(),
                      icon: controller.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh,
                              color: Colors.white, size: 20),
                      label: Text(
                        controller.isLoading
                            ? 'checking_status'.tr
                            : 'check_status_now'.tr,
                        style: rubikBold.copyWith(
                            fontSize: 16, color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Get.theme.colorScheme.surface,
                    side: BorderSide(color: Get.theme.colorScheme.outline),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _contactSupport,
                  icon: Icon(Icons.support_agent, color: primaryBlue, size: 20),
                  label: Text(
                    'contact_support'.tr,
                    style: rubikBold.copyWith(fontSize: 15, color: primaryBlue),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        )),
      ),
    );
  }
}
