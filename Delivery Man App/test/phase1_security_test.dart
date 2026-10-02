import 'package:flutter_test/flutter_test.dart';
import 'package:sixvalley_delivery_boy/features/profile/domain/models/userinfo_model.dart';
import 'package:sixvalley_delivery_boy/utill/app_constants.dart';

void main() {
  group('Phase 1 Security & Bug Fix Tests', () {
    test('UserInfoModel correctly separates is_active and is_online', () {
      final json = {
        'id': 1,
        'f_name': 'Test',
        'l_name': 'Driver',
        'phone': '1234567890',
        'email': 'driver@test.com',
        'is_active': 1,
        'is_online': 0,
        'approval_status': 'active',
      };

      final model = UserInfoModel.fromJson(json);

      expect(model.isActive, 1);
      expect(model.isOnline, 0);
      expect(model.approvalStatus, 'active');
    });

    test('UserInfoModel handles string or null values for online and active safely', () {
      final json = {
        'id': 2,
        'f_name': 'Test2',
        'is_active': '0',
        'is_online': '1',
      };

      final model = UserInfoModel.fromJson(json);

      expect(model.isActive, 0);
      expect(model.isOnline, 1);
    });

    test('AppConstants endpoints are correctly configured', () {
      expect(AppConstants.logoutUri, '/api/v2/delivery-man/logout');
      expect(AppConstants.searchConversationListUri, '/api/v2/delivery-man/messages/search/');
      expect(AppConstants.chatSearch, '/api/v2/delivery-man/messages/search/');
      expect(AppConstants.polylineMapKey, '');
    });

    test('Chat search URL encoding safely encodes Arabic and spaces', () {
      const search = 'علي أحمد';
      final encoded = Uri.encodeComponent(search);
      final url = '${AppConstants.chatSearch}customer?search=$encoded';

      expect(url.contains('customer'), true);
      expect(url.contains(encoded), true);
    });
  });
}
