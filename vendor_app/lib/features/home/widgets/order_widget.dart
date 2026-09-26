import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/features/order/domain/models/order_model.dart';
import 'package:sixvalley_vendor_app/features/order_details/screens/order_details_screen.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class OrderWidget extends StatefulWidget {
  final Order orderModel;
  final int? index;
  const OrderWidget({super.key, required this.orderModel, this.index});

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  final tooltipController = JustTheController();

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeController>(context, listen: false).darkTheme;

    // Calculate order amount for POS vs regular orders
    double orderAmount = widget.orderModel.orderAmount ?? 0;
    if (widget.orderModel.orderType == 'POS') {
      double itemsPrice = 0;
      double discount = 0;
      double? eeDiscount = 0;
      double tax = 0;
      double coupon = 0;
      double shipping = 0;
      if (widget.orderModel.orderDetails != null && widget.orderModel.orderDetails!.isNotEmpty) {
        coupon = widget.orderModel.discountAmount ?? 0;
        shipping = widget.orderModel.shippingCost ?? 0;
        for (var orderDetails in widget.orderModel.orderDetails!) {
          itemsPrice += (orderDetails.price ?? 0) * (orderDetails.qty ?? 0);
          discount += orderDetails.discount ?? 0;
          tax += orderDetails.tax ?? 0;
        }
        if (widget.orderModel.extraDiscountType == 'percent') {
          eeDiscount = itemsPrice * ((widget.orderModel.extraDiscount ?? 0) / 100);
        } else {
          eeDiscount = widget.orderModel.extraDiscount;
        }
      }
      double subTotal = itemsPrice + tax - discount;
      orderAmount = subTotal + shipping - coupon - (eeDiscount ?? 0);
    }

    // Status visual mapping
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (widget.orderModel.orderStatus) {
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

    // Order type badge
    String orderTypeLabel = 'متجر محلي';
    if (widget.orderModel.orderType == 'POS') {
      orderTypeLabel = 'نقطة بيع POS';
    } else if (widget.orderModel.orderType == 'supermarket' || widget.orderModel.shippingResponsibility != 'sellerwise_shipping') {
      orderTypeLabel = 'Alline';
    }

    // Customer name resolution
    String customerName = '';
    if (widget.orderModel.customer != null) {
      customerName = '${widget.orderModel.customer?.fName ?? ''} ${widget.orderModel.customer?.lName ?? ''}'.trim();
    }
    if (customerName.isEmpty) {
      customerName = (widget.orderModel.isGuest ?? false) ? 'عميل زائر' : 'العميل';
    }

    // Payment method
    String paymentMethodName = '';
    if (widget.orderModel.paymentMethod == 'cash_on_delivery') {
      paymentMethodName = 'الدفع عند الاستلام';
    } else if (widget.orderModel.paymentMethod == 'pay_by_wallet') {
      paymentMethodName = 'المحفظة';
    } else if (widget.orderModel.paymentMethod != null && widget.orderModel.paymentMethod!.isNotEmpty) {
      paymentMethodName = getTranslated(widget.orderModel.paymentMethod, context) ?? widget.orderModel.paymentMethod!;
    }

    // Payment status badge
    final isPaid = widget.orderModel.paymentStatus == 'paid';
    final paymentStatusLabel = isPaid ? 'مدفوع' : 'غير مدفوع';

    // Date
    String dateStr = '';
    if (widget.orderModel.createdAt != null) {
      try {
        dateStr = DateConverter.localDateToIsoStringAMPM(DateTime.parse(widget.orderModel.createdAt!));
      } catch (_) {
        dateStr = widget.orderModel.createdAt!;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailsScreen(orderId: widget.orderModel.id),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Theme.of(context).dividerColor : AllineColors.borderLight,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.transparent : Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Order ID + Tag + Status Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          '#${widget.orderModel.id}',
                          style: robotoBold.copyWith(
                            fontSize: 16,
                            color: AllineColors.textDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AllineColors.backgroundLight,
                            borderRadius: BorderRadius.circular(6),
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
                        if (widget.orderModel.editedStatus == 1) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AllineColors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'مُعدّل',
                              style: robotoMedium.copyWith(
                                fontSize: 10,
                                color: AllineColors.orange,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, color: statusColor, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            statusLabel,
                            style: robotoBold.copyWith(
                              fontSize: 11,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Divider(height: 1, color: AllineColors.borderLight),
                const SizedBox(height: 10),

                // Middle: Customer Info + Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Customer Name
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.person_outline_rounded, size: 15, color: AllineColors.textLight),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              customerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: robotoMedium.copyWith(
                                fontSize: 13,
                                color: AllineColors.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Date & Time
                    if (dateStr.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 13, color: AllineColors.textLight),
                          const SizedBox(width: 4),
                          Text(
                            dateStr,
                            style: robotoRegular.copyWith(
                              fontSize: 11,
                              color: AllineColors.textLight,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                // Bottom Row: Payment & Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Payment Method & Status Badges
                    Row(
                      children: [
                        if (paymentMethodName.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AllineColors.backgroundLight,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AllineColors.borderLight),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  height: 12,
                                  width: 12,
                                  child: CustomAssetImageWidget(
                                    widget.orderModel.paymentMethod == 'cash_on_delivery'
                                        ? Images.paymentIcon
                                        : widget.orderModel.paymentMethod == 'pay_by_wallet'
                                            ? Images.payByWalletIcon
                                            : Images.digitalPaymentIcon,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  paymentMethodName,
                                  style: robotoRegular.copyWith(
                                    fontSize: 11,
                                    color: AllineColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],

                        // Payment Status Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isPaid
                                ? AllineColors.success.withValues(alpha: 0.1)
                                : AllineColors.danger.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            paymentStatusLabel,
                            style: robotoMedium.copyWith(
                              fontSize: 10,
                              color: isPaid ? AllineColors.success : AllineColors.danger,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Order Amount in YER
                    Text(
                      PriceConverter.convertPrice(context, orderAmount),
                      style: robotoBold.copyWith(
                        fontSize: 16,
                        color: AllineColors.primary,
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
