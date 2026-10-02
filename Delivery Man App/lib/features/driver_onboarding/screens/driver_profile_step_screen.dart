import 'package:sixvalley_delivery_boy/theme/alline/alline_colors.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_delivery_boy/utill/dimensions.dart';
import 'package:sixvalley_delivery_boy/utill/styles.dart';
import '../controllers/driver_onboarding_controller.dart';
import '../widgets/alline_onboarding_header.dart';
import 'driver_documents_step_screen.dart';

class DriverProfileStepScreen extends StatefulWidget {
  const DriverProfileStepScreen({super.key});

  @override
  State<DriverProfileStepScreen> createState() =>
      _DriverProfileStepScreenState();
}

class _DriverProfileStepScreenState extends State<DriverProfileStepScreen> {
  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _identityNumController = TextEditingController();

  String _identityType = 'nid';
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final candidate = Get.find<DriverOnboardingController>().candidate;
      if (candidate != null) {
        _fNameController.text = candidate.fName ?? '';
        _lNameController.text = candidate.lName ?? '';
        _emailController.text = candidate.email ?? '';
        _addressController.text = candidate.address ?? '';
        _identityNumController.text = candidate.identityNumber ?? '';
        if (candidate.identityType != null &&
            candidate.identityType!.isNotEmpty) {
          _identityType = candidate.identityType!;
        }
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _fNameController.dispose();
    _lNameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _identityNumController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  void _submit() async {
    String fName = _fNameController.text.trim();
    String lName = _lNameController.text.trim();
    String email = _emailController.text.trim();
    String address = _addressController.text.trim();
    String idNum = _identityNumController.text.trim();

    if (fName.isEmpty || lName.isEmpty) {
      showCustomSnackBarWidget('enter_full_name'.tr);
      return;
    }
    if (idNum.isEmpty) {
      showCustomSnackBarWidget('enter_identity_number'.tr);
      return;
    }
    if (address.isEmpty) {
      showCustomSnackBarWidget('enter_address'.tr);
      return;
    }

    bool success =
        await Get.find<DriverOnboardingController>().updatePersonalInfo(
      fName: fName,
      lName: lName,
      email: email.isNotEmpty ? email : null,
      address: address,
      identityType: _identityType,
      identityNumber: idNum,
      photo: _pickedImage,
    );

    if (success) {
      Get.to(() => const DriverDocumentsStepScreen());
    }
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
          'driver_onboarding_title'.tr,
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
        child: Column(
          children: [
            AllineOnboardingHeader(
              currentStep: 1,
              title: 'driver_profile_step'.tr,
              subtitle: 'driver_profile_step_desc'.tr,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar Picker
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(color: primaryBlue, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryBlue.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: _pickedImage != null
                                  ? Image.file(File(_pickedImage!.path),
                                      fit: BoxFit.cover)
                                  : Get.find<DriverOnboardingController>()
                                              .candidate
                                              ?.imageUrl !=
                                          null
                                      ? Image.network(
                                          Get.find<DriverOnboardingController>()
                                              .candidate!
                                              .imageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.person,
                                                  size: 50, color: Colors.grey),
                                        )
                                      : const Icon(Icons.person,
                                          size: 50, color: Colors.grey),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: primaryBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'driver_photo_optional'.tr,
                        style: rubikRegular.copyWith(
                            fontSize: 12, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // First & Last Name
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            controller: _fNameController,
                            label: 'first_name'.tr,
                            hint: 'Ali',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInputField(
                            controller: _lNameController,
                            label: 'last_name'.tr,
                            hint: 'Al-Hemyari',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Email (Optional)
                    _buildInputField(
                      controller: _emailController,
                      label: 'email_optional'.tr,
                      hint: 'driver@alline.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Identity Type Dropdown
                    Text(
                      'identity_type'.tr,
                      style: rubikMedium.copyWith(
                          fontSize: 14, color: Get.theme.colorScheme.onSurface),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Get.theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Get.theme.colorScheme.outline),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _identityType,
                          isExpanded: true,
                          items: [
                            DropdownMenuItem(
                                value: 'nid', child: Text('identity_nid'.tr)),
                            DropdownMenuItem(
                                value: 'passport',
                                child: Text('identity_passport'.tr)),
                            DropdownMenuItem(
                                value: 'driving_license',
                                child: Text('identity_driving_license'.tr)),
                            DropdownMenuItem(
                                value: 'residence_permit',
                                child: Text('identity_residence_permit'.tr)),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _identityType = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Identity Number
                    _buildInputField(
                      controller: _identityNumController,
                      label: 'identity_number'.tr,
                      hint: '01010000000',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Address
                    _buildInputField(
                      controller: _addressController,
                      label: 'residential_address'.tr,
                      hint: 'Sanaa, Hadda St',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),

                    // Submit & Continue Button
                    GetBuilder<DriverOnboardingController>(
                      builder: (controller) {
                        return SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
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
                                      Text(
                                        'save_and_continue_docs'.tr,
                                        style: rubikBold.copyWith(
                                            fontSize: 16, color: Colors.white),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward_ios,
                                          size: 16, color: Colors.white),
                                    ],
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: rubikMedium.copyWith(
              fontSize: 14, color: Get.theme.colorScheme.onSurface),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Get.theme.colorScheme.outline),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: rubikRegular.copyWith(
                  fontSize: 14, color: Colors.grey.shade400),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
