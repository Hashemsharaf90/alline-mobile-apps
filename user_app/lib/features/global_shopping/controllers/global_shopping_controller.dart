import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/domain/models/global_product_preview_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/domain/models/global_shopping_request_model.dart';
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

  List<GlobalShoppingRequestModel> _requestsList = [];
  List<GlobalShoppingRequestModel> get requestsList => _requestsList;

  List<dynamic> _supportedStores = [];
  List<dynamic> get supportedStores => _supportedStores;

  String _selectedShippingType = 'air'; // 'air' or 'sea'
  String get selectedShippingType => _selectedShippingType;

  void setShippingType(String type) {
    _selectedShippingType = type;
    notifyListeners();
  }

  void clearPreview() {
    _productPreview = null;
    notifyListeners();
  }

  Future<void> fetchSupportedStores() async {
    final ApiResponseModel apiResponse = await globalShoppingService.getSupportedStores();
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      final data = apiResponse.response!.data;
      if (data['stores'] is List) {
        _supportedStores = data['stores'];
        notifyListeners();
      }
    }
  }

  Future<void> previewProduct(String url, BuildContext context) async {
    if (url.trim().isEmpty) {
      showCustomSnackBarWidget('Please enter a valid product URL', context, snackBarType: SnackBarType.warning);
      return;
    }

    _isPreviewLoading = true;
    _productPreview = null;
    notifyListeners();

    final ApiResponseModel apiResponse = await globalShoppingService.previewProduct(url.trim());
    _isPreviewLoading = false;

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      final data = apiResponse.response!.data;
      if (data['status'] == true && data['data'] != null) {
        _productPreview = GlobalProductPreviewModel.fromJson(data['data']);
      }
    } else {
      ApiChecker.checkApi(apiResponse);
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

    final ApiResponseModel apiResponse = await globalShoppingService.submitRequest(
      productUrl: productUrl,
      storeName: storeName ?? _productPreview?.storeName,
      quantity: quantity,
      customerNotes: customerNotes,
      shippingType: _selectedShippingType,
    );

    _isSubmitLoading = false;
    notifyListeners();

    if (apiResponse.response != null && (apiResponse.response!.statusCode == 200 || apiResponse.response!.statusCode == 201)) {
      if (onSuccess != null) { onSuccess(); }
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

    final ApiResponseModel apiResponse = await globalShoppingService.getRequests(offset: offset);
    _isRequestsLoading = false;

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
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
