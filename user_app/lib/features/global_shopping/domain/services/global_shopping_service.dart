import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';

class GlobalShoppingService {
  final DioClient dioClient;
  GlobalShoppingService({required this.dioClient});

  static const String _basePath = '/api/v1/customer/global-shopping';

  Future<ApiResponseModel> getSupportedStores() async {
    try {
      final response = await dioClient.get('$_basePath/stores');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> previewProduct(String url) async {
    try {
      final response = await dioClient.post(
        '$_basePath/preview',
        data: {'product_url': url},
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> submitRequest({
    required String productUrl,
    String? storeName,
    int quantity = 1,
    String? customerNotes,
    String? shippingType,
  }) async {
    try {
      final response = await dioClient.post(
        '$_basePath/request',
        data: {
          'product_url': productUrl,
          'store_name': storeName,
          'quantity': quantity,
          'customer_notes': customerNotes,
          'shipping_type': shippingType,
        },
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> getRequests({int offset = 1, int limit = 20}) async {
    try {
      final response = await dioClient.get('$_basePath/requests?offset=$offset&limit=$limit');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }
}
