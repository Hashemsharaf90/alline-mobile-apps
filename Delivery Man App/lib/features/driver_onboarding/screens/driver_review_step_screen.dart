import 'package:sixvalley_delivery_boy/theme/alline/alline_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_delivery_boy/utill/dimensions.dart';
import 'package:sixvalley_delivery_boy/utill/styles.dart';
import '../controllers/driver_onboarding_controller.dart';
import '../widgets/alline_onboarding_header.dart';
import 'driver_profile_step_screen.dart';
import 'driver_documents_step_screen.dart';
import 'driver_vehicle_step_screen.dart';
import 'driver_location_step_screen.dart';

class DriverReviewStepScreen extends StatefulWidget {
  const DriverReviewStepScreen({super.key});

  @override
  State<DriverReviewStepScreen> createState() => _DriverReviewStepScreenState();
}

class _DriverReviewStepScreenState extends State<DriverReviewStepScreen> {
  bool _declarationAccepted = true;

  @override
  void initState() {
    super.initState();
    Get.find<DriverOnboardingController>().loadOnboardingProfile();
  }

  void _submit() {
    if (!_declarationAccepted) {
      showCustomSnackBarWidget('please_accept_declaration'.tr);
      return;
    }
    Get.find<DriverOnboardingController>().submitFinalApplication();
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Get.theme.colorScheme.onSurface, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'driver_onboarding_title'.tr,
          style: rubikBold.copyWith(
              fontSize: 18, color: Get.theme.colorScheme.onSurface),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            AllineOnboardingHeader(
              currentStep: 5,
              title: 'driver_review_step'.tr,
              subtitle: 'driver_review_step_desc'.tr,
            ),
            Expanded(
              child: GetBuilder<DriverOnboardingController>(
                builder: (controller) {
                  final candidate = controller.candidate;
                  final vehicle = controller.vehicle;
                  final docs = controller.documents;

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card 1: Personal Info
                        _buildSectionCard(
                          title: 'personal_info_section'.tr,
                          icon: Icons.person_outline,
                          onEdit: () =>
                              Get.to(() => const DriverProfileStepScreen()),
                          items: [
                            {
                              'label': 'full_name'.tr,
                              'value':
                                  '${candidate?.fName ?? ''} ${candidate?.lName ?? ''}'
                            },
                            {
                              'label': 'phone_number'.tr,
                              'value':
                                  candidate?.fullPhone ?? candidate?.phone ?? ''
                            },
                            {
                              'label': 'identity_number'.tr,
                              'value': candidate?.identityNumber ?? ''
                            },
                            {
                              'label': 'residential_address'.tr,
                              'value': candidate?.address ?? ''
                            },
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Card 2: Documents
                        _buildSectionCard(
                          title: 'documents_section'.tr,
                          icon: Icons.description_outlined,
                          onEdit: () =>
                              Get.to(() => const DriverDocumentsStepScreen()),
                          items: [
                            {
                              'label': 'national_id_card'.tr,
                              'value':
                                  docs.any((d) => d.documentType == 'identity')
                                      ? 'uploaded_verified'.tr
                                      : 'not_uploaded'.tr,
                            },
                            {
                              'label': 'drivers_license_doc'.tr,
                              'value': docs.any((d) =>
                                      d.documentType == 'drivers_license')
                                  ? 'uploaded_verified'.tr
                                  : 'not_uploaded'.tr,
                            },
                            {
                              'label': 'total_documents'.tr,
                              'value': '${docs.length} ${'files'.tr}',
                            },
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Card 3: Vehicle Info
                        _buildSectionCard(
                          title: 'vehicle_section'.tr,
                          icon: Icons.two_wheeler,
                          onEdit: () =>
                              Get.to(() => const DriverVehicleStepScreen()),
                          items: [
                            {
                              'label': 'vehicle_type'.tr,
                              'value': (vehicle?.vehicleType ?? 'motorcycle').tr
                            },
                            {
                              'label': 'vehicle_brand_model'.tr,
                              'value': vehicle?.brandOrModel ?? ''
                            },
                            {
                              'label': 'plate_number'.tr,
                              'value': vehicle?.plateNumber ?? ''
                            },
                            {
                              'label': 'vehicle_color'.tr,
                              'value': vehicle?.color ?? ''
                            },
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Card 4: Location Info
                        _buildSectionCard(
                          title: 'coverage_location_section'.tr,
                          icon: Icons.location_on_outlined,
                          onEdit: () =>
                              Get.to(() => const DriverLocationStepScreen()),
                          items: [
                            {
                              'label': 'coordinates'.tr,
                              'value': candidate?.latitude != null
                                  ? '${candidate!.latitude!.toStringAsFixed(4)}, ${candidate.longitude!.toStringAsFixed(4)}'
                                  : 'not_set'.tr,
                            },
                            {
                              'label': 'address'.tr,
                              'value': candidate?.address ?? ''
                            },
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Declaration Checkbox
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Get.theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Get.theme.colorScheme.outline),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _declarationAccepted,
                                activeColor: primaryBlue,
                                onChanged: (val) => setState(
                                    () => _declarationAccepted = val ?? false),
                              ),
                              Expanded(
                                child: Text(
                                  'driver_declaration_agreement'.tr,
                                  style: rubikRegular.copyWith(
                                      fontSize: 13,
                                      color: Get.theme.colorScheme.onSurface),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Final Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AllineColors.success, // Success Green
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: controller.isSubmitting ? null : _submit,
                            child: controller.isSubmitting
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.send_rounded,
                                          color: Colors.white, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'submit_application_now'.tr,
                                        style: rubikBold.copyWith(
                                            fontSize: 16, color: Colors.white),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required VoidCallback onEdit,
    required List<Map<String, String>> items,
  }) {
    final Color primaryBlue = AllineColors.primaryBlue;

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryBlue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: rubikBold.copyWith(
                      fontSize: 15, color: Get.theme.colorScheme.onSurface),
                ),
              ),
              InkWell(
                onTap: onEdit,
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 14, color: primaryBlue),
                    const SizedBox(width: 4),
                    Text(
                      'edit'.tr,
                      style: rubikMedium.copyWith(
                          fontSize: 13, color: primaryBlue),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(height: 18, color: Get.theme.colorScheme.outline),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        item['label'] ?? '',
                        style: rubikRegular.copyWith(
                            fontSize: 13,
                            color: Get.theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item['value'] ?? '',
                        style: rubikMedium.copyWith(
                            fontSize: 13,
                            color: Get.theme.colorScheme.onSurface),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
