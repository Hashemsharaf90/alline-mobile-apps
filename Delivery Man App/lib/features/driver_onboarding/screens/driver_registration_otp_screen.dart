import 'package:sixvalley_delivery_boy/theme/alline/alline_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_delivery_boy/utill/dimensions.dart';
import 'package:sixvalley_delivery_boy/utill/styles.dart';
import '../controllers/driver_onboarding_controller.dart';

class DriverRegistrationOtpScreen extends StatefulWidget {
  final String phone;

  const DriverRegistrationOtpScreen({super.key, required this.phone});

  @override
  State<DriverRegistrationOtpScreen> createState() =>
      _DriverRegistrationOtpScreenState();
}

class _DriverRegistrationOtpScreenState
    extends State<DriverRegistrationOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  String _currentOtp = '';

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verify() {
    if (_currentOtp.length < 4) {
      showCustomSnackBarWidget('enter_complete_otp'.tr);
      return;
    }
    Get.find<DriverOnboardingController>().verifyRegistrationOtp(_currentOtp);
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
          'driver_phone_verification'.tr,
          style: rubikBold.copyWith(
              fontSize: 18, color: Get.theme.colorScheme.onSurface),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),

              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mark_email_read_outlined,
                  size: 46,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'driver_phone_verification'.tr,
                style: rubikBold.copyWith(
                    fontSize: 22, color: Get.theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 8),

              Text(
                '${'otp_sent_to'.tr} ${widget.phone}',
                style: rubikRegular.copyWith(
                    fontSize: 14,
                    color: Get.theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Pin Code Input
              Directionality(
                textDirection: TextDirection.ltr,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: PinCodeTextField(
                    length: 4,
                    appContext: context,
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(12),
                      fieldHeight: 56,
                      fieldWidth: 56,
                      activeFillColor: Colors.white,
                      inactiveFillColor: Colors.white,
                      selectedFillColor: Colors.white,
                      activeColor: primaryBlue,
                      inactiveColor: Get.theme.colorScheme.outline,
                      selectedColor: primaryBlue,
                    ),
                    enableActiveFill: true,
                    onChanged: (value) {
                      setState(() {
                        _currentOtp = value;
                      });
                    },
                    onCompleted: (value) {
                      _currentOtp = value;
                      _verify();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Resend Timer & Button
              GetBuilder<DriverOnboardingController>(
                builder: (controller) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'did_not_receive_code'.tr,
                        style: rubikRegular.copyWith(
                            fontSize: 14,
                            color: Get.theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: 4),
                      controller.resendCooldown > 0
                          ? Text(
                              '${controller.resendCooldown} ${'seconds'.tr}',
                              style: rubikBold.copyWith(
                                  fontSize: 14, color: primaryBlue),
                            )
                          : TextButton(
                              onPressed: () =>
                                  controller.resendRegistrationOtp(),
                              child: Text(
                                'resend_code'.tr,
                                style: rubikBold.copyWith(
                                    fontSize: 14, color: primaryBlue),
                              ),
                            ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 30),

              // Submit Button
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
                      onPressed: controller.isLoading ? null : _verify,
                      child: controller.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : Text(
                              'verify_and_continue'.tr,
                              style: rubikBold.copyWith(
                                  fontSize: 16, color: Colors.white),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
