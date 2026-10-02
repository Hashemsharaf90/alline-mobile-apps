import 'package:flutter/material.dart';
import 'package:sixvalley_delivery_boy/features/order_details/controllers/order_details_controller.dart';
import 'package:sixvalley_delivery_boy/features/order_details/screens/order_delivered_screen.dart';
import 'package:sixvalley_delivery_boy/features/order_details/widgets/camera_or_gallery_widget.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/alline/alline_swipe_action.dart';
import 'package:sixvalley_delivery_boy/features/order_details/widgets/verify_otp_sheet_widget.dart';
import 'package:sixvalley_delivery_boy/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_delivery_boy/features/order/domain/models/order_model.dart';
import 'package:sixvalley_delivery_boy/features/order/controllers/order_controller.dart';
import 'package:sixvalley_delivery_boy/helper/price_converter.dart';
import 'package:sixvalley_delivery_boy/utill/dimensions.dart';
import 'package:sixvalley_delivery_boy/utill/images.dart';
import 'package:sixvalley_delivery_boy/utill/styles.dart';
import 'package:get/get.dart';

class OrderStatusChangeCustomButtonWidget extends StatelessWidget {
  final OrderModel? orderModel;
  final int? index;
  final bool? showCollectAmount;
  const OrderStatusChangeCustomButtonWidget({super.key, this.orderModel, this.index, this.showCollectAmount});

  @override
  Widget build(BuildContext context) {

    if (orderModel == null || orderModel!.isPause == true) {
      return const SizedBox();
    }

    String currentStatus = orderModel!.driverJourneyStatus ??
        (orderModel!.orderStatus == 'processing' ? 'assigned' : orderModel!.orderStatus) ?? '';

    String label = '';
    String nextStatus = '';

    if (currentStatus == 'assigned') {
      label = 'swipe_to_accept_order'.tr;
      nextStatus = 'accepted';
    } else if (currentStatus == 'accepted') {
      label = 'swipe_to_head_to_store'.tr;
      nextStatus = 'heading_to_store';
    } else if (currentStatus == 'heading_to_store') {
      label = 'swipe_to_arrived_at_store'.tr;
      nextStatus = 'arrived_at_store';
    } else if (currentStatus == 'arrived_at_store') {
      label = 'swipe_to_picked_up'.tr;
      nextStatus = 'picked_up';
    } else if (currentStatus == 'picked_up' || currentStatus == 'out_for_delivery') {
      label = 'swipe_to_heading_to_customer'.tr;
      nextStatus = 'heading_to_customer';
    } else if (currentStatus == 'heading_to_customer') {
      label = 'swipe_to_arrived_at_customer'.tr;
      nextStatus = 'arrived_at_customer';
    } else if (currentStatus == 'arrived_at_customer') {
      label = 'swip_to_deliver_order'.tr;
      nextStatus = 'delivered';
    }

    if (nextStatus.isEmpty) return const SizedBox();

    return Container(
      color: Theme.of(context).cardColor,
      padding:  EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,vertical: Dimensions.paddingSizeSmall),
      child: Column(
        children: [

          if(showCollectAmount == true)...[
            GetBuilder<OrderController>(
                builder: (orderController) {
                  return GetBuilder<OrderDetailsController>(
                      builder: (orderDetailsController) {
                        return Padding(
                          padding: EdgeInsetsGeometry.symmetric(horizontal: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'amount_to_collect_from'.tr,
                                style: rubikRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
                              ),

                              Text(
                                PriceConverter.convertPrice(orderDetailsController.totalPrice),
                                style: rubikMedium.copyWith(color: Theme.of(context).primaryColor),
                              ),

                            ],
                          ),
                        );
                      }
                  );
                }
            ),

            SizedBox(height: Dimensions.paddingSizeExtraSmall),
          ],

          AllineSwipeAction(
            key: ValueKey(currentStatus),
            label: label,
            onSwipe: () async {
              if (nextStatus == 'delivered') {
                _handleDeliveredStatus(context);
                // Opens verification; delivery has not been confirmed yet.
                return false;
              } else {
                return await _handleStatusChange(context, nextStatus);
              }
            },
          )
        ],
      )
    );
  }

  Future<bool> _handleStatusChange(BuildContext context, String nextStatus) async {
    return Get.find<OrderDetailsController>().updateOrderStatus(orderId:orderModel!.id,status:nextStatus,context:context);
  }

  void _handleDeliveredStatus(BuildContext context) {
    final splashController = Get.find<SplashController>();
    final orderDetailsController = Get.find<OrderDetailsController>();

    if (splashController.configModel?.imageUpload == 1) {
      _showImageUploadDialog(context);
    } else {
      _handleNonImageUploadFlow(context, splashController, orderDetailsController);
    }
  }

  void _showImageUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  Get.find<OrderDetailsController>().gotoEndOfPage();
                  Get.back();
                },
                child: Padding(
                  padding: EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                  child: Icon(
                    Icons.cancel_rounded,
                    color: Theme.of(context).hintColor,
                    size: 30,
                  ),
                ),
              ),

              InkWell(
                onTap: () {
                  Get.back();
                  _showCameraBottomSheet(context);
                },
                child: Container(
                  width: Get.width,
                  height: 170,
                  decoration: BoxDecoration(
                    color: Get.isDarkMode
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
                        child: Text(
                          'take_a_picture'.tr,
                          style: rubikMedium.copyWith(color: Get.isDarkMode ? Theme.of(context).hintColor : Colors.black),
                        ),
                      ),
                      Container(
                        width: 150,
                        height: 75,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Get.isDarkMode
                              ? Theme.of(context).cardColor
                              : Theme.of(context).primaryColor.withValues(alpha: .125),
                          borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                        ),
                        child: Image.asset(Images.camera),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }


  void _showCameraBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: CameraOrGalleryWidget(
            orderModel: orderModel,
            totalPrice: Get.find<OrderDetailsController>().totalPrice,
          ),
        );
      },
    );
  }


  void _handleNonImageUploadFlow(
      BuildContext context,
      SplashController splashController,
      OrderDetailsController orderDetailsController,
      ) {
    if (splashController.configModel?.orderVerification == 0) {
      if (orderModel?.paymentStatus != 'paid') {
        orderDetailsController.toggleProceedToNext();
        _showVerifyDeliverySheet(context);
      } else {
        _completeDelivery(context, orderDetailsController);
      }
    } else {
      orderDetailsController.gotoEndOfPage();
    }
  }

  void _showVerifyDeliverySheet(BuildContext context) {
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: VerifyDeliverySheetWidget(
            orderModel: orderModel,
            totalPrice: Get.find<OrderDetailsController>().totalPrice,
          ),
        );
      },
    );
  }

  void _completeDelivery(
    BuildContext context,
      OrderDetailsController orderDetailsController,
    ) {
    orderDetailsController.updateOrderStatus(
      orderId: orderModel!.id,
      context: context,
      status: 'delivered',
    ).then((value) {
      if (!value || !context.mounted) return;
      Navigator.of(Get.context!).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OrderDeliveredScreen(
            orderID: orderModel!.id.toString(),
            orderModel: orderModel,
          ),
        ),
      );
    });
  }

}
