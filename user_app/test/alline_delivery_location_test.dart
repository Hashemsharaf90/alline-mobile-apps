import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sixvalley_ecommerce/features/location/controllers/location_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/location/domain/services/location_service_interface.dart';

class _LocationService implements LocationServiceInterface {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Only confirmed delivery coordinates survive a new controller',
      () async {
    SharedPreferences.setMockInitialValues({});
    final location =
        LocationController(locationServiceInterface: _LocationService());
    await location.restoreDeliveryLocation();
    await location.setPickedCoordinates(
        latitude: 15.35,
        longitude: 44.20,
        fromAddress: true,
        address: 'صنعاء، حدة');
    expect(location.deliveryLatitude, isNull);
    await location.confirmDeliveryLocation();
    await location.setPickedCoordinates(
        latitude: 14.5,
        longitude: 43.5,
        fromAddress: true,
        address: 'موقع غير مؤكد');
    expect(location.deliveryLabel, 'صنعاء، حدة');
    final restored =
        LocationController(locationServiceInterface: _LocationService());
    await restored.restoreDeliveryLocation();
    expect(restored.deliveryLatitude, 15.35);
    expect(restored.deliveryLongitude, 44.20);
    expect(restored.deliveryLabel, 'صنعاء، حدة');
    location.dispose();
    restored.dispose();
  });
}
