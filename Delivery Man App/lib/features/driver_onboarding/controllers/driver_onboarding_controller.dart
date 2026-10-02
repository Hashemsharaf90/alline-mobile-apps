import 'dart:async';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_delivery_boy/features/auth/screens/login_screen.dart';
import 'package:sixvalley_delivery_boy/features/dashboard/screens/dashboard_screen.dart';
import '../domain/models/driver_onboarding_model.dart';
import '../domain/services/driver_onboarding_service_interface.dart';
import '../screens/driver_registration_otp_screen.dart';
import '../screens/driver_profile_step_screen.dart';
import '../screens/driver_pending_approval_screen.dart';
import '../screens/driver_changes_requested_screen.dart';
import '../screens/driver_rejected_screen.dart';
import '../screens/driver_suspended_screen.dart';

class DriverOnboardingController extends GetxController implements GetxService {
  final DriverOnboardingServiceInterface onboardingService;

  DriverOnboardingController({required this.onboardingService});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  int _currentStepIndex = 0;
  int get currentStepIndex => _currentStepIndex;

  String _currentPhone = '';
  String get currentPhone => _currentPhone;

  int _resendCooldown = 60;
  int get resendCooldown => _resendCooldown;
  Timer? _cooldownTimer;

  CandidateDriver? _candidate;
  CandidateDriver? get candidate => _candidate;

  DriverVehicle? _vehicle;
  DriverVehicle? get vehicle => _vehicle;

  List<OnboardingDocument> _documents = [];
  List<OnboardingDocument> get documents => _documents;

  OnboardingStepStatus? _stepStatus;
  OnboardingStepStatus? get stepStatus => _stepStatus;

  DriverOnboardingStatusResponse? _statusResponse;
  DriverOnboardingStatusResponse? get statusResponse => _statusResponse;

  void setStepIndex(int index) {
    _currentStepIndex = index;
    update();
  }

