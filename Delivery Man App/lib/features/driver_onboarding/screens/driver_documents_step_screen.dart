import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_delivery_boy/utill/dimensions.dart';
import 'package:sixvalley_delivery_boy/utill/styles.dart';
import '../controllers/driver_onboarding_controller.dart';
import '../domain/models/driver_onboarding_model.dart';
import '../widgets/alline_onboarding_header.dart';
import 'driver_vehicle_step_screen.dart';

class DriverDocumentsStepScreen extends StatelessWidget {
  const DriverDocumentsStepScreen({super.key});

  Future<void> _pickAndUpload(BuildContext context, String docType) async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null) {
      Get.find<DriverOnboardingController>().uploadDocument(
        documentType: docType,
        file: file,
      );
    }
  }

  void _onNext() {
    final controller = Get.find<DriverOnboardingController>();
    bool hasId = controller.documents.any((d) => d.documentType == 'identity');
    bool hasLicense = controller.documents.any((d) => d.documentType == 'drivers_license');

    if (!hasId) {
      showCustomSnackBarWidget('please_upload_identity_doc'.tr);
      return;
    }
    if (!hasLicense) {
      showCustomSnackBarWidget('please_upload_license_doc'.tr);
      return;
    }

    Get.to(() => const DriverVehicleStepScreen());
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1B2430), size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'driver_onboarding_title'.tr,
          style: rubikBold.copyWith(fontSize: 18, color: const Color(0xFF1B2430)),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            AllineOnboardingHeader(
              currentStep: 2,
              title: 'driver_documents_step'.tr,
              subtitle: 'driver_documents_step_desc'.tr,
            ),
            Expanded(
              child: GetBuilder<DriverOnboardingController>(
                builder: (controller) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Document 1: National ID / Residence permit (Required)
                        _buildDocCard(
                          context: context,
                          title: 'national_id_card'.tr,
                          subtitle: 'national_id_card_desc'.tr,
                          docType: 'identity',
                          isRequired: true,
                          documents: controller.documents,
                          controller: controller,
                        ),
                        const SizedBox(height: 18),

                        // Document 2: Driving License (Required)
                        _buildDocCard(
                          context: context,
                          title: 'drivers_license_doc'.tr,
                          subtitle: 'drivers_license_doc_desc'.tr,
                          docType: 'drivers_license',
                          isRequired: true,
                          documents: controller.documents,
                          controller: controller,
                        ),
                        const SizedBox(height: 18),

                        // Document 3: Commercial Guarantee (Optional)
                        _buildDocCard(
                          context: context,
                          title: 'commercial_guarantee_doc'.tr,
                          subtitle: 'commercial_guarantee_doc_desc'.tr,
                          docType: 'commercial_guarantee',
                          isRequired: false,
                          documents: controller.documents,
                          controller: controller,
                        ),
                        const SizedBox(height: 30),

                        // Next Step Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: controller.isUploading ? null : _onNext,
                            child: controller.isUploading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'continue_to_vehicle'.tr,
                                        style: rubikBold.copyWith(fontSize: 16, color: Colors.white),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
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

  Widget _buildDocCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String docType,
    required bool isRequired,
    required List<OnboardingDocument> documents,
    required DriverOnboardingController controller,
  }) {
    const Color primaryBlue = Color(0xFF015FC9);
    final uploadedDocs = documents.where((d) => d.documentType == docType).toList();
    final bool isUploaded = uploadedDocs.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUploaded ? const Color(0xFF04BB7B) : const Color(0xFFE5EDF8),
          width: isUploaded ? 1.5 : 1,
        ),
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
              Icon(
                isUploaded ? Icons.check_circle : Icons.upload_file_outlined,
                color: isUploaded ? const Color(0xFF04BB7B) : primaryBlue,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: rubikBold.copyWith(fontSize: 15, color: const Color(0xFF1B2430)),
                ),
              ),
              if (isRequired)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'required'.tr,
                    style: rubikMedium.copyWith(fontSize: 11, color: const Color(0xFF856404)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: rubikRegular.copyWith(fontSize: 12, color: const Color(0xFF757D8A)),
          ),
          const SizedBox(height: 12),

          if (isUploaded)
            ...uploadedDocs.map((doc) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FBF9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD4EDDA)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.description_outlined, color: Color(0xFF04BB7B), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          doc.filePath ?? 'file_uploaded'.tr,
                          style: rubikMedium.copyWith(fontSize: 13, color: const Color(0xFF155724)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: doc.id != null ? () => controller.deleteDocument(doc.id!) : null,
                      ),
                    ],
                  ),
                ))
          else
            InkWell(
              onTap: () => _pickAndUpload(context, docType),
              child: DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  color: primaryBlue.withValues(alpha: 0.5),
                  strokeWidth: 1.5,
                  dashPattern: const [6, 4],
                  radius: const Radius.circular(10),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  color: const Color(0xFFF9FBFF),
                  child: Column(
                    children: [
                      Icon(Icons.cloud_upload_outlined, color: primaryBlue, size: 36),
                      const SizedBox(height: 6),
                      Text(
                        'tap_to_upload'.tr,
                        style: rubikBold.copyWith(fontSize: 13, color: primaryBlue),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'supported_formats_desc'.tr,
                        style: rubikRegular.copyWith(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
