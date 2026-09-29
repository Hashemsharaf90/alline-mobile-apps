import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixvalley_vendor_app/features/order_details/controllers/order_details_controller.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/alline_order_header_card_widget.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/alline_order_progress_widget.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/alline_customer_card_widget.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/alline_order_summary_card_widget.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/alline_order_action_bar_widget.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/order_details_shimmer.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/order_top_section_widget.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/product_list_widget.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/delivery_man_information_widget.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/third_party_delivery_info_widget.dart';
import 'package:sixvalley_vendor_app/features/order/controllers/order_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/image_diaglog_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/no_data_screen.dart';


class OrderDetailsScreen extends StatefulWidget {
  final int? orderId;
  final bool fromNotification;
  const OrderDetailsScreen({super.key,  required this.orderId, this.fromNotification = false});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  void _loadData(BuildContext context) async {
    if(widget.fromNotification && Provider.of<SplashController>(Get.context!, listen: false).configModel == null) {
      await Provider.of<SplashController>(Get.context!, listen: false).initConfig();
    }
    Provider.of<OrderDetailsController>(Get.context!, listen: false).getOrderDetails(widget.orderId.toString());
  }


  bool _onlyDigital = true;

  @override
  void initState() {
    _loadData(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async {
        Provider.of<OrderDetailsController>(context, listen: false).emptyOrderDetails();
        if(widget.fromNotification) {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const DashboardScreen()), (route)=> false);
        } else {
          return;
        }
      },

      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 1, backgroundColor: Theme.of(context).cardColor, toolbarHeight: 80,
          leadingWidth: 0, automaticallyImplyLeading: false,
          surfaceTintColor: Theme.of(context).highlightColor,
          title: Consumer<OrderDetailsController>(
            builder: (context, orderDetailsController,_) {
              return OrderTopSectionWidget(orderModel: orderDetailsController.orderDetails?[0].order, fromNotification: widget.fromNotification);
            }
          ),
        ),

        body: RefreshIndicator(
          onRefresh: () async => _loadData(context),
          child: Consumer<OrderController>(
            builder:(context, orderController, child){
              return Consumer<OrderDetailsController>(
                builder: (context, orderDetailsController, child) {
                  double itemsPrice = 0;
                  double discount = 0;
                  double eeDiscount = 0;
                  double tax = 0;
                  double coupon = 0;
                  double shipping = 0;
                  double referAndEarnDiscount = 0;
                  bool isFreeShipping = false;

                  if (orderDetailsController.orderDetails != null && orderDetailsController.orderDetails!.isNotEmpty) {
                    coupon = orderDetailsController.orderDetails![0].order!.discountAmount!;
                    shipping = orderDetailsController.orderDetails![0].order!.shippingCost!;
                    isFreeShipping = orderDetailsController.orderDetails?[0].order?.isShippingFree ?? false;
                    for (var orderDetails in orderDetailsController.orderDetails!) {
                      if(orderDetails.productDetails?.productType == "physical") {
                        _onlyDigital =  false;
                      }
                      itemsPrice = itemsPrice + (orderDetails.price! * orderDetails.qty!);
                      discount = discount + orderDetails.discount!;
                    }
                    tax = orderDetailsController.orderDetails![0].order?.totalTaxAmount ?? 0;

                    if(orderDetailsController.orderDetails![0].order!.orderType == 'POS') {
                      if(orderDetailsController.orderDetails![0].order!.extraDiscountType == 'percent') {
                        eeDiscount = (itemsPrice - coupon - discount) * (orderDetailsController.orderDetails![0].order!.extraDiscount!/100);
                      }else{
                        eeDiscount = orderDetailsController.orderDetails![0].order!.extraDiscount ?? 0;
                      }
                    }

                    if(orderDetailsController.orderDetails != null && orderDetailsController.orderDetails![0].order!.orderType != 'POS') {
                      referAndEarnDiscount = orderDetailsController.orderDetails?[0].order?.referAndEarnDiscount ?? 0;
                    }
                  }
                  double subTotal = itemsPrice + tax - discount;

                  double totalPrice = subTotal + (isFreeShipping ? 0 : shipping) - coupon - eeDiscount - referAndEarnDiscount;

                  return orderDetailsController.orderDetails != null ? orderDetailsController.orderDetails!.isNotEmpty ?
                  CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            // 1. Order Header Card (ID, Status Badge, Type, Date & Payment)
                            AllineOrderHeaderCardWidget(order: orderDetailsController.orderDetails![0].order),

                            // 2. Order Progress Tracker (Alline Stepper)
                            AllineOrderProgressWidget(status: orderDetailsController.orderDetails![0].order?.orderStatus),

                            // 3. Customer Information & Direct Contact Card
                            AllineCustomerCardWidget(order: orderDetailsController.orderDetails![0].order),

                            // 4. Products List (Supermarket Compatible)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                              child: ProductListWidget(orderId: widget.orderId ?? 0),
                            ),

                            // 5. Order Financial Summary & Payment Card
                            AllineOrderSummaryCardWidget(
                              order: orderDetailsController.orderDetails![0].order,
                              itemsPrice: itemsPrice,
                              discount: discount,
                              tax: tax,
                              shipping: isFreeShipping ? 0 : shipping,
                              coupon: coupon,
                              extraDiscount: eeDiscount,
                              totalPrice: totalPrice,
                            ),

                            // 6. Delivery Man Details (if assigned)
                            if (orderDetailsController.orderDetails![0].order!.deliveryMan != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                child: DeliveryManContactInformationWidget(
                                  orderModel: orderDetailsController.orderDetails![0].order,
                                  orderType: orderDetailsController.orderDetails![0].order!.orderType,
                                  onlyDigital: _onlyDigital,
                                ),
                              ),

                            // 7. Third-Party Courier Tracking (if assigned)
                            if (orderDetailsController.orderDetails![0].order!.thirdPartyServiceName != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                child: ThirdPartyDeliveryInfoWidget(orderModel: orderDetailsController.orderDetails![0].order),
                              ),

                            // 8. Order Note (if provided)
                            if (orderDetailsController.orderDetails![0].order!.orderNote != null &&
                                orderDetailsController.orderDetails![0].order!.orderNote!.trim().isNotEmpty)
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AllineColors.borderLight),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.note_alt_outlined, color: AllineColors.secondary, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'ملاحظات العميل على الطلب:',
                                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: AllineColors.textDark),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            orderDetailsController.orderDetails![0].order!.orderNote!,
                                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: AllineColors.textDark),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // 9. Delivery Verification Images (if uploaded)
                            if (orderDetailsController.orderDetails != null &&
                                orderDetailsController.orderDetails![0].verificationImages != null &&
                                orderDetailsController.orderDetails![0].verificationImages!.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                                    child: Text(
                                      'صور إثبات التسليم المرفوعة:',
                                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: AllineColors.textDark),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 120,
                                    child: ListView.builder(
                                      itemCount: orderDetailsController.orderDetails![0].verificationImages?.length,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        final imgUrl = orderDetailsController.orderDetails![0].verificationImages?[index].imageFullUrl?.path ?? '';
                                        return InkWell(
                                          onTap: () => showDialog(
                                            context: context,
                                            builder: (_) => ImageDialogWidget(
                                              imageUrl: imgUrl,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 14),
                                            child: SizedBox(
                                              width: 160,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child: CustomImageWidget(
                                                  image: imgUrl,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),

                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ],
                  ) : const NoDataScreen() :
                  const OrderDetailsShimmer();
                }
              );
            }
          ),
        ),

        bottomNavigationBar: Consumer<OrderDetailsController>(builder: (_, orderDetailsController, __) {
          if (orderDetailsController.orderDetails?.isEmpty ?? true) return const SizedBox();
          return AllineOrderActionBarWidget(
            order: orderDetailsController.orderDetails?[0].order,
            onlyDigital: _onlyDigital,
          );
        }),
      ),
    );
  }
}

