import 'package:flutter/material.dart';
import 'package:sixvalley_delivery_boy/features/order/domain/models/order_model.dart';
import 'package:sixvalley_delivery_boy/theme/alline/alline_colors.dart';

abstract final class DriverJourney {
  static const stages = ['assigned', 'accepted', 'heading_to_store', 'arrived_at_store', 'picked_up', 'heading_to_customer', 'arrived_at_customer', 'delivered'];
  static String status(OrderModel order) {
    if (const ['delivered', 'canceled', 'returned', 'failed'].contains(order.orderStatus)) return order.orderStatus!;
    return order.driverJourneyStatus ?? (const ['pending', 'confirmed', 'processing'].contains(order.orderStatus) ? 'assigned' : order.orderStatus ?? '');
  }
  static String labelKey(String status) => switch (status) {
    'assigned' || 'accepted' || 'heading_to_store' || 'arrived_at_store' || 'picked_up' || 'heading_to_customer' || 'arrived_at_customer' || 'delivered' => 'status_$status',
    'out_for_delivery' => 'status_picked_up',
    'canceled' => 'alline_canceled', 'returned' => 'alline_returned', 'failed' => 'alline_failed',
    _ => 'alline_status_unavailable',
  };
  static Color color(String status, {bool paused = false}) {
    if (paused) return AllineColors.warning;
    return switch (status) { 'delivered' => AllineColors.success, 'canceled' || 'returned' || 'failed' => AllineColors.error, _ => AllineColors.brightBlue };
  }
}
