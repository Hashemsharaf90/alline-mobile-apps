import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixvalley_delivery_boy/data/api/api_client.dart';
import 'package:sixvalley_delivery_boy/utill/app_constants.dart';
import 'driver_onboarding_repository_interface.dart';

class DriverOnboardingRepository implements DriverOnboardingRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  DriverOnboardingRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<Response> register(Map<String, dynamic> data) async {
    return await apiClient.postData(AppConstants.driverRegisterUri, data);
  }

  @override
  Future<Response> verifyRegistrationOtp(String phone, String otp) async {
    return await apiClient.postData(AppConstants.driverVerifyRegistrationOtpUri, {
      'phone': phone,
      'otp': otp,
    });
  }

  @override
  Future<Response> resendRegistrationOtp(String phone) async {
    return await apiClient.postData(AppConstants.driverResendRegistrationOtpUri, {
      'phone': phone,
    });
  }

  @override
  Future<Response> getProfile() async {
    return await apiClient.getData(AppConstants.driverOnboardingProfileUri);
  }

  @override
  Future<Response> updateProfile(Map<String, String> data, XFile? image) async {
    if (image != null) {
      return await apiClient.putMultipartData(
        AppConstants.driverOnboardingProfileUri,
        data,
        [MultipartBody('image', image)],
      );
    }
    return await apiClient.putData(AppConstants.driverOnboardingProfileUri, data);
  }

  @override
  Future<Response> uploadDocument(String documentType, XFile file, String? note) async {
    Map<String, String> fields = {
      'document_type': documentType,
    };
    if (note != null && note.isNotEmpty) {
      fields['review_note'] = note;
    }
    return await apiClient.postMultipartData(
      AppConstants.driverOnboardingDocumentsUri,
      fields,
      [MultipartBody('document', file)],
    );
  }

  @override
  Future<Response> deleteDocument(int id) async {
    return await apiClient.deleteData('${AppConstants.driverOnboardingDeleteDocumentUri}$id');
  }

  @override
  Future<Response> saveVehicle(Map<String, String> data, XFile? regDoc) async {
    if (regDoc != null) {
      return await apiClient.postMultipartData(
        AppConstants.driverOnboardingVehicleUri,
        data,
        [MultipartBody('registration_document', regDoc)],
      );
    }
    return await apiClient.postData(AppConstants.driverOnboardingVehicleUri, data);
  }

  @override
  Future<Response> saveLocation(double lat, double lng, String? address) async {
    return await apiClient.putData(AppConstants.driverOnboardingLocationUri, {
      'latitude': lat,
      'longitude': lng,
      if (address != null) 'address': address,
    });
  }

  @override
  Future<Response> submitApplication() async {
    return await apiClient.postData(AppConstants.driverOnboardingSubmitUri, {});
  }

  @override
  Future<Response> getStatus() async {
    return await apiClient.getData(AppConstants.driverOnboardingStatusUri);
  }

  @override
  Future<bool> saveCandidateToken(String token, String status) async {
    apiClient.token = token;
    apiClient.updateHeader(token, sharedPreferences.getString(AppConstants.languageCode));
    await sharedPreferences.setString(AppConstants.driverApprovalStatus, status);
    return await sharedPreferences.setString(AppConstants.token, token);
  }

  @override
  String? getCandidateToken() {
    return sharedPreferences.getString(AppConstants.token);
  }

  @override
  String getApprovalStatus() {
    return sharedPreferences.getString(AppConstants.driverApprovalStatus) ?? 'draft';
  }

  @override
  Future<bool> clearCandidateData() async {
    await sharedPreferences.remove(AppConstants.token);
    await sharedPreferences.remove(AppConstants.driverApprovalStatus);
    apiClient.token = null;
    apiClient.updateHeader(null, sharedPreferences.getString(AppConstants.languageCode));
    return true;
  }
}
