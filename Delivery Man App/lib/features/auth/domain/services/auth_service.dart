import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_delivery_boy/data/api/api_checker.dart';
import 'package:sixvalley_delivery_boy/features/auth/domain/models/response_model.dart';
import 'package:sixvalley_delivery_boy/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:sixvalley_delivery_boy/features/auth/domain/services/auth_service_interface.dart';

class AuthService implements AuthServiceInterface {
  AuthRepositoryInterface authRepoInterface;
  AuthService({required this.authRepoInterface});

  @override
  Future<bool> clearSharedData() {
    return authRepoInterface.clearSharedData();
  }

  @override
  Future<bool> clearUserCredentials() {
    return authRepoInterface.clearUserCredentials();
  }

  @override
  String getUserEmail() {
    return authRepoInterface.getUserEmail();
  }

  @override
  String getUserPassword() {
    return authRepoInterface.getUserPassword();
  }

  @override
  String getUserToken() {
    return authRepoInterface.getUserToken();
  }

  @override
  bool isLoggedIn() {
    return authRepoInterface.isLoggedIn();
  }

  @override
  Future<ResponseModel> login(String countryCode, String phone, String password) async {
    Response response = await authRepoInterface.login(countryCode, phone, password);

    if (response.statusCode == 200) {
      String? token = response.body['token'];
      String approvalStatus = response.body['approval_status'] ?? 'active';
      String? reviewNote = response.body['review_note'];
      if (token != null) {
        authRepoInterface.saveUserToken(token, approvalStatus);
        if (approvalStatus == 'active') {
          await authRepoInterface.updateToken();
        }
      }
      return ResponseModel(true, 'successful', approvalStatus: approvalStatus, reviewNote: reviewNote);
    } else {
      String? reviewNote;
      String? code;
      if (response.body is Map && response.body['errors'] != null && response.body['errors'] is List && response.body['errors'].isNotEmpty) {
        reviewNote = response.body['errors'][0]['review_note'];
        code = response.body['errors'][0]['code'];
      }
      return ResponseModel(false, response.statusText, approvalStatus: code, reviewNote: reviewNote);
    }
  }

  @override
  void saveUserCredentials(String countryCode, String number, String password) {
    return authRepoInterface.saveUserCredentials(countryCode, number, password);
  }

  @override
  void saveUserToken(String token, [String? approvalStatus]) {
    return authRepoInterface.saveUserToken(token, approvalStatus);
  }

  @override
  Future setLanguageCode(String currentLanguage) {
    return authRepoInterface.setLanguageCode(currentLanguage);
  }


  @override
  Future updateToken() {
    return authRepoInterface.updateToken();
  }

  @override
  Future<Response> forgotPassword(String? identity) async{
    Response _response = await authRepoInterface.forgotPassword(identity);
    if (_response.statusCode == 200) {
      showCustomSnackBarWidget(_response.body['message'], isError: false);
    } else {
      ApiChecker.checkApi(_response);
    }
    return _response;
  }

  @override
  Future<Response> verifyOtp(String otp, String? identity) async{
    Response _response = await authRepoInterface.verifyOtp(otp, identity);
    if (_response.statusCode == 200) {

      showCustomSnackBarWidget('otp_verified_successfully'.tr, isError: false);
    } else {
      ApiChecker.checkApi(_response);
    }
    return _response ;
  }

  @override
  String getUserCountryCode() {
    return authRepoInterface.getUserCountryCode();
  }


}