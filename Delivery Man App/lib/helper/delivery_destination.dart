import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixvalley_delivery_boy/features/order/domain/models/order_model.dart';

abstract final class DeliveryDestination {
  static bool isStore(OrderModel order) => const [
        'assigned',
        'accepted',
        'heading_to_store',
        'arrived_at_store'
      ].contains(order.driverJourneyStatus ??
          (const ['pending', 'confirmed', 'processing']
                  .contains(order.orderStatus)
              ? 'assigned'
              : order.orderStatus));

  static LatLng? coordinates(OrderModel order) {
    final store = isStore(order);
    final lat = double.tryParse((store
            ? order.seller?.shop?.latitude
            : order.shippingAddress?.latitude) ??
        '');
    final lng = double.tryParse((store
            ? order.seller?.shop?.longitude
            : order.shippingAddress?.longitude) ??
        '');
    if (lat == null ||
        lng == null ||
        !lat.isFinite ||
        !lng.isFinite ||
        lat.abs() > 90 ||
        lng.abs() > 180) {
      return null;
    }
    return LatLng(lat, lng);
  }
}
