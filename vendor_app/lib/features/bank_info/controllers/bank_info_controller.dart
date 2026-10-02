import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/order/domain/models/business_analytics_filter_data.dart';
import 'package:sixvalley_vendor_app/features/profile/domain/models/profile_body.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/data/model/response/response_model.dart';
import 'package:sixvalley_vendor_app/features/bank_info/domain/services/bank_info_service_interface.dart';
import 'package:sixvalley_vendor_app/features/profile/domain/models/profile_info.dart';
import 'package:sixvalley_vendor_app/helper/api_checker.dart';

class BankInfoController extends ChangeNotifier {
  final BankInfoServiceInterface bankInfoServiceInterface;

  BankInfoController({required this.bankInfoServiceInterface});

  ProfileInfoModel? _bankInfo;
  List<double?>? _userEarnings;
  List<double?>? _userCommissions;
  ProfileInfoModel? get bankInfo => _bankInfo;
  List<double?>? get userEarnings => _userEarnings;
  List<double?>? get userCommissions => _userCommissions;

  String? _analyticsName = '';
  String? get analyticsName => _analyticsName;
  int _analyticsIndex = 0;
  int get analyticsIndex => _analyticsIndex;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  BusinessAnalyticsFilterDataModel? _businessAnalyticsFilterData;
  BusinessAnalyticsFilterDataModel? get businessAnalyticsFilterData =>
      _businessAnalyticsFilterData;
  bool _analyticsFilterFailed = false;
  bool get analyticsFilterFailed => _analyticsFilterFailed;
  bool _revenueDataFailed = false;
  bool get revenueDataFailed => _revenueDataFailed;
  bool _hasSellerEarningsData = false;
  bool get hasSellerEarningsData => _hasSellerEarningsData;
  bool get hasCommissionData => _commission.isNotEmpty;
  BusinessAnalyticsFilterDataModel? _dashboardTodayAnalytics;
  BusinessAnalyticsFilterDataModel? get dashboardTodayAnalytics =>
      _dashboardTodayAnalytics;
  BusinessAnalyticsFilterDataModel? _dashboardActionAnalytics;
  BusinessAnalyticsFilterDataModel? get dashboardActionAnalytics =>
      _dashboardActionAnalytics;

  Future<void> getDashboardActionAnalytics() async {
    final response = await bankInfoServiceInterface.getOrderFilterData('all');
    if (response.response?.statusCode == 200 &&
        response.response?.data is Map) {
      _dashboardActionAnalytics =
          BusinessAnalyticsFilterDataModel.fromJson(response.response!.data);
    } else {
      _dashboardActionAnalytics = null;
    }
    notifyListeners();
  }

  Future<void> getDashboardTodayAnalytics() async {
    final response = await bankInfoServiceInterface.getOrderFilterData('today');
    if (response.response?.statusCode == 200 &&
        response.response?.data is Map) {
      _dashboardTodayAnalytics =
          BusinessAnalyticsFilterDataModel.fromJson(response.response!.data);
    } else {
      _dashboardTodayAnalytics = null;
    }
    notifyListeners();
  }

  double? _todaySales;
  double? _yesterdaySales;
  double? get todaySales => _todaySales;
  double? get yesterdaySales => _yesterdaySales;
  List<double>? _dashboardWeekEarnings;
  List<double>? get dashboardWeekEarnings => _dashboardWeekEarnings;

  Future<void> getDashboardWeekEarnings() async {
    final response = await bankInfoServiceInterface.chartFilterData('WeekEarn');
    if (response.response?.statusCode == 200 &&
        response.response?.data is Map) {
      final values = response.response!.data['seller_earn'];
      if (values is List) {
        _dashboardWeekEarnings = values
            .map((value) => double.tryParse('$value') ?? 0.0)
            .toList(growable: false);
      } else {
        _dashboardWeekEarnings = null;
      }
    } else {
      _dashboardWeekEarnings = null;
    }
    notifyListeners();
  }

  bool _salesSummaryFailed = false;
  bool get salesSummaryFailed => _salesSummaryFailed;

  Future<void> getDashboardSalesSummary() async {
    final response = await bankInfoServiceInterface.getDashboardSalesSummary();
    if (response.response?.statusCode == 200 &&
        response.response?.data is Map) {
      final data = response.response!.data;
      _todaySales = double.tryParse('${data['today_sales']}');
      _yesterdaySales = double.tryParse('${data['yesterday_sales']}');
      _salesSummaryFailed = _todaySales == null;
    } else {
      _todaySales = null;
      _yesterdaySales = null;
      _salesSummaryFailed = true;
    }
    notifyListeners();
  }

  int _revenueFilterTypeIndex = 0;
  int get revenueFilterTypeIndex => _revenueFilterTypeIndex;
  String? _revenueFilterType = '';
  String? get revenueFilterType => _revenueFilterType;

