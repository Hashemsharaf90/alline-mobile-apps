import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/features/order/domain/models/order_model.dart';
import 'package:sixvalley_delivery_boy/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixvalley_delivery_boy/features/order_details/screens/order_details_screen.dart';

class OrderDeliveredScreen extends StatelessWidget {
  final OrderModel? orderModel;
  final String? orderID;
  const OrderDeliveredScreen({super.key, this.orderID, this.orderModel});
  @override
  Widget build(BuildContext context) => Scaffold(
      body: SafeArea(
          child: Center(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.check_circle_outline_rounded,
                            size: 80,
                            color: Theme.of(context)
                                .colorScheme
                                .onTertiaryContainer),
                        const SizedBox(height: 24),
                        Text('alline_delivery_success'.tr,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 16),
                        if (orderID != null || orderModel?.id != null)
                          Text('${'order'.tr} #${orderID ?? orderModel!.id}'),
                        const SizedBox(height: 32),
                        SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                                onPressed: () => Get.offAll(
                                    () => const DashboardScreen(pageIndex: 0)),
                                child: Text('alline_return_home'.tr,
                                    textAlign: TextAlign.center))),
                        if (orderModel?.id != null) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                  onPressed: () => Get.to(() =>
                                      OrderDetailsScreen(
                                          orderModel:
                                              OrderModel(id: orderModel!.id),
                                          fromNotification: false)),
                                  child: Text('alline_order_details'.tr,
                                      textAlign: TextAlign.center)))
                        ],
                      ]))))));
}
