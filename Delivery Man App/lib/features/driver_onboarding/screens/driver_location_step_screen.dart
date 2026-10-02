import 'package:sixvalley_delivery_boy/theme/alline/alline_colors.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_delivery_boy/utill/dimensions.dart';
import 'package:sixvalley_delivery_boy/utill/styles.dart';
import '../controllers/driver_onboarding_controller.dart';
import '../widgets/alline_onboarding_header.dart';
import 'driver_review_step_screen.dart';

class DriverLocationStepScreen extends StatefulWidget {
  const DriverLocationStepScreen({super.key});

  @override
  State<DriverLocationStepScreen> createState() =>
      _DriverLocationStepScreenState();
}

class _DriverLocationStepScreenState extends State<DriverLocationStepScreen> {
  final TextEditingController _addressController = TextEditingController();
  double? _latitude;
  double? _longitude;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final candidate = Get.find<DriverOnboardingController>().candidate;
      if (candidate != null) {
        if (candidate.latitude != null) _latitude = candidate.latitude;
        if (candidate.longitude != null) _longitude = candidate.longitude;
        _addressController.text = candidate.address ?? '';
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          showCustomSnackBarWidget('location_permission_denied'.tr);
          setState(() => _isLocating = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        showCustomSnackBarWidget('location_permission_permanently_denied'.tr);
        setState(() => _isLocating = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
      showCustomSnackBarWidget('location_detected_success'.tr, isError: false);
    } catch (e) {
      showCustomSnackBarWidget('location_permission_denied'.tr);
    } finally {
      setState(() => _isLocating = false);
    }
  }

  void _submit() async {
    if (_latitude == null || _longitude == null) {
      showCustomSnackBarWidget('please_set_location_coordinates'.tr);
      return;
    }

    String address = _addressController.text.trim();
    if (address.isEmpty) {
      showCustomSnackBarWidget('enter_address'.tr);
      return;
    }

    bool success =
        await Get.find<DriverOnboardingController>().saveLocationCoords(
      latitude: _latitude!,
      longitude: _longitude!,
      address: address,
    );

    if (success) {
      Get.to(() => const DriverReviewStepScreen());
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
              currentStep: 4,
              title: 'driver_location_step'.tr,
              subtitle: 'driver_location_step_desc'.tr,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location Detection Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Get.theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: Get.theme.colorScheme.outline),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: primaryBlue.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.my_location,
                              color: primaryBlue,
                              size: 38,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'preferred_coverage_location'.tr,
                            style: rubikBold.copyWith(
                                fontSize: 16,
                                color: Get.theme.colorScheme.onSurface),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'preferred_coverage_location_desc'.tr,
                            style: rubikRegular.copyWith(
                                fontSize: 13,
                                color: Get.theme.colorScheme.onSurfaceVariant),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),

                          // GPS Detect Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed:
                                  _isLocating ? null : _getCurrentLocation,
                              icon: _isLocating
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Icon(Icons.gps_fixed,
                                      color: Colors.white, size: 20),
                              label: Text(
                                _isLocating
                                    ? 'detecting_location'.tr
                                    : 'detect_my_location'.tr,
                                style: rubikBold.copyWith(
                                    fontSize: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Coordinates display card
                    if (_latitude != null && _longitude != null)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Get.theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Get.theme.colorScheme.outline),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: AllineColors.success, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'coordinates_captured'.tr,
                                    style: rubikBold.copyWith(
                                        fontSize: 13,
                                        color: Get.theme.colorScheme.onSurface),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Lat: ${_latitude!.toStringAsFixed(5)}, Long: ${_longitude!.toStringAsFixed(5)}',
                                    style: rubikRegular.copyWith(
                                        fontSize: 12,
                                        color: AllineColors.success),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Address Field
                    Text(
                      'coverage_address_label'.tr,
                      style: rubikMedium.copyWith(
                          fontSize: 14, color: Get.theme.colorScheme.onSurface),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: Get.theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Get.theme.colorScheme.outline),
                      ),
                      child: TextField(
                        controller: _addressController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'address_detail_hint'.tr,
                          hintStyle: rubikRegular.copyWith(
                              fontSize: 14, color: Colors.grey.shade400),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Continue Button
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
                                        'continue_to_review'.tr,
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
}
