import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_delivery_boy/features/order/domain/models/order_model.dart';
import 'package:sixvalley_delivery_boy/features/order_details/screens/order_details_screen.dart';
import 'package:sixvalley_delivery_boy/features/order_details/widgets/cal_chat_widget.dart';
import 'package:sixvalley_delivery_boy/helper/date_converter.dart';
import 'package:sixvalley_delivery_boy/utill/dimensions.dart';
import 'package:sixvalley_delivery_boy/utill/styles.dart';



// class OrderHistoryItemWidget extends StatelessWidget {
//   final OrderModel? orderModel;
//   const OrderHistoryItemWidget({super.key, this.orderModel});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => Get.to(OrderDetailsScreen(orderModel: orderModel, fromNotification: false,)),
//       child: Padding(padding:  EdgeInsets.only(left: Dimensions.paddingSizeSmall,
//           bottom : Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall),
//         child: Container(padding:  EdgeInsets.all(Dimensions.paddingSizeSmall),
//           decoration: BoxDecoration(color: Theme.of(context).cardColor,
//             boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha:.125),
//               spreadRadius: .7, blurRadius: 2, offset: const Offset(0, 1))],
//             borderRadius: BorderRadius.circular(10),
//           ),
//
//           child: Stack(children: [
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   Padding(padding:  EdgeInsets.only(left: 7,top: Dimensions.paddingSizeSmall),
//                     child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
//                       Expanded(child: Text('${'order'.tr} #${orderModel!.id}',
//                         style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge,
//                           color:  (
//                             Get.find<ThemeController>().darkTheme ?
//                             ColorHelper.blendColors(Colors.white, Theme.of(context).primaryColor, 0.9):
//                             ColorHelper.darken(Theme.of(context).primaryColor, 0.1)
//                           )),
//                       )),
//
//                       CallAndChatWidget(orderModel: orderModel),
//                     ]),
//                   ),
//
//
//                 Padding(padding:  EdgeInsets.fromLTRB( Dimensions.paddingSizeDefault,
//                     Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, 0),
//                   child: CustomerInfoWidget(orderModel: orderModel, showCustomerImage: true),
//                 ),
//
//                 Padding(padding:  EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
//                   child: Column(children: [
//                     Row(children: [
//
//                       SizedBox(width: Dimensions.iconSizeDefault, child: Image.asset(Images.calenderIcon,
//                           color: Get.find<ThemeController>().darkTheme ?Theme.of(context).hintColor.withValues(alpha:.5) :Theme.of(context).primaryColor.withValues(alpha:.5))),
//                       SizedBox(width: Dimensions.paddingSizeSmall),
//
//                       Text('${'assigned'.tr} : ',style: rubikRegular.copyWith(
//                           color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),),
//                       Text(DateConverter.isoStringToLocalDateOnly(orderModel!.createdAt!),
//                         style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Get.isDarkMode ? Theme.of(context).hintColor : Colors.black),
//                       ),
//                     ]),
//
//
//                     orderModel!.expectedDate != null?
//                     Padding(padding:  EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
//                       child: Row(children: [
//                         SizedBox(width: Dimensions.iconSizeDefault, child: Image.asset(Images.calenderIcon,
//                             color: Get.find<ThemeController>().darkTheme ?Theme.of(context).hintColor.withValues(alpha:.5) :Theme.of(context).primaryColor.withValues(alpha:.5))),
//                         SizedBox(width: Dimensions.paddingSizeSmall),
//                         Text('${'expected_date'.tr} : ',
//                           style: rubikRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),),
//                         Text(orderModel!.expectedDate!, style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Get.isDarkMode ? Theme.of(context).hintColor : Colors.black))])): const SizedBox(),
//                     SizedBox(height: Dimensions.paddingSizeSmall,),
//                   ]),
//                 ),
//               ]),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




class OrderHistoryItemWidget extends StatelessWidget {
  final OrderModel? orderModel;
  const OrderHistoryItemWidget({super.key, this.orderModel});

  @override
  Widget build(BuildContext context) {
    String customerName = orderModel!.isGuest! ? '${orderModel!.billingAddress != null? orderModel!.billingAddress?.contactPersonName :
    '${orderModel?.billingAddress?.contactPersonName}'}' :
    '${orderModel!.customer?.fName ?? ''} ''${orderModel!.customer?.lName ?? ''}';

    return GestureDetector(
      onTap: () => Get.to(OrderDetailsScreen(orderModel: orderModel, fromNotification: false)),
      child: Container(
        margin: EdgeInsets.only(
          left: Dimensions.paddingSizeSmall,
          right: Dimensions.paddingSizeSmall,
          bottom: Dimensions.paddingSizeSmall,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${'order'.tr} ',
                              style: rubikRegular.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                            TextSpan(
                              text: '#${orderModel!.id}',
                              style: rubikBold.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: (orderModel?.orderStatus == 'canceled'  || orderModel?.orderStatus == 'returned') ? Theme.of(context).colorScheme.error.withValues(alpha: 0.1)  :  orderModel?.orderStatus?.tr == 'Delivered' ? Theme.of(context).colorScheme.onTertiaryContainer.withValues(alpha: 0.1) :  orderModel?.orderStatus?.tr == 'Delivered' ? Theme.of(context).colorScheme.onTertiaryContainer.withValues(alpha: 0.1) : orderModel?.orderStatus == 'out_for_delivery' ? Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1) : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          (orderModel!.orderStatus ?? 'assigned').tr.capitalizeFirst!,
                          style: rubikMedium.copyWith(
                            color: (orderModel?.orderStatus == 'canceled'  || orderModel?.orderStatus == 'returned') ? Theme.of(context).colorScheme.error  :  orderModel?.orderStatus?.tr == 'Delivered' ? Theme.of(context).colorScheme.onTertiaryContainer :  orderModel?.orderStatus?.tr == 'Delivered' ? Theme.of(context).colorScheme.onTertiaryContainer : orderModel?.orderStatus == 'out_for_delivery' ? Theme.of(context).colorScheme.tertiary : Theme.of(context).primaryColor,
                            fontSize: Dimensions.fontSizeExtraSmall,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Text(
                    '${'assigned'.tr} : ${DateConverter.localDateToIsoStringAMPM(DateTime.parse(orderModel!.createdAt!))}',
                    style: rubikRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeExtraSmall),
                  ),
                ],
              ),
            ),
            Divider(height: 0.2, thickness: 1, color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5)),


            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'customer_info'.tr,
                    style: rubikMedium.copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize: Dimensions.fontSizeExtraSmall,
                    ),
                  ),
                  SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: CustomImageWidget(
                          image: '${orderModel!.customer?.imageFullUrl?.path}',
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: Dimensions.paddingSizeSmall),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customerName,
                              style: rubikBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            Text(
                              orderModel!.shippingAddress?.address ?? 'no_address_found'.tr,
                              style: rubikRegular.copyWith(
                                color: Theme.of(context).hintColor,
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      CallAndChatWidget(orderModel: orderModel),
                    ],
                  ),
                ],
              ),
            ),



            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).hintColor.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '${'expected_date'.tr} : ',
                        style: rubikRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
                      ),

                      Text(
                        orderModel!.expectedDate != null ? DateConverter.formatDateToDayMonthYear(DateTime.parse(orderModel!.expectedDate!.split(' at ').first)) : '--',
                        style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                      ),

                    ],
                  ),
                  Text(
                    'view_details'.tr,
                    style: rubikMedium.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontSize: Dimensions.fontSizeDefault,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}