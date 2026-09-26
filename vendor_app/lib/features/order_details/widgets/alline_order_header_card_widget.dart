import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/order/domain/models/order_model.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class AllineOrderHeaderCardWidget extends StatelessWidget {
  final Order? order;
  const AllineOrderHeaderCardWidget({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    if (order == null) return const SizedBox.shrink();

    final status = order!.orderStatus?.toLowerCase() ?? 'pending';
    final paymentStatus = order!.paymentStatus?.toLowerCase() ?? 'unpaid';

    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (status) {
      case 'confirmed':
        statusColor = AllineColors.secondary;
        statusLabel = 'تم التأكيد';
        statusIcon = Icons.check_circle_outline_rounded;
        break;
      case 'processing':
        statusColor = const Color(0xFFF59E0B);
        statusLabel = 'قيد التجهيز';
        statusIcon = Icons.inventory_2_outlined;
        break;
      case 'out_for_delivery':
        statusColor = const Color(0xFF0284C7);
        statusLabel = 'خرج للتوصيل';
        statusIcon = Icons.two_wheeler_rounded;
        break;
      case 'delivered':
        statusColor = AllineColors.success;
        statusLabel = 'تم التسليم';
        statusIcon = Icons.task_alt_rounded;
        break;
      case 'canceled':
      case 'cancelled':
        statusColor = AllineColors.danger;
        statusLabel = 'ملغي';
        statusIcon = Icons.cancel_rounded;
        break;
      case 'returned':
        statusColor = const Color(0xFFD97706);
        statusLabel = 'مرتجع';
        statusIcon = Icons.assignment_return_rounded;
        break;
      case 'failed':
        statusColor = AllineColors.danger;
        statusLabel = 'فشل التسليم';
        statusIcon = Icons.error_outline_rounded;
        break;
      default:
        statusColor = AllineColors.orange;
        statusLabel = 'طلب جديد';
        statusIcon = Icons.fiber_new_rounded;
    }

    String orderTypeLabel = 'طلب متجر محلي';
    if (order!.orderType == 'POS') {
      orderTypeLabel = 'نقطة بيع POS';
    } else if (order!.orderType == 'supermarket' || (order!.shippingResponsibility != 'sellerwise_shipping')) {
      orderTypeLabel = 'طلب Alline';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AllineColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Order Number
              Row(
                children: [
                  Text(
                    'طلب #${order!.id}',
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge + 1,
                      color: AllineColors.textDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AllineColors.backgroundLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AllineColors.borderLight),
                    ),
                    child: Text(
                      orderTypeLabel,
                      style: robotoRegular.copyWith(
                        fontSize: 10,
                        color: AllineColors.textLight,
                      ),
                    ),
                  ),
                ],
              ),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: robotoBold.copyWith(
                        color: statusColor,
                        fontSize: Dimensions.fontSizeSmall - 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AllineColors.borderLight),
          const SizedBox(height: 12),

          // Date and Payment Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Order Date & Time
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 15, color: AllineColors.textLight),
                  const SizedBox(width: 5),
                  Text(
                    order!.createdAt != null
                        ? DateConverter.localDateToIsoStringAMPM(DateTime.parse(order!.createdAt!))
                        : '',
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: AllineColors.textLight,
                    ),
                  ),
                ],
              ),

              // Payment Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: paymentStatus == 'paid'
                      ? AllineColors.success.withValues(alpha: 0.1)
                      : AllineColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  paymentStatus == 'paid' ? 'مدفوع 🟢' : 'غير مدفوع 🔴',
                  style: robotoBold.copyWith(
                    fontSize: 11,
                    color: paymentStatus == 'paid' ? AllineColors.success : AllineColors.danger,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
