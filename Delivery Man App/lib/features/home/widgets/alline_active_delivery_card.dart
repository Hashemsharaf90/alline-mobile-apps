import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/features/order/domain/models/order_model.dart';
import 'package:sixvalley_delivery_boy/features/order_details/screens/order_details_screen.dart';
import 'package:sixvalley_delivery_boy/features/live_tracking/screens/order_tracking_screen.dart';
import 'package:sixvalley_delivery_boy/helper/driver_journey.dart';
import 'package:sixvalley_delivery_boy/helper/delivery_destination.dart';
class AllineActiveDeliveryCard extends StatelessWidget {
 final OrderModel order;
 const AllineActiveDeliveryCard({super.key,required this.order});
 @override Widget build(BuildContext context){
 final store=DeliveryDestination.isStore(order);
 final name=store?order.seller?.shop?.name:order.shippingAddress?.address;
 return Card(color:Theme.of(context).colorScheme.primary,child:Padding(padding:const EdgeInsets.all(24),child:DefaultTextStyle(
 style:Theme.of(context).textTheme.bodyLarge!.copyWith(color:Theme.of(context).colorScheme.onPrimary),
 child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
 Text('${'order'.tr} #${order.id}'),const SizedBox(height:8),
 Text(DriverJourney.labelKey(DriverJourney.status(order)).tr,style:Theme.of(context).textTheme.titleMedium?.copyWith(color:Theme.of(context).colorScheme.onPrimary)),
 const SizedBox(height:16),Text((store?'heading_to_store_dest':'heading_to_customer_dest').tr),
 if(name?.isNotEmpty??false)Text(name!),
 if(order.paymentMethod=='cash_on_delivery'&&order.paymentStatus!='paid')...[
 const SizedBox(height:12),Text('cash_on_delivery'.tr)],
 const SizedBox(height:24),ElevatedButton(style:ElevatedButton.styleFrom(backgroundColor:Theme.of(context).colorScheme.surface,foregroundColor:Theme.of(context).colorScheme.primary),
 onPressed:()=>Get.to(()=>OrderDetailsScreen(orderModel:order,fromNotification:false)),child:Text('continue_delivery'.tr,textAlign:TextAlign.center)),
 const SizedBox(height:8),TextButton(style:TextButton.styleFrom(foregroundColor:Theme.of(context).colorScheme.onPrimary),
 onPressed:()=>Get.to(()=>OrderLiveTrackingScreen(orderModel:order)),child:Text('alline_view_map'.tr)),
 ]))));
 }
}
