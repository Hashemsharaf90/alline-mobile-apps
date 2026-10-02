import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/helper/color_helper.dart';
import 'package:sixvalley_delivery_boy/utill/dimensions.dart';
import 'package:sixvalley_delivery_boy/utill/images.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_stepper_widget.dart';

class TrackingStepperWidget extends StatelessWidget {
  final String? status;
  const TrackingStepperWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    int status = -1;
    if(this.status == 'confirmed') {
      status = 0;
    }else if(this.status == 'processing') {
      status = 1;
    }else if(this.status == 'out_for_delivery') {
      status = 2;
    }else if(this.status == 'delivered') {
      status = 3;
    }

    return Container(padding:  EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(color: Get.isDarkMode?
      ColorHelper.blendColors(Colors.white, Theme.of(context).primaryColor, 0.9)  : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)),
      child: Row(children: [
        CustomStepperWidget(title: 'order_confirmed'.tr, isActive: status > -1,
          hasLeftBar: false, hasRightBar: true, rightActive: status > 0,
          icon: Images.orderConfirmationIcon,),

        CustomStepperWidget(title: 'order_processing'.tr, isActive: status > 0, hasLeftBar: true,
          hasRightBar: true, rightActive: status > 1,
          icon: Images.orderProcessingIcon),

        CustomStepperWidget(
          title: 'out_for_delivery'.tr, isActive: status > 1, hasLeftBar: true,
            hasRightBar: true, rightActive: status > 2,
          icon: Images.orderOutForDeliveryIcon),

        CustomStepperWidget(title: 'delivered'.tr, isActive: status > 2,
          hasLeftBar: true, hasRightBar: false, rightActive: status > 3,
          icon: Images.orderDeliveredIcon)]));
  }
}
