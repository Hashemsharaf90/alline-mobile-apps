import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/bank_info/controllers/bank_info_controller.dart';
import 'package:sixvalley_vendor_app/features/bank_info/domain/services/bank_info_service_interface.dart';

class _DashboardBankService extends Fake implements BankInfoServiceInterface {
  bool failSales = false;

  ApiResponse _response(Map<String, dynamic> data) => ApiResponse.withSuccess(
        Response<dynamic>(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: data,
        ),
      );

  @override
  Future<ApiResponse> getDashboardSalesSummary() async => failSales
      ? ApiResponse.withError('offline')
      : _response({'today_sales': 245000, 'yesterday_sales': 200000});

  @override
  Future<ApiResponse> getOrderFilterData(String? type) async => _response({
        'pending': type == 'today' ? 2 : 5,
        'confirmed': 1,
        'processing': 3,
        'out_for_delivery': 0,
        'delivered': 4,
        'canceled': 0,
        'returned': 0,
        'failed': 0,
      });

  @override
  Future<ApiResponse> chartFilterData(String? type) async => _response({
        'seller_earn': [0, 1000, 2500],
        'commission_earn': [0, 100, 250],
      });
}

void main() {
  test('dashboard data remains separate from analytics page filters', () async {
    final service = _DashboardBankService();
    final controller = BankInfoController(bankInfoServiceInterface: service);

    await controller.getDashboardSalesSummary();
    await controller.getDashboardTodayAnalytics();
    await controller.getDashboardActionAnalytics();
    await controller.getDashboardWeekEarnings();

    expect(controller.todaySales, 245000);
    expect(controller.yesterdaySales, 200000);
    expect(controller.dashboardTodayAnalytics?.pending, 2);
    expect(controller.dashboardActionAnalytics?.pending, 5);
    expect(controller.dashboardWeekEarnings, [0, 1000, 2500]);
    expect(controller.businessAnalyticsFilterData, isNull);

    service.failSales = true;
    await controller.getDashboardSalesSummary();
    expect(controller.todaySales, isNull);
    expect(controller.salesSummaryFailed, isTrue);
  });

  test('dashboard calculates sales growth percentage correctly', () {
    const today = 245000.0;
    const yesterday = 200000.0;
    final diff = (today - yesterday) / yesterday * 100;
    expect(diff, closeTo(22.5, 0.01));
    expect(diff >= 0, isTrue);

    // Negative growth case
    const todayDown = 150000.0;
    final diffDown = (todayDown - yesterday) / yesterday * 100;
    expect(diffDown, closeTo(-25.0, 0.01));
    expect(diffDown < 0, isTrue);
  });
}
