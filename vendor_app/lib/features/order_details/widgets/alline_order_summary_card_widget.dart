import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/order/domain/models/order_model.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class AllineOrderSummaryCardWidget extends StatelessWidget {
  final Order? order;
  final double itemsPrice;
  final double discount;
  final double tax;
  final double shipping;
  final double coupon;
  final double extraDiscount;
  final double totalPrice;

  const AllineOrderSummaryCardWidget({
    super.key,
    required this.order,
    required this.itemsPrice,
    required this.discount,
    required this.tax,
    required this.shipping,
    required this.coupon,
    required this.extraDiscount,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    if (order == null) return const SizedBox.shrink();

    String paymentMethodName = 'نقد عند الاستلام (COD)';
    if (order!.paymentMethod == 'pay_by_wallet') {
      paymentMethodName = 'محفظة Alline الإلكترونية';
    } else if (order!.paymentMethod != null && order!.paymentMethod != 'cash_on_delivery') {
      paymentMethodName = getTranslated(order!.paymentMethod ?? '', context) ?? order!.paymentMethod!;
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
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AllineColors.secondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.receipt_long_rounded, color: AllineColors.secondary, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                'الملخص المالي وطريقة الدفع',
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: AllineColors.textDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AllineColors.borderLight),
          const SizedBox(height: 12),

          // Subtotal
          _buildSummaryRow(
            context,
            label: 'مجموع الأصناف',
            amount: PriceConverter.convertPrice(context, itemsPrice),
          ),
          const SizedBox(height: 8),

          // Discount
          if (discount > 0) ...[
            _buildSummaryRow(
              context,
              label: 'خصم المنتجات',
              amount: '- ${PriceConverter.convertPrice(context, discount)}',
              isNegative: true,
            ),
            const SizedBox(height: 8),
          ],

          // Coupon
          if (coupon > 0) ...[
            _buildSummaryRow(
              context,
              label: 'خصم الكوبون',
              amount: '- ${PriceConverter.convertPrice(context, coupon)}',
              isNegative: true,
            ),
            const SizedBox(height: 8),
          ],

          // Extra POS Discount
          if (extraDiscount > 0) ...[
            _buildSummaryRow(
              context,
              label: 'خصم إضافي',
              amount: '- ${PriceConverter.convertPrice(context, extraDiscount)}',
              isNegative: true,
            ),
            const SizedBox(height: 8),
          ],

          // Delivery fee
          _buildSummaryRow(
            context,
            label: 'رسوم التوصيل',
            amount: (order!.isShippingFree ?? false)
                ? 'مجاني'
                : PriceConverter.convertPrice(context, shipping),
          ),
          const SizedBox(height: 8),

          // Tax
          if (tax > 0) ...[
            _buildSummaryRow(
              context,
              label: 'الضريبة المضافة',
              amount: PriceConverter.convertPrice(context, tax),
            ),
            const SizedBox(height: 8),
          ],

          const Divider(height: 16, color: AllineColors.borderLight),

          // Grand Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإجمالي الصافي',
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: AllineColors.textDark,
                ),
              ),
              Text(
                PriceConverter.convertPrice(context, totalPrice),
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge + 1,
                  color: AllineColors.secondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Payment method info box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AllineColors.backgroundLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AllineColors.borderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.payment_rounded, size: 18, color: AllineColors.secondary),
                    const SizedBox(width: 8),
                    Text(
                      paymentMethodName,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: AllineColors.textDark,
                      ),
                    ),
                  ],
                ),
                Text(
                  order!.paymentStatus == 'paid' ? 'مدفوع بالكامل ✅' : 'الدفع عند الاستلام',
                  style: robotoBold.copyWith(
                    fontSize: 10,
                    color: order!.paymentStatus == 'paid' ? AllineColors.success : AllineColors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required String label,
    required String amount,
    bool isNegative = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: AllineColors.textLight,
          ),
        ),
        Text(
          amount,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: isNegative ? AllineColors.danger : AllineColors.textDark,
          ),
        ),
      ],
    );
  }
}
