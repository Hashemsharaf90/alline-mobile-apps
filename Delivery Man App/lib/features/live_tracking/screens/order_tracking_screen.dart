import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixvalley_delivery_boy/features/live_tracking/controllers/rider_controller.dart';
import 'package:sixvalley_delivery_boy/features/order/controllers/order_controller.dart';
import 'package:sixvalley_delivery_boy/features/order/domain/models/order_model.dart';
import 'package:sixvalley_delivery_boy/helper/delivery_destination.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/alline/alline_empty_state.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/alline/alline_states.dart';
class OrderLiveTrackingScreen extends StatefulWidget {
 final OrderModel? orderModel;
 const OrderLiveTrackingScreen({super.key,this.orderModel});
 @override State<OrderLiveTrackingScreen> createState()=>_OrderLiveTrackingScreenState();
}
class _OrderLiveTrackingScreenState extends State<OrderLiveTrackingScreen> {
 GoogleMapController? _map;
 LatLng? _destination;
 bool _loading=true;
 @override void initState(){super.initState();_load();}
 Future<void> _load()async{
 final order=widget.orderModel;
 if(order==null){setState(()=>_loading=false);return;}
 _destination=DeliveryDestination.coordinates(order);
 if(_destination==null){setState(()=>_loading=false);return;}
 final rider=Get.find<RiderController>();
 Get.find<OrderController>().setSelectedOrderLatLng(_destination!);
 await rider.getCurrentLocation();
 if(!mounted)return;
 if(rider.initialPosition!=null&&!rider.locationError)await rider.getPolyline(from:rider.initialPosition,to:_destination);
 if(mounted)setState(()=>_loading=false);
 }
 @override void dispose(){final rider=Get.find<RiderController>();if(identical(rider.mapController,_map))rider.mapController=null;_map?.dispose();super.dispose();}
 @override Widget build(BuildContext context)=>Scaffold(appBar:CustomAppBarWidget(title:'alline_view_map'.tr,isBack:true),
 body:GetBuilder<RiderController>(builder:(rider){
 if(_destination==null)return AllineEmptyState(title:(widget.orderModel!=null&&DeliveryDestination.isStore(widget.orderModel!)?'alline_store_location_missing':'location_not_available').tr,subtitle:widget.orderModel?.shippingAddress?.address??'',icon:Icons.location_off_outlined);
 if(_loading)return const Padding(padding:EdgeInsets.all(16),child:AllineSkeleton());
 if(rider.initialPosition==null||rider.locationError)return AllineErrorState(message:'alline_location_error'.tr,onRetry:(){setState(()=>_loading=true);_load();});
 return Column(children:[Expanded(child:GoogleMap(initialCameraPosition:CameraPosition(target:rider.initialPosition!,zoom:14),
 onMapCreated:(controller){_map=controller;rider.mapController=controller;},
 markers:{Marker(markerId:const MarkerId('driver'),position:rider.initialPosition!),Marker(markerId:const MarkerId('destination'),position:_destination!)},
 polylines:rider.polylines.values.toSet(),myLocationEnabled:false,myLocationButtonEnabled:false,mapToolbarEnabled:false)),
 SafeArea(top:false,child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
 Text((DeliveryDestination.isStore(widget.orderModel!)?'heading_to_store_dest':'heading_to_customer_dest').tr,style:Theme.of(context).textTheme.titleSmall),
 if(rider.polylines.values.every((line)=>line.points.isEmpty))Text('alline_route_unavailable'.tr),
 OutlinedButton.icon(onPressed:(){setState(()=>_loading=true);_load();},icon:const Icon(Icons.refresh),label:Text('alline_retry'.tr)),
 ]))),
 ]);
 }));
}
