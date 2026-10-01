import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

abstract class DriverOnboardingRepositoryInterface {
  Future<Response> register(Map<String, dynamic> data);
  Future<Response> verifyRegistrationOtp(String phone, String otp);
  Future<Response> resendRegistrationOtp(String phone);
  Future<Response> getProfile();
  Future<Response> updateProfile(Map<String, String> data, XFile? image);
  Future<Response> uploadDocument(String documentType, XFile file, String? note);
  Future<Response> deleteDocument(int id);
  Future<Response> saveVehicle(Map<String, String> data, XFile? regDoc);
  Future<Response> saveLocation(double lat, double lng, String? address);
  Future<Response> submitApplication();
  Future<Response> getStatus();
  Future<bool> saveCandidateToken(String token, String status);
  String? getCandidateToken();
  String getApprovalStatus();
  Future<bool> clearCandidateData();
}