  bool _showWarning = true;
  bool get showWarning => _showWarning;

  void setRevenueFilterName(
      BuildContext context, String? filterName, bool notify) {
    _revenueFilterType = filterName;
    String? callingString;
    if (_revenueFilterType == 'this_year') {
      callingString = 'yearEarn';
    } else if (_revenueFilterType == 'this_month') {
      callingString = 'MonthEarn';
    } else if (_revenueFilterType == 'this_week') {
      callingString = 'WeekEarn';
    }
    getDashboardRevenueData(context, callingString);
    if (notify) {
      notifyListeners();
    }
  }

  void setRevenueFilterType(int index, bool notify) {
    _revenueFilterTypeIndex = index;
    if (notify) {
      notifyListeners();
    }
  }

  List<dynamic> _earnings = [];
  List<dynamic> get earnings => _earnings;
  List<dynamic> _commission = [];
  List<dynamic> get commission => _commission;
  double _lim = 0.0;
  double get lim => _lim;

  Future<void> getDashboardRevenueData(
      BuildContext context, String? filterType) async {
    _userEarnings = null;
    _userCommissions = null;
    _earnings = [];
    _commission = [];
    _lim = 0;
    _revenueDataFailed = false;
    _hasSellerEarningsData = false;
    notifyListeners();
    try {
      final ApiResponse apiResponse =
          await bankInfoServiceInterface.chartFilterData(filterType);
      final data = apiResponse.response?.data;
      if (apiResponse.response?.statusCode == 200 &&
          data is Map &&
          data['seller_earn'] is List &&
          data['commission_earn'] is List) {
        _earnings = List<dynamic>.from(data['seller_earn']);
        _commission = List<dynamic>.from(data['commission_earn']);
        _hasSellerEarningsData = _earnings.isNotEmpty;
        final sellerEarnings = _earnings
            .map((value) => double.tryParse('$value'))
            .toList(growable: true);
        final commissions = _commission
            .map((value) => double.tryParse('$value'))
            .toList(growable: true);
        if (sellerEarnings.every((value) => value != null) &&
            commissions.every((value) => value != null)) {
          _userEarnings = sellerEarnings;
          _userCommissions = commissions;
          _userEarnings!.insert(0, 0);
          _userCommissions!.insert(0, 0);
          final maxEarning = _userEarnings!
              .whereType<double>()
              .fold<double>(0, (maximum, value) => value > maximum ? value : maximum);
          final maxCommission = _userCommissions!
              .whereType<double>()
              .fold<double>(0, (maximum, value) => value > maximum ? value : maximum);
          _lim = maxEarning > maxCommission ? maxEarning : maxCommission;
        } else {
          _revenueDataFailed = true;
        }
      } else {
        _revenueDataFailed = true;
        ApiChecker.checkApi(apiResponse);
      }
    } catch (_) {
      _revenueDataFailed = true;
    }
    notifyListeners();
  }

  Future<void> getBankInfo(BuildContext context) async {
    _bankInfo = await bankInfoServiceInterface.getBankList();
    notifyListeners();
  }

  Future<ResponseModel?> updateBankInfo(
      BuildContext context,
      ProfileInfoModel updateUserModel,
      ProfileBody seller,
      String token) async {
    _isLoading = true;
    notifyListeners();
    ResponseModel responseModel = await bankInfoServiceInterface.updateBank(
        updateUserModel, seller, token);
    _isLoading = false;
    notifyListeners();
    return responseModel;
  }

  String getBankToken() {
    return bankInfoServiceInterface.getBankToken();
  }

  void setAnalyticsFilterName(
      BuildContext context, String? filterName, bool notify) {
    _analyticsName = filterName;
    getAnalyticsFilterData(context, _analyticsName);
    if (notify) {
      notifyListeners();
    }
  }

  void setAnalyticsFilterType(int index, bool notify) {
    _analyticsIndex = index;
    if (notify) {
      _businessAnalyticsFilterData = null;
      notifyListeners();
    }
  }

  Future<void> getAnalyticsFilterData(
      BuildContext context, String? type) async {
    _isLoading = true;
    _businessAnalyticsFilterData = null;
    _analyticsFilterFailed = false;
    notifyListeners();
    try {
      final ApiResponse response =
          await bankInfoServiceInterface.getOrderFilterData(type);
      if (response.response?.statusCode == 200 &&
          response.response?.data is Map) {
        _businessAnalyticsFilterData =
            BusinessAnalyticsFilterDataModel.fromJson(response.response!.data);
      } else {
        _analyticsFilterFailed = true;
        ApiChecker.checkApi(response);
      }
    } catch (_) {
      _analyticsFilterFailed = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setWarningValue(bool showWarning, {bool isUpdate = false}) {
    _showWarning = showWarning;
    if (isUpdate) {
      notifyListeners();
    }
  }
}
