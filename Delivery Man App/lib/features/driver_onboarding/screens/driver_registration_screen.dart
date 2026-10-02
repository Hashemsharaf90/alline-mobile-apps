import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_delivery_boy/features/auth/screens/login_screen.dart';
import 'package:sixvalley_delivery_boy/utill/dimensions.dart';
import 'package:sixvalley_delivery_boy/utill/styles.dart';
import '../controllers/driver_onboarding_controller.dart';

class DriverRegistrationScreen extends StatefulWidget {
  const DriverRegistrationScreen({super.key});

  @override
  State<DriverRegistrationScreen> createState() => _DriverRegistrationScreenState();
}

class _DriverRegistrationScreenState extends State<DriverRegistrationScreen> {
  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String _countryCode = '+967';
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _termsAccepted = true;

  @override
  void dispose() {
    _fNameController.dispose();
    _lNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    String fName = _fNameController.text.trim();
    String lName = _lNameController.text.trim();
    String phone = _phoneController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (fName.isEmpty) {
      showCustomSnackBarWidget('enter_first_name'.tr);
      return;
    }
    if (lName.isEmpty) {
      showCustomSnackBarWidget('enter_last_name'.tr);
      return;
    }
    if (phone.isEmpty) {
      showCustomSnackBarWidget('enter_phone_number'.tr);
      return;
    }
    if (password.length < 8) {
      showCustomSnackBarWidget('password_min_8_chars'.tr);
      return;
    }
    if (password != confirmPassword) {
      showCustomSnackBarWidget('passwords_do_not_match'.tr);
      return;
    }
    if (!_termsAccepted) {
      showCustomSnackBarWidget('please_accept_terms'.tr);
      return;
    }

    Get.find<DriverOnboardingController>().startRegistration(
      fName: fName,
      lName: lName,
      phone: phone,
      countryCode: _countryCode,
      password: password,
      email: email.isNotEmpty ? email : null,
    );
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
          'create_driver_account'.tr,
          style: rubikBold.copyWith(fontSize: 18, color: const Color(0xFF1B2430)),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'driver_registration_desc'.tr,
                style: rubikRegular.copyWith(fontSize: 14, color: const Color(0xFF5D6B82)),
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
                      icon: Icons.person_outline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInputField(
                      controller: _lNameController,
                      label: 'last_name'.tr,
                      hint: 'Al-Hemyari',
                      icon: Icons.person_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Phone with country code picker
              Text(
                'phone_number'.tr,
                style: rubikMedium.copyWith(fontSize: 14, color: const Color(0xFF2C3E50)),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDDE4EE)),
                ),
                child: Row(
                  children: [
                    CountryCodePicker(
                      onChanged: (CountryCode code) {
                        setState(() {
                          _countryCode = code.dialCode ?? '+967';
                        });
                      },
                      initialSelection: 'YE',
                      favorite: const ['+967', '+966'],
                      showCountryOnly: false,
                      showOnlyCountryWhenClosed: false,
                      alignLeft: false,
                      textStyle: rubikBold.copyWith(fontSize: 14, color: const Color(0xFF1B2430)),
                    ),
                    Container(width: 1, height: 28, color: const Color(0xFFDDE4EE)),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: '770000000',
                          hintStyle: rubikRegular.copyWith(fontSize: 14, color: Colors.grey.shade400),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Email (Optional)
              _buildInputField(
                controller: _emailController,
                label: 'email_optional'.tr,
                hint: 'example@domain.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Password
              _buildInputField(
                controller: _passwordController,
                label: 'password'.tr,
                hint: '••••••••',
                icon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 16),

              // Confirm Password
              _buildInputField(
                controller: _confirmPasswordController,
                label: 'confirm_password'.tr,
                hint: '••••••••',
                icon: Icons.lock_outline,
                obscureText: _obscureConfirm,
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              const SizedBox(height: 14),

              // Terms & Conditions Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _termsAccepted,
                    activeColor: primaryBlue,
                    onChanged: (val) => setState(() => _termsAccepted = val ?? false),
                  ),
                  Expanded(
                    child: Text(
                      'agree_to_alline_terms'.tr,
                      style: rubikRegular.copyWith(fontSize: 13, color: const Color(0xFF5D6B82)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: controller.isLoading ? null : _submit,
                      child: controller.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : Text(
                              'continue_and_verify_phone'.tr,
                              style: rubikBold.copyWith(fontSize: 16, color: Colors.white),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Already have account
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'already_have_driver_account'.tr,
                      style: rubikRegular.copyWith(fontSize: 14, color: const Color(0xFF757D8A)),
                    ),
                    TextButton(
                      onPressed: () => Get.to(() => const LoginScreen()),
                      child: Text(
                        'login_now'.tr,
                        style: rubikBold.copyWith(fontSize: 14, color: primaryBlue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: rubikMedium.copyWith(fontSize: 14, color: const Color(0xFF2C3E50)),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDDE4EE)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF757D8A), size: 20),
              suffixIcon: suffixIcon,
              hintText: hint,
              hintStyle: rubikRegular.copyWith(fontSize: 14, color: Colors.grey.shade400),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
