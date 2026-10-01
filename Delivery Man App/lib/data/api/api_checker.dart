
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_delivery_boy/features/auth/screens/login_screen.dart';

class ApiChecker {
  static bool _isSessionExpiredHandling = false;

  static void checkApi(Response response) {
    if (response.statusCode == 401) {
      if (!_isSessionExpiredHandling) {
        _isSessionExpiredHandling = true;
        try {
          Get.find<SplashController>().removeSharedData();
        } catch (_) {}
        Get.offAll(() => const LoginScreen());
        showCustomSnackBarWidget('session_expired_please_login_again'.tr);
        Future.delayed(const Duration(seconds: 3), () {
          _isSessionExpiredHandling = false;
        });
      }
    } else if (response.statusCode == 403) {
      String message = response.statusText ?? 'forbidden'.tr;
      if (response.body is Map && response.body['message'] != null) {
        message = response.body['message'].toString();
      } else if (response.body is Map && response.body['errors'] != null && response.body['errors'] is List && (response.body['errors'] as List).isNotEmpty) {
        message = response.body['errors'][0]['message']?.toString() ?? message;
      }
      showCustomSnackBarWidget(message);
    } else if (response.statusCode == 429) {
      showCustomSnackBarWidget('too_many_requests_try_later'.tr);
    } else {
      String? message = response.statusText;
      if (message == null || message.trim().isEmpty || message.contains('Exception') || message.contains('<!DOCTYPE') || message.contains('<html')) {
        message = 'something_went_wrong_please_try_again'.tr;
      }
      showCustomSnackBarWidget(message);
    }
  }
}