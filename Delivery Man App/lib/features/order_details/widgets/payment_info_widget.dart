import 'package:flutter/material.dart';
import 'package:sixvalley_delivery_boy/features/order_details/widgets/payment_status_widget.dart';
import 'package:sixvalley_delivery_boy/theme/controllers/theme_controller.dart';
import 'package:sixvalley_delivery_boy/utill/dimensions.dart';
import 'package:sixvalley_delivery_boy/utill/images.dart';
import 'package:sixvalley_delivery_boy/utill/styles.dart';
import 'package:sixvalley_delivery_boy/features/order/widgets/order_item_info_widget.dart';
import 'package:get/get.dart';


class PaymentInfoWidget extends StatelessWidget {
  final double? itemsPrice;
  final double? discount;
  final double? tax;
  final double? subTotal;
  final double? deliveryCharge;
  final double? totalPrice;
  final double? referAndEarnDiscount;
  final double? paidAmount;
  final double? dueAmount;
  final String paymentStatus;

  const PaymentInfoWidget({super.key, this.itemsPrice, this.discount, this.tax, this.subTotal, this.deliveryCharge, this.totalPrice, this.paymentStatus = '', this.referAndEarnDiscount, this.paidAmount, this.dueAmount});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding:  EdgeInsets.symmetric(horizontal:Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeMin),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [BoxShadow(color: Get.find<ThemeController>().darkTheme ? Colors.black.withValues(alpha:0.10) : Colors.grey[100]!,
            blurRadius: 5, spreadRadius: 1,)],
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
        ),
        child: Column(children: [

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
            Row(children: [
              SizedBox(width: 20, child: Image.asset(Images.orderInfo)),
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeDefault),
                child: Text('payment_info'.tr,style: rubikMedium.copyWith(
                    color: Get.isDarkMode? Theme.of(context).hintColor.withValues(alpha:.5) :
                    Theme.of(context).primaryColor,fontSize: Dimensions.fontSizeLarge),
                ),
              ),
            ]),

            PaymentStatusWidget(isPaid: paymentStatus),
          ]),


          Column(children: [
            OrderItemInfoWidget(title: 'product_price',info: itemsPrice.toString(), isPrice: true, isCount: false),

            OrderItemInfoWidget(title: 'discount',info: discount.toString(), isPrice: true),

            if(referAndEarnDiscount != null && (referAndEarnDiscount ?? 0) > 0)
            OrderItemInfoWidget(title: 'referral_discount',info: referAndEarnDiscount.toString(), isPrice: true),

            OrderItemInfoWidget(title: 'tax',info: tax.toString(), isPrice: true),

            OrderItemInfoWidget(title: 'delivery_cost',info: deliveryCharge.toString(), isPrice: true),

            Divider(height: .0725, color: Theme.of(context).hintColor.withValues(alpha: .5)),

            OrderItemInfoWidget(
              title: 'total',
              titleTextStyle: rubikRegular.copyWith(
                color: Get.isDarkMode ? Theme.of(context).hintColor : Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: Dimensions.fontSizeDefault,
              ),
              textStyle: rubikBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color),
              info: subTotal.toString(),
              isPrice: true,
            ),


            if((dueAmount ?? 0) > 0)
            OrderItemInfoWidget(
              title: 'paid_amount',
              titleTextStyle: rubikRegular.copyWith(
                color: Get.isDarkMode ? Theme.of(context).hintColor : Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: Dimensions.fontSizeDefault,
              ),
              textStyle: rubikRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color),
              info: paidAmount.toString(),
              isPrice: true,
            ),


            if((dueAmount ?? 0) > 0)
              OrderItemInfoWidget(
                title: 'due_amount',
                titleTextStyle: rubikBold.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: Dimensions.fontSizeDefault,
                ),
                textStyle: rubikBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).colorScheme.error
                ),
                info: dueAmount.toString(),
                isPrice: true,
              ),


          ]),

          if(paymentStatus == 'partially_paid' || paymentStatus == 'unpaid')
            Container(
              width: MediaQuery.sizeOf(context).width,
              padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMin, vertical: Dimensions.paddingSizeChat),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeMin),
              ),
              child: Text('make_sure_to_collect_cash_before_handover_the_product'.tr, style: rubikRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.80),
              ), textAlign: TextAlign.center),
            ),

          SizedBox(height: Dimensions.paddingSizeChat),

        ]),
    );
  }
}
