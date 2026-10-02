import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/driver_onboarding_model.dart';
import '../repositories/driver_onboarding_repository_interface.dart';
import 'driver_onboarding_service_interface.dart';

class DriverOnboardingService implements DriverOnboardingServiceInterface {
  final DriverOnboardingRepositoryInterface onboardingRepo;

  DriverOnboardingService({required this.onboardingRepo});

  @override
  Future<Response> register(Map<String, dynamic> data) async {
    return await onboardingRepo.register(data);
  }

  @override
  Future<Response> verifyRegistrationOtp(String phone, String otp) async {
    return await onboardingRepo.verifyRegistrationOtp(phone, otp);
  }

  @override
  Future<Response> resendRegistrationOtp(String phone) async {
    return await onboardingRepo.resendRegistrationOtp(phone);
  }

  @override
  Future<DriverOnboardingProfileResponse?> getProfile() async {
    Response response = await onboardingRepo.getProfile();
    if (response.statusCode == 200 && response.body != null) {
      try {
        return DriverOnboardingProfileResponse.fromJson(response.body);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<Response> updateProfile(Map<String, String> data, XFile? image) async {
    return await onboardingRepo.updateProfile(data, image);
  }

  @override
  Future<Response> uploadDocument(String documentType, XFile file, String? note) async {
    return await onboardingRepo.uploadDocument(documentType, file, note);
  }

  @override
  Future<Response> deleteDocument(int id) async {
    return await onboardingRepo.deleteDocument(id);
  }

  @override
  Future<Response> saveVehicle(Map<String, String> data, XFile? regDoc) async {
    return await onboardingRepo.saveVehicle(data, regDoc);
  }

  @override
  Future<Response> saveLocation(double lat, double lng, String? address) async {
    return await onboardingRepo.saveLocation(lat, lng, address);
  }

  @override
  Future<Response> submitApplication() async {
    return await onboardingRepo.submitApplication();
  }

  @override
  Future<DriverOnboardingStatusResponse?> getStatus() async {
    Response response = await onboardingRepo.getStatus();
    if (response.statusCode == 200 && response.body != null) {
      try {
        return DriverOnboardingStatusResponse.fromJson(response.body);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<bool> saveCandidateToken(String token, String status) async {
    return await onboardingRepo.saveCandidateToken(token, status);
  }

  @override
  String? getCandidateToken() {
    return onboardingRepo.getCandidateToken();
  }

  @override
  String getApprovalStatus() {
    return onboardingRepo.getApprovalStatus();
  }

  @override
  Future<bool> clearCandidateData() async {
    return await onboardingRepo.clearCandidateData();
  }
}
