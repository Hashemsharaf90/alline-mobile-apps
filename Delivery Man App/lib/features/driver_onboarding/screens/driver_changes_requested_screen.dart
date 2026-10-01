import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/utill/dimensions.dart';
import 'package:sixvalley_delivery_boy/utill/styles.dart';
import '../controllers/driver_onboarding_controller.dart';
import 'driver_profile_step_screen.dart';

class DriverChangesRequestedScreen extends StatelessWidget {
  final String? reviewNote;

  const DriverChangesRequestedScreen({super.key, this.reviewNote});

  @override
  Widget build(BuildContext context) {
    const Color warningAmber = Color(0xFFFF9800);
    const Color bgLight = Color(0xFFF4F8FE);
    const Color primaryBlue = Color(0xFF015FC9);

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'changes_requested_title'.tr,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: warningAmber.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  size: 50,
                  color: warningAmber,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'driver_changes_requested'.tr,
                style: rubikBold.copyWith(fontSize: 22, color: const Color(0xFF1B2430)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                'changes_requested_instructions'.tr,
                style: rubikRegular.copyWith(fontSize: 14, color: const Color(0xFF5D6B82)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Feedback Note Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFFE58F)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.feedback_outlined, color: warningAmber, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'admin_feedback_note'.tr,
                          style: rubikBold.copyWith(fontSize: 14, color: const Color(0xFF874D00)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      reviewNote ?? 'please_review_application_details'.tr,
                      style: rubikMedium.copyWith(fontSize: 14, color: const Color(0xFF613400), height: 1.5),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Button to edit
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Get.to(() => const DriverProfileStepScreen());
                  },
                  icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                  label: Text(
                    'edit_application_and_resubmit'.tr,
                    style: rubikBold.copyWith(fontSize: 16, color: Colors.white),
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
