import 'package:sixvalley_delivery_boy/theme/alline/alline_colors.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_delivery_boy/utill/dimensions.dart';
import 'package:sixvalley_delivery_boy/utill/styles.dart';
import '../controllers/driver_onboarding_controller.dart';
import '../widgets/alline_onboarding_header.dart';
import 'driver_location_step_screen.dart';

class DriverVehicleStepScreen extends StatefulWidget {
  const DriverVehicleStepScreen({super.key});

  @override
  State<DriverVehicleStepScreen> createState() =>
      _DriverVehicleStepScreenState();
}

class _DriverVehicleStepScreenState extends State<DriverVehicleStepScreen> {
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();

  String _vehicleType = 'motorcycle';
  XFile? _regDocFile;

  final List<Map<String, dynamic>> _vehicleTypes = [
    {
      'type': 'motorcycle',
      'title': 'vehicle_motorcycle',
      'icon': Icons.two_wheeler
    },
    {'type': 'car', 'title': 'vehicle_car', 'icon': Icons.directions_car},
    {'type': 'van', 'title': 'vehicle_van', 'icon': Icons.local_shipping},
    {'type': 'bicycle', 'title': 'vehicle_bicycle', 'icon': Icons.pedal_bike},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vehicle = Get.find<DriverOnboardingController>().vehicle;
      if (vehicle != null) {
        if (vehicle.vehicleType != null) _vehicleType = vehicle.vehicleType!;
        _brandController.text = vehicle.brandOrModel ?? '';
        _plateController.text = vehicle.plateNumber ?? '';
        _colorController.text = vehicle.color ?? '';
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _brandController.dispose();
    _plateController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _pickRegDoc() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null) {
      setState(() {
        _regDocFile = file;
      });
    }
  }

  void _submit() async {
    String brand = _brandController.text.trim();
    String plate = _plateController.text.trim();
    String color = _colorController.text.trim();

    if (brand.isEmpty) {
      showCustomSnackBarWidget('enter_vehicle_brand'.tr);
      return;
    }
    if (plate.isEmpty) {
      showCustomSnackBarWidget('enter_plate_number'.tr);
      return;
    }
    if (color.isEmpty) {
      showCustomSnackBarWidget('enter_vehicle_color'.tr);
      return;
    }

    bool success = await Get.find<DriverOnboardingController>().saveVehicleInfo(
      vehicleType: _vehicleType,
      brandOrModel: brand,
      plateNumber: plate,
      color: color,
      regDoc: _regDocFile,
    );

    if (success) {
      Get.to(() => const DriverLocationStepScreen());
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
              currentStep: 3,
              title: 'driver_vehicle_step'.tr,
              subtitle: 'driver_vehicle_step_desc'.tr,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'select_vehicle_type'.tr,
                      style: rubikMedium.copyWith(
                          fontSize: 14, color: Get.theme.colorScheme.onSurface),
                    ),
                    const SizedBox(height: 10),

                    // Vehicle Type Selector Grid
                    Row(
                      children: _vehicleTypes.map((v) {
                        bool isSelected = _vehicleType == v['type'];
                        return Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _vehicleType = v['type']),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Get.theme.colorScheme.primaryContainer
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? primaryBlue
                                      : Get.theme.colorScheme.outline,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    v['icon'] as IconData,
                                    color:
                                        isSelected ? primaryBlue : Colors.grey,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    (v['title'] as String).tr,
                                    style: rubikMedium.copyWith(
                                      fontSize: 11,
                                      color: isSelected
                                          ? primaryBlue
                                          : Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Brand / Model
                    _buildInputField(
                      controller: _brandController,
                      label: 'vehicle_brand_model'.tr,
                      hint: 'Honda CG 125',
                    ),
                    const SizedBox(height: 16),

                    // Plate Number
                    _buildInputField(
                      controller: _plateController,
                      label: 'plate_number'.tr,
                      hint: '1234-A',
                    ),
                    const SizedBox(height: 16),

                    // Color
                    _buildInputField(
                      controller: _colorController,
                      label: 'vehicle_color'.tr,
                      hint: 'Red / White',
                    ),
                    const SizedBox(height: 20),

                    // Registration Card (Optional Upload)
                    Text(
                      'vehicle_registration_card_optional'.tr,
                      style: rubikMedium.copyWith(
                          fontSize: 14, color: Get.theme.colorScheme.onSurface),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _pickRegDoc,
                      child: DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          color: primaryBlue.withValues(alpha: 0.5),
                          strokeWidth: 1.5,
                          dashPattern: const [6, 4],
                          radius: const Radius.circular(10),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          color: Get.theme.colorScheme.surface,
                          child: Column(
                            children: [
                              Icon(
                                _regDocFile != null
                                    ? Icons.check_circle
                                    : Icons.document_scanner_outlined,
                                color: _regDocFile != null
                                    ? AllineColors.success
                                    : primaryBlue,
                                size: 32,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _regDocFile != null
                                    ? 'file_selected'.tr
                                    : 'upload_vehicle_card'.tr,
                                style: rubikBold.copyWith(
                                  fontSize: 13,
                                  color: _regDocFile != null
                                      ? AllineColors.success
                                      : primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Next Button
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
                                        'continue_to_location'.tr,
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
