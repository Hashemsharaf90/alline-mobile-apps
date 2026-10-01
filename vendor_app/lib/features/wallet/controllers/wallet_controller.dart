import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/features/profile/domain/models/withdraw_model.dart';
import 'package:sixvalley_vendor_app/features/shop/controllers/shop_controller.dart';
import 'package:sixvalley_vendor_app/features/shop/domain/models/payment_information_model.dart';
import 'package:sixvalley_vendor_app/features/transaction/controllers/transaction_controller.dart';
import 'package:sixvalley_vendor_app/features/wallet/domain/services/wallet_service_interface.dart';
import 'package:sixvalley_vendor_app/helper/api_checker.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';

class WalletController with ChangeNotifier{

  final WalletServiceInterface walletServiceInterface;
  WalletController({required this.walletServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isLoadingWithdrawMethods = false;
  bool get isLoadingWithdrawMethods => _isLoadingWithdrawMethods;
  bool _withdrawMethodLoadFailed = false;
  bool get withdrawMethodLoadFailed => _withdrawMethodLoadFailed;

  WithdrawModel? withdrawModel;
  List<WithdrawModel> methodList = [];
  MethodModel? methodSelected;
  List<MethodModel?> methodsIds = [];
  List<MethodModel?> myMethodsIds = [];

  List<String> inputValueList = [];
  bool validityCheck = false;

  PaymentInformationModel ? _paymentInformationModel;
  PaymentInformationModel ? get paymentInformationModel => _paymentInformationModel;
  bool _isLoadingPaymentInfo = false;
  bool get isLoadingPaymentInfo => _isLoadingPaymentInfo;
  bool _paymentInfoLoadFailed = false;
  bool get paymentInfoLoadFailed => _paymentInfoLoadFailed;




  void setTitle(int index, String title) {
    inputFieldControllerList[index].text = title;
  }


  List<TextEditingController> inputFieldControllerList = [];
  void getInputFieldList(){
    _disposeInputFieldControllers();
    inputFieldControllerList = [];
    if(methodList.isNotEmpty){
      for(int i= 0; i< (methodSelected?.methodFields?.length ?? 0 ) ; i++){
        inputFieldControllerList.add(TextEditingController());
      }
    }
  }

  void _disposeInputFieldControllers() {
    for (final controller in inputFieldControllerList) {
      controller.dispose();
    }
    inputFieldControllerList.clear();
  }

  List <String?> keyList = [];


  void setMethodTypeIndex(MethodModel? index, {bool notify = true}) {
    methodSelected = index;

    keyList = [];
    if(methodList.isNotEmpty){
      for(int i= 0; i< (methodSelected?.methodFields?.length ?? 0) ; i++){
        keyList.add(methodSelected?.methodFields![i].inputName);
      }
      getInputFieldList();
    }
    if(notify){
      notifyListeners();
    }
  }


  Future<void> getWithdrawMethods(BuildContext context) async{
    _isLoadingWithdrawMethods = true;
    _withdrawMethodLoadFailed = false;
    methodList = [];
    methodsIds = [];
    notifyListeners();
    try {
      final ApiResponse response =
          await walletServiceInterface.getDynamicWithDrawMethod();
      final data = response.response?.data;
      if (response.response?.statusCode == 200 && data is List) {
        for (final method in data) {
          if (method is Map) {
            methodList.add(
              WithdrawModel.fromJson(Map<String, dynamic>.from(method)),
            );
          }
        }
        getInputFieldList();
        for (final method in methodList) {
          methodsIds.add(
            MethodModel(
              id: method.id,
              inputName: method.methodName,
              type: 'other',
              methodFields: method.methodFields,
            ),
          );
        }
      } else {
        _withdrawMethodLoadFailed = true;
      }
    } catch (_) {
      _withdrawMethodLoadFailed = true;
    } finally {
      _isLoadingWithdrawMethods = false;
      notifyListeners();
    }
  }



  void checkValidity(){
    for(int i= 0; i< inputValueList.length; i++){
      if(inputValueList[i].isEmpty){
        inputValueList.clear();
        validityCheck = true;
        notifyListeners();
      }
    }

  }


  Future<ApiResponse> updateBalance(String balance, BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    inputValueList.clear();

    if(methodSelected?.type == 'other') {
      for(TextEditingController textEditingController in inputFieldControllerList) {
        inputValueList.add(textEditingController.text.trim());
      }
    } else if(methodSelected?.type == 'my_methods') {
      inputValueList = [];
      keyList = [];

      methodSelected?.methodInfo?.forEach((key, value) {
        keyList.add(key);
        inputValueList.add(value);
      });
    }


    try {
      final ApiResponse apiResponse = await walletServiceInterface.withdrawBalance(
        keyList,
        inputValueList,
        methodSelected?.id,
        balance,
      );

      if (apiResponse.response?.statusCode == 200) {
        inputValueList.clear();
        _disposeInputFieldControllers();
        if (context.mounted) {
          final shopController =
              Provider.of<ShopController>(context, listen: false);
          if (shopController.shopModel?.setupGuideApp != null &&
              shopController.shopModel?.setupGuideApp?['withdraw_setup'] != 1) {
            shopController.updateTutorialFlow('withdraw_setup');
            shopController.updateSetupGuideApp('withdraw_setup', 1);
          }
          Provider.of<TransactionController>(context, listen: false)
              .getTransactionList(context, 'all', '', '');
          Provider.of<ProfileController>(context, listen: false).getSellerInfo();
          showCustomSnackBarWidget(
            getTranslated('withdraw_request_sent_successfully', context),
            context,
            isToaster: true,
            isError: false,
          );
          Navigator.of(context).pop();
        }
      } else if (apiResponse.error != null && apiResponse.error.isNotEmpty) {
        showToast(message: apiResponse.error.toString());
      } else {
        ApiChecker.checkApi(apiResponse);
      }
      return apiResponse;
    } catch (_) {
      if (context.mounted) {
        showToast(message: 'تعذر إرسال طلب السحب. حاول مرة أخرى.');
      }
      return ApiResponse.withError('تعذر إرسال طلب السحب. حاول مرة أخرى.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ApiResponse> updateWithdrawRequest(String balance, int requestId, BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    inputValueList.clear();

    if (methodSelected?.type == 'other') {
      for (TextEditingController textEditingController in inputFieldControllerList) {
        inputValueList.add(textEditingController.text.trim());
      }
    } else if (methodSelected?.type == 'my_methods') {
      inputValueList = [];
      keyList = [];

      methodSelected?.methodInfo?.forEach((key, value) {
        keyList.add(key);
        inputValueList.add(value);
      });
    }

    try {
      final ApiResponse apiResponse =
          await walletServiceInterface.updateWithdrawRequest(
        keyList,
        inputValueList,
        methodSelected?.id,
        balance,
        requestId,
      );

      if (apiResponse.response?.statusCode == 200) {
        inputValueList.clear();
        _disposeInputFieldControllers();
        if (context.mounted) {
          Provider.of<TransactionController>(context, listen: false)
              .getTransactionList(context, 'all', '', '');
          Provider.of<ProfileController>(context, listen: false).getSellerInfo();
          showCustomSnackBarWidget(
            getTranslated('withdraw_request_updated_successfully', context),
            context,
            isToaster: true,
            isError: false,
          );
          Navigator.of(context).pop();
        }
      } else if (apiResponse.error != null && apiResponse.error.isNotEmpty) {
        showToast(message: apiResponse.error.toString());
      } else {
        ApiChecker.checkApi(apiResponse);
      }
      return apiResponse;
    } catch (_) {
      if (context.mounted) {
        showToast(message: 'تعذر تحديث طلب السحب. حاول مرة أخرى.');
      }
      return ApiResponse.withError('تعذر تحديث طلب السحب. حاول مرة أخرى.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  Future<void> getPaymentInfoList() async {
    _isLoadingPaymentInfo = true;
    _paymentInfoLoadFailed = false;
    _paymentInformationModel = null;
    myMethodsIds = [];
    notifyListeners();
    try {
      final ApiResponse apiResponse =
          await walletServiceInterface.getPaymentInfoList();
      if (apiResponse.response?.statusCode == 200 &&
          apiResponse.response?.data is Map) {
        _paymentInformationModel =
            PaymentInformationModel.fromJson(apiResponse.response!.data);

        for (final information in _paymentInformationModel?.data ?? []) {
          myMethodsIds.add(
            MethodModel(
              id: information.withdrawMethodId,
              inputName: information.methodName,
              type: 'my_methods',
              methodFields: information.withdrawMethod?.methodFields,
              methodInfo: information.methodInfo,
              isDefault: information.isDefault ?? false,
            ),
          );
        }
      } else {
        _paymentInfoLoadFailed = true;
        ApiChecker.checkApi(apiResponse);
      }
    } catch (_) {
      _paymentInfoLoadFailed = true;
    } finally {
      _isLoadingPaymentInfo = false;
      notifyListeners();
    }
  }


  void setDefaultPaymentMethod () {
    if(methodSelected == null || (!(methodSelected?.isDefault ?? false) && myMethodsIds.isNotEmpty)) {
      for(MethodModel? paymentInfo in myMethodsIds) {
        if(paymentInfo?.isDefault ?? false) {
          setMethodTypeIndex(
            paymentInfo,
            notify: false,
          );
        }
      }
    } else if (methodSelected == null && methodsIds.isNotEmpty) {
      setMethodTypeIndex(
        methodsIds.first,
        notify: false,
      );
    }
  }



  Future<ApiResponse> closeWithdrawRequest(
    int id,
    String balance, {
    BuildContext? context,
  }) async {
    _isLoading = true;
    notifyListeners();

    ApiResponse apiResponse = await walletServiceInterface.closeWithdrawRequest(id, balance);
    if (apiResponse.response?.statusCode == 200 &&
        context != null &&
        context.mounted) {
      Provider.of<ProfileController>(context, listen: false)
          .updateWalletAmount(balance);
      Provider.of<ShopController>(context, listen: false).getShopInfo();
    }
    _isLoading = false;
    notifyListeners();
    return apiResponse;
  }



  void showToast({Color backGroundColor = Colors.red, required String message}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: backGroundColor,
      textColor: Colors.white,
      fontSize: Dimensions.fontSizeDefault
    );
  }


}
