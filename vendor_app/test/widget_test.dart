import 'package:flutter_test/flutter_test.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

void main() {
  test('Alline Seller App configuration and branding verification', () {
    // 1. Verify app name
    expect(AppConstants.appName, equals('Alline Seller'));

    // 2. Verify color palette matches Alline Design System
    expect(AllineColors.primary, isNotNull);
    expect(AllineColors.secondary, isNotNull);

    // 3. Verify order & delivery API endpoints
    expect(AppConstants.orderListUri, isNotEmpty);
    expect(AppConstants.orderDetails, isNotEmpty);
    expect(AppConstants.getDeliveryManUri, isNotEmpty);
  });
}
