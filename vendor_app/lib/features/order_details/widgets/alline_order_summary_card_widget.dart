import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/order/domain/models/order_model.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
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
  final double referAndEarnDiscount;
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
    this.referAndEarnDiscount = 0,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    if (order == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorResources.getBorder(context)),
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
                  color: ColorResources.getPrimary(context).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.receipt_long_rounded, color: ColorResources.getPrimary(context), size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                'ملخص الطلب',
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: ColorResources.getTextTitle(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(height: 1, color: ColorResources.getBorder(context)),
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

          if (referAndEarnDiscount > 0) ...[
            _buildSummaryRow(
              context,
              label: 'خصم الإحالة',
              amount: '- ${PriceConverter.convertPrice(context, referAndEarnDiscount)}',
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

          Divider(height: 16, color: ColorResources.getBorder(context)),

          // Grand Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإجمالي الصافي',
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: ColorResources.getTextTitle(context),
                ),
              ),
              Text(
                PriceConverter.convertPrice(context, totalPrice),
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge + 1,
                  color: ColorResources.getPrimary(context),
                ),
              ),
            ],
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
          color: ColorResources.getTextSubTitle(context),
          ),
        ),
        Text(
          amount,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeSmall,
          color: isNegative ? ColorResources.getError(context) : ColorResources.getTextTitle(context),
          ),
        ),
      ],
    );
  }
}
