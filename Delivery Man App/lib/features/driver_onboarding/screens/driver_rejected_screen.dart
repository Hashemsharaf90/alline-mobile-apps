import 'package:sixvalley_delivery_boy/features/help_and_support/screens/help_and_support_screen.dart';
import 'package:sixvalley_delivery_boy/theme/alline/alline_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/utill/dimensions.dart';
import 'package:sixvalley_delivery_boy/utill/styles.dart';
import '../controllers/driver_onboarding_controller.dart';

class DriverRejectedScreen extends StatelessWidget {
  final String? reviewNote;

  const DriverRejectedScreen({super.key, this.reviewNote});

  Future<void> _contactSupport() async {
    Get.to(() => const HelpAndSupportScreen());
  }

  @override
  Widget build(BuildContext context) {
    const Color dangerRed = AllineColors.error;
    final Color bgLight = Get.theme.scaffoldBackgroundColor;
    final Color primaryBlue = AllineColors.primaryBlue;

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
      ),
      body: SafeArea(
        child: SingleChildScrollView(child: Padding(
          padding: EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),

              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: dangerRed.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel_outlined,
                  size: 54,
                  color: dangerRed,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'driver_rejected'.tr,
                style: rubikBold.copyWith(
                    fontSize: 22, color: Get.theme.colorScheme.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              Text(
                'driver_rejected_desc'.tr,
                style: rubikRegular.copyWith(
                    fontSize: 14,
                    color: Get.theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Rejection Reason Card
              if (reviewNote != null && reviewNote!.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Get.theme.colorScheme.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: dangerRed, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'rejection_reason_label'.tr,
                            style: rubikBold.copyWith(
                                fontSize: 14, color: Get.theme.colorScheme.onErrorContainer),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        reviewNote!,
                        style: rubikMedium.copyWith(
                            fontSize: 14,
                            color: Get.theme.colorScheme.onErrorContainer,
                            height: 1.5),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height:24),

              SizedBox(
                width: double.infinity,
                
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _contactSupport,
                  icon: const Icon(Icons.support_agent,
                      color: Colors.white, size: 20),
                  label: Text(
                    'contact_support'.tr,
                    style:
                        rubikBold.copyWith(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Get.theme.colorScheme.surface,
                    side: BorderSide(color: Get.theme.colorScheme.outline),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Get.find<DriverOnboardingController>().logoutCandidate();
                  },
                  child: Text(
                    'back_to_login'.tr,
                    style: rubikBold.copyWith(
                        fontSize: 15,
                        color: Get.theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        )),
      ),
    );
  }
}
