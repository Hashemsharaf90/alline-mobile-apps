import 'package:sixvalley_delivery_boy/helper/driver_journey.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/alline/alline_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/features/order/domain/models/order_model.dart';
import 'package:sixvalley_delivery_boy/features/order_details/screens/order_details_screen.dart';
import 'package:sixvalley_delivery_boy/theme/alline/alline_typography.dart';
import 'package:sixvalley_delivery_boy/helper/date_converter.dart';

class AllineOrderHistoryItemWidget extends StatelessWidget {
  final OrderModel order;
  const AllineOrderHistoryItemWidget({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final currentStatus=DriverJourney.status(order);
    final statusLabel=order.isPause==true?'paused'.tr:DriverJourney.labelKey(currentStatus).tr;
    final statusColor=DriverJourney.color(currentStatus,paused:order.isPause==true);

    String customerName = order.isGuest == true 
      ? (order.billingAddress?.contactPersonName ?? 'guest_customer'.tr) 
      : (order.customer?.fName != null ? '${order.customer?.fName} ${order.customer?.lName ?? ''}' : 'guest_customer'.tr);

    return GestureDetector(
      onTap: () {
        Get.to(() => OrderDetailsScreen(orderModel: order, fromNotification: false));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(spacing:12,runSpacing:8,crossAxisAlignment:WrapCrossAlignment.center,children:[
              Text('${'order'.tr} #${order.id}',style:Theme.of(context).textTheme.titleMedium),
              AllineStatusBadge(label:statusLabel,color:statusColor),
            ]),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.storefront_rounded, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.seller?.shop?.name ?? 'store'.tr,
                    style: AllineTypography.body.copyWith(color: Theme.of(context).colorScheme.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_rounded, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    customerName,
                    style: AllineTypography.body.copyWith(color: Theme.of(context).colorScheme.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: Theme.of(context).colorScheme.outline, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  order.createdAt != null ? DateConverter.isoStringToLocalDateOnly(order.createdAt!) : '',
                  style: AllineTypography.caption.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
