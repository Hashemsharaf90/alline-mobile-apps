import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/features/order/controllers/order_controller.dart';
import 'package:sixvalley_delivery_boy/features/order/widgets/order_type_button_widget.dart';
import 'package:sixvalley_delivery_boy/utill/dimensions.dart';

class OrderHistoryHeaderWidget extends StatefulWidget {
  const OrderHistoryHeaderWidget({super.key});

  @override
  State<OrderHistoryHeaderWidget> createState() =>
      _OrderHistoryHeaderWidgetState();
}

class _OrderHistoryHeaderWidgetState extends State<OrderHistoryHeaderWidget> {

  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _itemKeys = List.generate(6, (index) => GlobalKey());

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(
      builder: (orderController) {

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final index = orderController.orderTypeIndex;
          if (index < _itemKeys.length) {
            final context = _itemKeys[index].currentContext;
            if (context != null) {
              Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: 0.5);
            }
          }
        });

        return Container(
          height: 65, padding: EdgeInsets.only(top: Dimensions.paddingSizeSmall),
          child: Padding(padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,
            ),
            child: SizedBox(
              height: 55,
              child: ListView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                children: [
                  OrderTypeButtonWidget(key: _itemKeys[0], text: 'all'.tr, index: 0,),

                  OrderTypeButtonWidget(key: _itemKeys[1], text: 'out_for_delivery'.tr, index: 1,),

                  OrderTypeButtonWidget(key: _itemKeys[2], text: 'paused'.tr, index: 2,),

                  OrderTypeButtonWidget(key: _itemKeys[3], text: 'delivered'.tr, index: 3,),

                  OrderTypeButtonWidget(key: _itemKeys[4], text: 'return'.tr, index: 4,),

                  OrderTypeButtonWidget(key: _itemKeys[5], text: 'canceled'.tr, index: 5,),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}