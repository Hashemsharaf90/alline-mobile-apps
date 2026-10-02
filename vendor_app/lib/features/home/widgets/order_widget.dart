import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/order/domain/models/order_model.dart';
import 'package:sixvalley_vendor_app/features/order_details/screens/order_details_screen.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

class OrderWidget extends StatelessWidget {
  final Order orderModel;
  final int? index;
  const OrderWidget({super.key, required this.orderModel, this.index});

  @override
  Widget build(BuildContext context) {
    final isDark =
        Provider.of<ThemeController>(context, listen: false).darkTheme;

    // Calculate order amount for POS vs regular orders
    double orderAmount = orderModel.orderAmount ?? 0;
    if (orderModel.orderType == 'POS') {
      double itemsPrice = 0;
      double discount = 0;
      double? eeDiscount = 0;
      double tax = 0;
      double coupon = 0;
      double shipping = 0;
      if (orderModel.orderDetails != null &&
          orderModel.orderDetails!.isNotEmpty) {
        coupon = orderModel.discountAmount ?? 0;
        shipping = orderModel.shippingCost ?? 0;
        for (var details in orderModel.orderDetails!) {
          itemsPrice += (details.price ?? 0) * (details.qty ?? 0);
          discount += details.discount ?? 0;
          tax += details.tax ?? 0;
        }
        if (orderModel.extraDiscountType == 'percent') {
          eeDiscount = itemsPrice * ((orderModel.extraDiscount ?? 0) / 100);
        } else {
          eeDiscount = orderModel.extraDiscount;
        }
      }
      double subTotal = itemsPrice + tax - discount;
      orderAmount = subTotal + shipping - coupon - (eeDiscount ?? 0);
    }

    // Status visual mapping (Soft Status Badges)
    final (statusLabel, statusColor, statusBg) = switch (orderModel.orderStatus) {
      'pending' => ('جديد', AllineColors.orange, const Color(0xFFFFF7ED)),
      'confirmed' => ('مؤكد', AllineColors.primary, const Color(0xFFEFF6FF)),
      'processing' => ('قيد التجهيز', AllineColors.warning, const Color(0xFFFFFBEB)),
      'out_for_delivery' => ('قيد التوصيل', const Color(0xFF7C3AED), const Color(0xFFF5F3FF)),
      'delivered' => ('مكتمل', AllineColors.success, const Color(0xFFECFDF5)),
      'canceled' || 'cancelled' => ('ملغي', AllineColors.danger, const Color(0xFFFEF2F2)),
      'returned' => ('مرتجع', const Color(0xFFD97706), const Color(0xFFFFF7ED)),
      'failed' => ('فشل التسليم', AllineColors.danger, const Color(0xFFFEF2F2)),
      _ => (orderModel.orderStatus ?? 'غير معروف', AllineColors.coolGray, const Color(0xFFF8FAFC)),
    };

    // Order type badge
    String? orderTypeLabel;
    if (orderModel.orderType == 'POS') {
      orderTypeLabel = 'نقطة بيع POS';
    } else if (orderModel.orderType == 'supermarket' ||
        orderModel.shippingResponsibility != 'sellerwise_shipping') {
      orderTypeLabel = 'Alline Express';
    }

    // Customer name resolution
    String customerName = '';
    if (orderModel.customer != null) {
      customerName =
          '${orderModel.customer?.fName ?? ''} ${orderModel.customer?.lName ?? ''}'
              .trim();
    }
    if (customerName.isEmpty) {
      customerName =
          (orderModel.isGuest ?? false) ? 'عميل زائر' : 'عميل Alline';
    }

    // Payment method
    String paymentMethodName = '';
    if (orderModel.paymentMethod == 'cash_on_delivery') {
      paymentMethodName = 'عند الاستلام';
    } else if (orderModel.paymentMethod == 'pay_by_wallet') {
      paymentMethodName = 'المحفظة';
    } else if (orderModel.paymentMethod != null &&
        orderModel.paymentMethod!.isNotEmpty) {
      paymentMethodName =
          getTranslated(orderModel.paymentMethod, context) ??
              orderModel.paymentMethod!;
    }

    // Payment status badge (Distinct from order status!)
    final isPaid = orderModel.paymentStatus == 'paid';
    final (paymentStatusLabel, paymentColor, paymentBg) = isPaid
        ? ('✓ مدفوع', AllineColors.success, const Color(0xFFECFDF5))
        : orderModel.paymentMethod == 'cash_on_delivery'
            ? ('💵 عند الاستلام', AllineColors.navyText, const Color(0xFFF1F5F9))
            : ('غير مدفوع', AllineColors.danger, const Color(0xFFFEF2F2));

    // Date
    String dateStr = '';
    if (orderModel.createdAt != null) {
      try {
        dateStr = DateConverter.localDateToIsoStringAMPM(
            DateTime.parse(orderModel.createdAt!));
      } catch (_) {
        dateStr = orderModel.createdAt!;
      }
    }

    final int itemsCount = orderModel.orderDetails?.length ?? 0;
    final bool isActionNeeded = orderModel.orderStatus == 'pending';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailsScreen(orderId: orderModel.id),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? Theme.of(context).dividerColor
                    : (isActionNeeded
                        ? AllineColors.orange.withValues(alpha: 0.35)
                        : AllineColors.border),
                width: isActionNeeded ? 1.2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.transparent
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Order ID + Status Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'طلب #${orderModel.id}',
                          style: TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: ColorResources.getTextTitle(context),
                          ),
                        ),
                        if (orderTypeLabel != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AllineColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              orderTypeLabel,
                              style: const TextStyle(
                                fontFamily: 'AllineTajawal',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AllineColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Soft Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              fontFamily: 'AllineTajawal',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Priority Action Needed Strip
                if (isActionNeeded) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFEDD5)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            size: 16, color: AllineColors.orange),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'هذا الطلب يحتاج إلى تأكيدك للبدء في التجهيز',
                            style: TextStyle(
                              fontFamily: 'AllineTajawal',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFC2410C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // Middle: Customer Info + Date + Items Count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'AllineTajawal',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: ColorResources.getTextTitle(context),
                            ),
                          ),
                          if (dateStr.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              dateStr,
                              style: TextStyle(
                                fontFamily: 'AllineTajawal',
                                fontSize: 11,
                                color: ColorResources.getTextSubTitle(context),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (itemsCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white10
                              : AllineColors.backgroundLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$itemsCount منتجات',
                          style: TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: ColorResources.getTextSubTitle(context),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 10),
                Divider(
                  height: 1,
                  color: isDark
                      ? Theme.of(context).dividerColor
                      : AllineColors.border,
                ),
                const SizedBox(height: 10),

                // Bottom Row: Price + Payment Status + Action Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price & Payment Badge
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          PriceConverter.convertPrice(context, orderAmount),
                          style: const TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: AllineColors.primary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: paymentBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            paymentStatusLabel,
                            style: TextStyle(
                              fontFamily: 'AllineTajawal',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: paymentColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Quick Action Button
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActionNeeded
                            ? AllineColors.primary
                            : AllineColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isActionNeeded ? 'مراجعة الطلب' : 'عرض الطلب',
                            style: TextStyle(
                              fontFamily: 'AllineTajawal',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isActionNeeded
                                  ? Colors.white
                                  : AllineColors.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_left_rounded,
                            size: 16,
                            color: isActionNeeded
                                ? Colors.white
                                : AllineColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
