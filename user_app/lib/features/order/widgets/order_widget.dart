import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_status_colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/order/domain/models/order_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/date_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:provider/provider.dart';

class OrderWidget extends StatefulWidget {
  final Orders? orderModel;
  const OrderWidget({super.key, this.orderModel});

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  final tooltipController = JustTheController();

  @override
  Widget build(BuildContext context) {
    if (widget.orderModel == null) return const SizedBox.shrink();

    final isDark =
        Provider.of<ThemeController>(context, listen: false).darkTheme;
    final isLtr =
        Provider.of<LocalizationController>(context, listen: false).isLtr;

    // Calculate total order amount
    double orderAmount = widget.orderModel!.orderAmount ?? 0;
    if (widget.orderModel?.orderType == 'POS') {
      double itemsPrice = 0;
      double discount = 0;
      double? eeDiscount = 0;
      double coupon = widget.orderModel?.discountAmount ?? 0;
      double shipping = widget.orderModel?.shippingCost ?? 0;
      double tax = widget.orderModel?.totalTaxAmount ?? 0;

      if (widget.orderModel?.details != null &&
          widget.orderModel!.details!.isNotEmpty) {
        for (var orderDetails in widget.orderModel!.details!) {
          itemsPrice += (orderDetails.price ?? 0) * (orderDetails.qty ?? 0);
          discount += orderDetails.discount ?? 0;
        }
        if (widget.orderModel!.extraDiscountType == 'percent') {
          eeDiscount =
              itemsPrice * ((widget.orderModel!.extraDiscount ?? 0) / 100);
        } else {
          eeDiscount = widget.orderModel!.extraDiscount ?? 0;
        }
      }
      double subTotal = itemsPrice + tax - discount;
      orderAmount = subTotal + shipping - coupon - eeDiscount;
    }

    final String orderStatus =
        widget.orderModel?.orderStatus?.toLowerCase() ?? 'pending';
    final bool isOngoing = [
      'pending',
      'confirmed',
      'processing',
      'out_for_delivery'
    ].contains(orderStatus);
    final bool isDelivered = orderStatus == 'delivered';

    final statusStyle = AllineStatusColors.order(context, orderStatus);
    final typeBadge = _getTypeBadge();

    // Store name determination
    final String storeName = widget.orderModel?.sellerIs == 'admin'
        ? (Provider.of<SplashController>(context, listen: false)
                .configModel
                ?.inHouseShop
                ?.name ??
            'Alline Express')
        : (widget.orderModel?.seller?.shop?.name ?? 'Alline Store');

    final details = widget.orderModel?.details ?? [];
    final int totalCount = widget.orderModel?.orderDetailsCount ??
        (details.isNotEmpty ? details.length : 1);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Theme.of(context).dividerColor.withValues(alpha: 0.1)
              : const Color(0xFFE1E8F2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF071B49).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            RouterHelper.getOrderDetailsScreenRoute(
              action: RouteAction.push,
              orderId: widget.orderModel!.id!,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Row: Type Badge + Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Order Type Badge (Local, Supermarket, Global)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: typeBadge.bgColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: typeBadge.borderColor, width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            typeBadge.emoji,
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            typeBadge.title,
                            style: titilliumBold.copyWith(
                              fontSize: 11,
                              color: typeBadge.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Order Status Badge with Dot
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusStyle.background,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: statusStyle.foreground,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getLocalizedStatus(orderStatus, context),
                            style: titilliumBold.copyWith(
                              fontSize: 11,
                              color: statusStyle.foreground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 2. Order ID, Quick Copy, and Date
                Row(
                  children: [
                    Text(
                      '#ALN-${widget.orderModel?.id ?? ''}',
                      style: titilliumBold.copyWith(
                        fontSize: 15,
                        color: isDark ? Colors.white : const Color(0xFF071B49),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(
                            text: '#ALN-${widget.orderModel?.id ?? ''}'));
                        showCustomSnackBar(
                          isLtr
                              ? 'Order ID copied to clipboard'
                              : 'تم نسخ رقم الطلب بنجاح',
                          context,
                          isError: false,
                        );
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.copy_rounded,
                          size: 14,
                          color: const Color(0xFF6D85AF).withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    if (widget.orderModel?.editedStatus == 1) ...[
                      const SizedBox(width: 4),
                      Text(
                        '(${getTranslated('edited', context)})',
                        style: textMedium.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: Dimensions.fontSizeExtraSmall,
                        ),
                      ),
                      if ((widget.orderModel?.editDueAmount ?? 0) > 0 ||
                          (widget.orderModel?.editReturnAmount ?? 0) > 0)
                        JustTheTooltip(
                          backgroundColor: Colors.black87,
                          controller: tooltipController,
                          preferredDirection: AxisDirection.up,
                          tailLength: 10,
                          tailBaseWidth: 20,
                          content: Container(
                            width: 250,
                            padding: const EdgeInsets.all(
                                Dimensions.paddingSizeSmall),
                            child: Text(
                              (widget.orderModel?.editDueAmount ?? 0) > 0
                                  ? getTranslated(
                                      'you_will_pay_due_the_amount', context)!
                                  : getTranslated(
                                      'admin_return_the_excess_amount_to_you',
                                      context)!,
                              style: titleRegular.copyWith(
                                  color: Colors.white,
                                  fontSize: Dimensions.fontSizeDefault),
                            ),
                          ),
                          child: InkWell(
                            onTap: () => tooltipController.showTooltip(),
                            child: CustomAssetImageWidget(
                              (widget.orderModel?.editDueAmount ?? 0) > 0
                                  ? Images.orderDueAmountIcon
                                  : Images.orderReturnAmountIcon,
                              height: 14,
                              width: 14,
                            ),
                          ),
                        ),
                    ],
                    const Spacer(),
                    // Formatted Date
                    if (widget.orderModel?.createdAt != null)
                      Text(
                        DateConverter.localDateToIsoStringAMPMOrder(
                          DateTime.parse(widget.orderModel!.createdAt!),
                        ),
                        style: titilliumRegular.copyWith(
                          fontSize: 11,
                          color: const Color(0xFF6D85AF),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 6),

                // 3. Store Name Row
                Row(
                  children: [
                    const Icon(
                      Icons.storefront_outlined,
                      size: 14,
                      color: Color(0xFF6D85AF),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      storeName,
                      style: textMedium.copyWith(
                        fontSize: 12,
                        color: const Color(0xFF6D85AF),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 4. Product Thumbnails Preview Row
                if (details.isNotEmpty)
                  Row(
                    children: [
                      // Display up to 3 thumbnails
                      ...details.take(3).map((detail) {
                        final String? imgUrl =
                            detail.product?.thumbnailFullUrl?.path;
                        return Container(
                          width: 48,
                          height: 48,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFE1E8F2),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: CustomImageWidget(
                              image: imgUrl ?? '',
                              fit: BoxFit.cover,
                              placeholder: Images.placeholder,
                            ),
                          ),
                        );
                      }),

                      // If > 3 products, show +N overflow container
                      if (details.length > 3)
                        Container(
                          width: 48,
                          height: 48,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: AllineColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color:
                                  AllineColors.primary.withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '+${details.length - 3}',
                            style: titilliumBold.copyWith(
                              fontSize: 13,
                              color: AllineColors.primary,
                            ),
                          ),
                        ),
                    ],
                  )
                else
                  // Fallback store logo/icon if details are not populated
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE1E8F2)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: CustomImageWidget(
                        image: widget.orderModel?.sellerIs == 'admin'
                            ? Provider.of<SplashController>(context,
                                        listen: false)
                                    .configModel
                                    ?.inHouseShop
                                    ?.imageFullUrl
                                    ?.path ??
                                ''
                            : (widget.orderModel?.seller?.shop?.imageFullUrl
                                    ?.path ??
                                ''),
                        fit: BoxFit.cover,
                        placeholder: Images.placeholder,
                      ),
                    ),
                  ),

                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: isDark
                      ? Theme.of(context).dividerColor.withValues(alpha: 0.08)
                      : const Color(0xFFF0F4FA),
                ),
                const SizedBox(height: 12),

                // 5. Bottom Row: Price & Products Count + Primary CTA Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Price & Count
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$totalCount ${totalCount == 1 ? (isLtr ? 'product' : 'منتج واحد') : (isLtr ? 'products' : 'منتجات')}',
                          style: titilliumRegular.copyWith(
                            fontSize: 11,
                            color: const Color(0xFF6D85AF),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              isLtr ? 'Total: ' : 'الإجمالي: ',
                              style: titilliumRegular.copyWith(
                                fontSize: 12,
                                color: const Color(0xFF6D85AF),
                              ),
                            ),
                            Text(
                              PriceConverter.convertPrice(context, orderAmount),
                              style: titilliumBold.copyWith(
                                fontSize: 15,
                                color: AllineColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Primary CTA Button
                    if (isOngoing)
                      ElevatedButton.icon(
                        onPressed: () {
                          RouterHelper.getOrderDetailsScreenRoute(
                            action: RouteAction.push,
                            orderId: widget.orderModel!.id!,
                          );
                        },
                        icon: const Icon(Icons.two_wheeler_rounded,
                            size: 16, color: Colors.white),
                        label: Text(
                          isLtr ? 'Track Order' : 'تتبع الطلب',
                          style: titilliumBold.copyWith(
                              fontSize: 12, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AllineColors.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          minimumSize: const Size(0, 36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      )
                    else if (isDelivered)
                      OutlinedButton.icon(
                        onPressed: () {
                          RouterHelper.getOrderDetailsScreenRoute(
                            action: RouteAction.push,
                            orderId: widget.orderModel!.id!,
                          );
                        },
                        icon: const Icon(Icons.receipt_long_outlined,
                            size: 15, color: AllineColors.primary),
                        label: Text(
                          isLtr ? 'View Details' : 'عرض التفاصيل',
                          style: titilliumBold.copyWith(
                              fontSize: 12, color: AllineColors.primary),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor:
                              AllineColors.primary.withValues(alpha: 0.05),
                          side: const BorderSide(
                              color: AllineColors.primary, width: 1),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          minimumSize: const Size(0, 36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      )
                    else
                      OutlinedButton(
                        onPressed: () {
                          RouterHelper.getOrderDetailsScreenRoute(
                            action: RouteAction.push,
                            orderId: widget.orderModel!.id!,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isDark
                              ? Colors.transparent
                              : const Color(0xFFF8FAFC),
                          side: BorderSide(
                            color: isDark
                                ? Theme.of(context).dividerColor
                                : const Color(0xFFE1E8F2),
                            width: 1,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          minimumSize: const Size(0, 36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          isLtr ? 'Order Details' : 'تفاصيل الطلب',
                          style: textMedium.copyWith(
                            fontSize: 12,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF071B49),
                          ),
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

  // Helper to determine type badge
  _TypeBadgeData _getTypeBadge() {
    final type = widget.orderModel?.orderType?.toLowerCase() ?? '';
    final shopName = widget.orderModel?.seller?.shop?.name?.toLowerCase() ?? '';

    if (type == 'global_shopping' || type == 'global') {
      return _TypeBadgeData(
        emoji: '🌍',
        title: 'تسوق عالمي',
        bgColor: const Color(0xFFF3E8FF),
        borderColor: const Color(0xFFE9D5FF),
        textColor: const Color(0xFF7C3AED),
      );
    } else if (type == 'supermarket' ||
        shopName.contains('سوبر') ||
        shopName.contains('ماركت') ||
        shopName.contains('بقالة')) {
      return _TypeBadgeData(
        emoji: '🛒',
        title: 'سوبر ماركت',
        bgColor: const Color(0xFFEAF8F0),
        borderColor: const Color(0xFFD1FAE5),
        textColor: AllineColors.success,
      );
    } else {
      return _TypeBadgeData(
        emoji: '🛍️',
        title: 'محلي',
        bgColor: const Color(0xFFF0F4FA),
        borderColor: const Color(0xFFE1E8F2),
        textColor: AllineColors.primaryDark,
      );
    }
  }

  // Localized status text helper
  String _getLocalizedStatus(String status, BuildContext context) {
    switch (status) {
      case 'pending':
        return 'قيد المراجعة';
      case 'confirmed':
        return 'تم التأكيد';
      case 'processing':
        return 'جاري التجهيز';
      case 'out_for_delivery':
        return 'قيد التوصيل';
      case 'delivered':
        return 'تم التسليم';
      case 'canceled':
        return 'ملغي';
      case 'failed':
        return 'فشل الطلب';
      case 'returned':
        return 'مرتجع';
      default:
        return getTranslated(status, context) ?? status;
    }
  }
}

class _TypeBadgeData {
  final String emoji;
  final String title;
  final Color bgColor;
  final Color borderColor;
  final Color textColor;
  _TypeBadgeData({
    required this.emoji,
    required this.title,
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
  });
}
