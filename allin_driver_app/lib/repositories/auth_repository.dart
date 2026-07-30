import 'dart:convert';

import 'package:active_flutter_delivery_app/app_config.dart';
import 'package:active_flutter_delivery_app/data_model/common_response.dart';
import 'package:active_flutter_delivery_app/data_model/login_response.dart';
import 'package:active_flutter_delivery_app/data_model/logout_response.dart';
import 'package:active_flutter_delivery_app/helpers/api_request.dart';
import 'package:active_flutter_delivery_app/helpers/shared_value_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AuthRepository {
  static const MethodChannel _notificationChannel = MethodChannel(
    'allin_delivery/notifications',
  );

  Future<LoginResponse> getLoginResponse(
    String? email,
    String password,
    String loginBy,
  ) async {
    var postBody = jsonEncode({
      "user_type": "delivery_boy",
      "email": "$email",
      "password": password,
      "login_by": loginBy,
    });

    final response = await ApiRequest.post(
      url: ("${AppConfig.BASE_URL}/${AppConfig.DELIVERY_PREFIX}/auth/login"),
      headers: {
        "Content-Type": "application/json",
        "X-Requested-With": "XMLApiRequestRequest",
      },
      body: postBody,
    );

    debugPrint("Delivery login status: ${response.statusCode}");
    debugPrint(
      "Delivery login body: ${response.body.length > 500 ? response.body.substring(0, 500) : response.body}",
    );

    try {
      return loginResponseFromJson(response.body);
    } catch (error) {
      debugPrint("Delivery login parse error: $error");
      return LoginResponse(
        result: false,
        message: "Login failed. Please check server response and account data.",
      );
    }
  }

  Future<LogoutResponse> getLogoutResponse() async {
    final response = await ApiRequest.get(
      url: ("${AppConfig.BASE_URL}/${AppConfig.DELIVERY_PREFIX}/auth/logout"),
      headers: {"Authorization": "Bearer ${access_token.$}"},
    );

    return logoutResponseFromJson(response.body);
  }

  Future<LoginResponse> getUserByTokenResponse() async {
    var postBody = jsonEncode({"access_token": "${access_token.$}"});

    final response = await ApiRequest.post(
      url: ("${AppConfig.BASE_URL}/${AppConfig.DELIVERY_PREFIX}/auth/info"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
      },
      body: postBody,
    );

    return loginResponseFromJson(response.body);
  }

  Future<CommonResponse> updateFcmToken() async {
    final token = await _notificationChannel.invokeMethod<String>(
      'getFcmToken',
    );
    if (token == null || token.isEmpty || (access_token.$ ?? '').isEmpty) {
      return CommonResponse(
        result: false,
        message: 'Firebase device token is empty',
      );
    }

    final response = await ApiRequest.put(
      url:
          ("${AppConfig.BASE_URL}/${AppConfig.DELIVERY_PREFIX}/update-fcm-token"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
      },
      body: jsonEncode({"fcm_token": token}),
    );

    return commonResponseFromJson(response.body);
  }

  Future<CommonResponse> getAccountDeleteResponse() async {
    String url = ("${AppConfig.BASE_URL}/auth/account-deletion");

    final response = await ApiRequest.get(
      url: url,
      headers: {
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!,
      },
    );
    return commonResponseFromJson(response.body);
  }
}
