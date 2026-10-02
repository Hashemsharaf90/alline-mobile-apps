import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/features/notification/domain/models/notifications_model.dart';
import 'package:sixvalley_delivery_boy/features/order/domain/models/order_model.dart';
import 'package:sixvalley_delivery_boy/features/order_details/screens/order_details_screen.dart';

class NotificationCardWidget extends StatelessWidget {
  final Notifications? notificationModel;
  final bool addTitle, isSeen;
  final int index;
  const NotificationCardWidget(
      {super.key,
      this.notificationModel,
      this.addTitle = false,
      required this.index,
      this.isSeen = false});
  @override
  Widget build(BuildContext context) {
    final notification = notificationModel;
    if (notification == null) return const SizedBox.shrink();
    return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Icon(
                notification.orderId != null
                    ? Icons.local_shipping_outlined
                    : Icons.notifications_outlined,
                color: Theme.of(context).colorScheme.primary),
            title: Text(
                notification.orderId != null
                    ? '${'order'.tr} #${notification.orderId}'
                    : 'notification'.tr,
                style: Theme.of(context).textTheme.titleSmall),
            subtitle:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(notification.description ?? ''),
              if (notification.createdAt != null) ...[
                const SizedBox(height: 8),
                Text(notification.createdAt!,
                    style: Theme.of(context).textTheme.bodySmall)
              ]
            ]),
            onTap: notification.orderId == null
                ? null
                : () => Get.to(() => OrderDetailsScreen(
                    orderModel: OrderModel(id: notification.orderId),
                    fromNotification: false))));
  }
}
