import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/domain/models/global_product_preview_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/domain/models/global_shopping_request_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/domain/models/global_shopping_store_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/domain/services/global_shopping_service.dart';
import 'package:flutter_sixvalley_ecommerce/helper/api_checker.dart';

class GlobalShoppingController extends ChangeNotifier {
  final GlobalShoppingService globalShoppingService;
  GlobalShoppingController({required this.globalShoppingService});

  bool _isPreviewLoading = false;
  bool get isPreviewLoading => _isPreviewLoading;

  bool _isSubmitLoading = false;
  bool get isSubmitLoading => _isSubmitLoading;

  bool _isRequestsLoading = false;
  bool get isRequestsLoading => _isRequestsLoading;

  GlobalProductPreviewModel? _productPreview;
  GlobalProductPreviewModel? get productPreview => _productPreview;

  String? _previewErrorMessage;
  String? get previewErrorMessage => _previewErrorMessage;

  List<GlobalShoppingRequestModel> _requestsList = [];
  List<GlobalShoppingRequestModel> get requestsList => _requestsList;

  bool _isStoresLoading = false;
  bool get isStoresLoading => _isStoresLoading;

  bool _hasStoresError = false;
  bool get hasStoresError => _hasStoresError;

  List<GlobalShoppingStoreModel> _supportedStores = [];
  List<GlobalShoppingStoreModel> get supportedStores => _supportedStores;

  void clearPreview() {
    _productPreview = null;
    _previewErrorMessage = null;
    notifyListeners();
  }

  Future<void> fetchSupportedStores() async {
    _isStoresLoading = true;
    _hasStoresError = false;
    notifyListeners();

    final ApiResponseModel apiResponse =
        await globalShoppingService.getSupportedStores();
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      final data = apiResponse.response!.data;
      if (data['stores'] is List) {
        _supportedStores = (data['stores'] as List)
            .whereType<Map>()
            .map((store) => GlobalShoppingStoreModel.fromJson(
                Map<String, dynamic>.from(store)))
            .toList();
        _hasStoresError = _supportedStores.isEmpty;
      } else {
        _hasStoresError = true;
      }
    } else {
      _hasStoresError = true;
    }

    _isStoresLoading = false;
    notifyListeners();
  }

  Future<void> previewProduct(String url, BuildContext context) async {
    if (url.trim().isEmpty) {
      showCustomSnackBarWidget('Please enter a valid product URL', context,
          snackBarType: SnackBarType.warning);
      return;
    }

    _isPreviewLoading = true;
    _productPreview = null;
    _previewErrorMessage = null;
    notifyListeners();

    final ApiResponseModel apiResponse =
        await globalShoppingService.previewProduct(url.trim());
    _isPreviewLoading = false;

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      final data = apiResponse.response!.data;
      if (data['status'] == true && data['data'] != null) {
        _productPreview = GlobalProductPreviewModel.fromJson(data['data']);
      }
    } else {
      final isLtr = Localizations.localeOf(context).languageCode == 'en';
      final error = apiResponse.error;
      final code = error is Map ? error['code']?.toString() : null;
      final message = switch (code) {
        'unsupported_store' => isLtr
            ? 'This store is not supported yet.'
            : 'هذا المتجر غير مدعوم حالياً.',
        'invalid_product_url' => isLtr
            ? 'The product link is invalid.'
            : 'رابط المنتج غير صالح.',
        'product_data_incomplete' || 'product_unavailable' => isLtr
            ? 'Could not get real product data. Try another product link.'
            : 'تعذر الحصول على بيانات حقيقية للمنتج. تحقق من الرابط أو جرّب رابطاً آخر.',
        _ => isLtr
            ? 'Could not read this product. Check your connection and try again.'
            : 'تعذر قراءة المنتج. تحقق من اتصالك وحاول مرة أخرى.',
      };
      showCustomSnackBarWidget(message, context,
          snackBarType: SnackBarType.warning);
      _previewErrorMessage = message;
    }
    if (_productPreview == null && _previewErrorMessage == null) {
      _previewErrorMessage = Localizations.localeOf(context).languageCode == 'en'
          ? 'Could not read this product. Try again.'
          : 'تعذر قراءة بيانات هذا المنتج. حاول مرة أخرى.';
    }
    notifyListeners();
  }

  Future<bool> submitRequest({
    required String productUrl,
    String? storeName,
    int quantity = 1,
    String? customerNotes,
    Function? onSuccess,
  }) async {
    _isSubmitLoading = true;
    notifyListeners();

    final ApiResponseModel apiResponse =
        await globalShoppingService.submitRequest(
      productUrl: productUrl,
      storeName: storeName ?? _productPreview?.storeName,
      quantity: quantity,
      customerNotes: customerNotes,
    );

    _isSubmitLoading = false;
    notifyListeners();

    if (apiResponse.response != null &&
        (apiResponse.response!.statusCode == 200 ||
            apiResponse.response!.statusCode == 201)) {
      if (onSuccess != null) {
        onSuccess();
      }
      clearPreview();
      getMyRequests();
      return true;
    } else {
      ApiChecker.checkApi(apiResponse);
      return false;
    }
  }

  Future<void> getMyRequests({int offset = 1}) async {
    _isRequestsLoading = true;
    notifyListeners();

    final ApiResponseModel apiResponse =
        await globalShoppingService.getRequests(offset: offset);
    _isRequestsLoading = false;

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      final data = apiResponse.response!.data;
      if (data['requests'] is List) {
        _requestsList = (data['requests'] as List)
            .map((e) => GlobalShoppingRequestModel.fromJson(e))
            .toList();
      }
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }
}