  void _startCooldownTimer() {
    _resendCooldown = 60;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        _resendCooldown--;
        update();
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void onClose() {
    _cooldownTimer?.cancel();
    super.onClose();
  }

  /// Step 1: Register initial candidate and trigger OTP
  Future<bool> startRegistration({
    required String fName,
    required String lName,
    required String phone,
    required String password,
    String? countryCode,
    String? email,
  }) async {
    _isLoading = true;
    update();

    Map<String, dynamic> data = {
      'f_name': fName,
      'l_name': lName,
      'phone': phone,
      'password': password,
      if (countryCode != null) 'country_code': countryCode,
      if (email != null && email.isNotEmpty) 'email': email,
    };

    Response response = await onboardingService.register(data);
    _isLoading = false;
    update();

    if (response.statusCode == 200) {
      _currentPhone = response.body['phone'] ?? phone;
      _startCooldownTimer();
      Get.to(() => DriverRegistrationOtpScreen(phone: _currentPhone));
      showCustomSnackBarWidget('registration_otp_sent'.tr, isError: false);
      return true;
    } else {
      String errorMsg = response.statusText ?? 'registration_failed'.tr;
      showCustomSnackBarWidget(errorMsg, isError: true);
      return false;
    }
  }

  /// Step 2: Verify Registration OTP
  Future<bool> verifyRegistrationOtp(String otp) async {
    _isLoading = true;
    update();

    Response response = await onboardingService.verifyRegistrationOtp(_currentPhone, otp);
    _isLoading = false;
    update();

    if (response.statusCode == 200 && response.body['token'] != null) {
      String token = response.body['token'];
      String status = response.body['approval_status'] ?? 'draft';

      await onboardingService.saveCandidateToken(token, status);
      await loadOnboardingProfile();

      routeByApprovalStatus(status);
      showCustomSnackBarWidget('phone_verified_success'.tr, isError: false);
      return true;
    } else {
      String errorMsg = response.statusText ?? 'invalid_otp_code'.tr;
      showCustomSnackBarWidget(errorMsg, isError: true);
      return false;
    }
  }

  /// Resend Registration OTP
  Future<bool> resendRegistrationOtp() async {
    if (_resendCooldown > 0) return false;

    _isLoading = true;
    update();

    Response response = await onboardingService.resendRegistrationOtp(_currentPhone);
    _isLoading = false;
    update();

    if (response.statusCode == 200) {
      _startCooldownTimer();
      showCustomSnackBarWidget('otp_resent_success'.tr, isError: false);
      return true;
    } else {
      String errorMsg = response.statusText ?? 'resend_failed'.tr;
      showCustomSnackBarWidget(errorMsg, isError: true);
      return false;
    }
  }

  /// Load current onboarding profile & step progress
  Future<void> loadOnboardingProfile() async {
    _isLoading = true;
    update();

    DriverOnboardingProfileResponse? profileResponse = await onboardingService.getProfile();
    _isLoading = false;

    if (profileResponse != null) {
      _candidate = profileResponse.deliveryMan;
      _vehicle = profileResponse.vehicle;
      _documents = profileResponse.documents ?? [];
      _stepStatus = profileResponse.steps;
    }
    update();
  }

  /// Step 3: Update personal details
  Future<bool> updatePersonalInfo({
    required String fName,
    required String lName,
    String? email,
    String? address,
    String? identityType,
    String? identityNumber,
    XFile? photo,
  }) async {
    _isSubmitting = true;
    update();

    Map<String, String> data = {
      'f_name': fName,
      'l_name': lName,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (identityType != null) 'identity_type': identityType,
      if (identityNumber != null) 'identity_number': identityNumber,
    };

    Response response = await onboardingService.updateProfile(data, photo);
    _isSubmitting = false;
    update();

    if (response.statusCode == 200) {
      await loadOnboardingProfile();
      showCustomSnackBarWidget('personal_info_saved'.tr, isError: false);
      return true;
    } else {
      showCustomSnackBarWidget(response.statusText ?? 'update_failed'.tr, isError: true);
      return false;
    }
  }

  /// Step 4: Upload document
  Future<bool> uploadDocument({
    required String documentType,
    required XFile file,
    String? note,
  }) async {
    _isUploading = true;
    update();

    Response response = await onboardingService.uploadDocument(documentType, file, note);
    _isUploading = false;
    update();

    if (response.statusCode == 200) {
      await loadOnboardingProfile();
      showCustomSnackBarWidget('document_uploaded_success'.tr, isError: false);
      return true;
    } else {
      showCustomSnackBarWidget(response.statusText ?? 'upload_failed'.tr, isError: true);
      return false;
    }
  }

  /// Delete document
  Future<bool> deleteDocument(int id) async {
    _isLoading = true;
    update();

    Response response = await onboardingService.deleteDocument(id);
    _isLoading = false;
    update();

    if (response.statusCode == 200) {
      _documents.removeWhere((doc) => doc.id == id);
      await loadOnboardingProfile();
      showCustomSnackBarWidget('document_deleted_success'.tr, isError: false);
      return true;
    } else {
      showCustomSnackBarWidget(response.statusText ?? 'delete_failed'.tr, isError: true);
      return false;
    }
  }

  /// Step 5: Save vehicle info
  Future<bool> saveVehicleInfo({
    required String vehicleType,
    required String brandOrModel,
    required String plateNumber,
    required String color,
    XFile? regDoc,
  }) async {
    _isSubmitting = true;
    update();

    Map<String, String> data = {
      'vehicle_type': vehicleType,
      'brand_or_model': brandOrModel,
      'plate_number': plateNumber,
      'color': color,
    };

    Response response = await onboardingService.saveVehicle(data, regDoc);
    _isSubmitting = false;
    update();

    if (response.statusCode == 200) {
      await loadOnboardingProfile();
      showCustomSnackBarWidget('vehicle_info_saved'.tr, isError: false);
      return true;
    } else {
      showCustomSnackBarWidget(response.statusText ?? 'vehicle_save_failed'.tr, isError: true);
      return false;
    }
  }

  /// Step 6: Save Location
  Future<bool> saveLocationCoords({
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    _isSubmitting = true;
    update();

    Response response = await onboardingService.saveLocation(latitude, longitude, address);
    _isSubmitting = false;
    update();

    if (response.statusCode == 200) {
      await loadOnboardingProfile();
      showCustomSnackBarWidget('location_saved_success'.tr, isError: false);
      return true;
    } else {
      showCustomSnackBarWidget(response.statusText ?? 'location_save_failed'.tr, isError: true);
      return false;
    }
  }

  /// Step 7: Final Submit
  Future<bool> submitFinalApplication() async {
    _isSubmitting = true;
    update();

    Response response = await onboardingService.submitApplication();
    _isSubmitting = false;
    update();

    if (response.statusCode == 200) {
      await onboardingService.saveCandidateToken(
        onboardingService.getCandidateToken() ?? '',
        'pending_approval',
      );
      Get.offAll(() => const DriverPendingApprovalScreen());
      showCustomSnackBarWidget('application_submitted_success'.tr, isError: false);
      return true;
    } else {
      showCustomSnackBarWidget(response.statusText ?? 'submit_failed'.tr, isError: true);
      return false;
    }
  }

  /// Status polling & dynamic branching
  Future<void> pollStatus() async {
    _isLoading = true;
    update();

    _statusResponse = await onboardingService.getStatus();
    _isLoading = false;
    update();

    if (_statusResponse != null) {
      String status = _statusResponse!.approvalStatus ?? 'draft';
      await onboardingService.saveCandidateToken(
        onboardingService.getCandidateToken() ?? '',
        status,
      );
      routeByApprovalStatus(status, note: _statusResponse!.reviewNote);
    }
  }

  /// Route to appropriate screen based on approval status
  void routeByApprovalStatus(String status, {String? note}) {
    switch (status) {
      case 'active':
        Get.offAll(() => const DashboardScreen(pageIndex: 0));
        break;
      case 'pending_approval':
        Get.offAll(() => const DriverPendingApprovalScreen());
        break;
      case 'changes_requested':
        Get.offAll(() => DriverChangesRequestedScreen(reviewNote: note ?? _candidate?.reviewNote));
        break;
      case 'rejected':
        Get.offAll(() => DriverRejectedScreen(reviewNote: note ?? _candidate?.reviewNote));
        break;
      case 'suspended':
        Get.offAll(() => DriverSuspendedScreen(reviewNote: note ?? _candidate?.reviewNote));
        break;
      case 'draft':
      default:
        Get.offAll(() => const DriverProfileStepScreen());
        break;
    }
  }

  /// Logout candidate & clear storage
  Future<void> logoutCandidate() async {
    await onboardingService.clearCandidateData();
    Get.offAll(() => const LoginScreen());
  }
}
