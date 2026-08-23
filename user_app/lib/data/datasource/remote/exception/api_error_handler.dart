import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/error_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:provider/provider.dart';

class ApiErrorHandler {
  static dynamic getMessage(dynamic error) {
    dynamic errorDescription = "";
    if (error is Exception) {
      try {
        if (error is DioException) {
          switch (error.type) {
            case DioExceptionType.cancel:
              errorDescription = "تم إلغاء الطلب";
              break;
            case DioExceptionType.connectionTimeout:
              errorDescription = "انتهت مهلة الاتصال بالخادم";
              break;
            case DioExceptionType.sendTimeout:
              errorDescription = "انتهت مهلة إرسال البيانات";
              break;
            case DioExceptionType.receiveTimeout:
              errorDescription = "انتهت مهلة استلام البيانات";
              break;
            case DioExceptionType.badResponse:
              switch (error.response!.statusCode) {
                case 403:
                  if (error.response!.data != null && error.response!.data is Map && error.response!.data['errors'] != null) {
                    ErrorResponse errorResponse = ErrorResponse.fromJson(error.response?.data);
                    errorDescription = errorResponse.errors?[0].message;
                  } else if (error.response!.data != null && error.response!.data is Map) {
                    errorDescription = error.response!.data['message'];
                  } else {
                    errorDescription = "غير مصرح بالوصول";
                  }
                  break;
                case 401:
                  if (error.response!.data != null && error.response!.data is Map && error.response!.data['errors'] != null) {
                    ErrorResponse errorResponse = ErrorResponse.fromJson(error.response?.data);
                    errorDescription = errorResponse.errors?[0].message;
                  } else if (error.response!.data != null && error.response!.data is Map) {
                    errorDescription = error.response!.data['message'];
                  } else {
                    errorDescription = "يرجى تسجيل الدخول مجدداً";
                  }
                  Provider.of<AuthController>(Get.context!, listen: false).clearSharedData();
                  break;
                case 404:
                  errorDescription = "البيانات المطلوبة غير موجودة";
                  break;
                case 400:
                  if (error.response!.data != null && error.response!.data is Map && error.response!.data['errors'] != null) {
                    ErrorResponse errorResponse = ErrorResponse.fromJson(error.response?.data);
                    errorDescription = errorResponse.errors?[0].message;
                  } else if (error.response!.data != null && error.response!.data is Map) {
                    errorDescription = error.response?.data['message'] ?? '';
                  } else {
                    errorDescription = "طلب غير صالح";
                  }
                  break;
                case 500:
                  errorDescription = 'خطأ داخلي في الخادم';
                  break;
                case 503:
                  if (error.response!.data != null && error.response!.data is Map && error.response!.data['message'] != null) {
                    errorDescription = error.response!.data['message'];
                  } else {
                    errorDescription = "الخدمة غير متوفرة حالياً";
                  }
                  break;
                case 429:
                  errorDescription = "يرجى الانتظار قليلاً قبل إعادة المحاولة";
                  break;
                default:
                  try {
                    ErrorResponse errorResponse = ErrorResponse.fromJson(error.response!.data);
                    if (errorResponse.errors != null && errorResponse.errors!.isNotEmpty) {
                      errorDescription = errorResponse;
                    } else {
                      errorDescription = "فشل تحميل البيانات (${error.response!.statusCode})";
                    }
                  } catch (_) {
                    errorDescription = "فشل تحميل البيانات (${error.response!.statusCode})";
                  }
              }
              break;
            case DioExceptionType.badCertificate:
              errorDescription = "شهادة الأمان غير صالحة";
              break;
            case DioExceptionType.connectionError:
              errorDescription = "تعذر الاتصال، يرجى التحقق من اتصال الإنترنت";
              break;
            case DioExceptionType.unknown:
              errorDescription = "تعذر الاتصال، يرجى التحقق من اتصال الإنترنت";
              break;
          }
        } else {
          errorDescription = "حدث خطأ غير متوقع";
        }
      } catch (e) {
        errorDescription = e.toString();
      }
    } else {
      errorDescription = "حدث خطأ في النظام";
    }
    return errorDescription;
  }
}
