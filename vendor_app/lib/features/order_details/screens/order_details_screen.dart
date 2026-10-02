import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/image_diaglog_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/no_data_screen.dart';
import 'package:sixvalley_vendor_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixvalley_vendor_app/features/order/domain/models/order_model.dart';
import 'package:sixvalley_vendor_app/features/order_details/controllers/order_details_controller.dart';
import 'package:sixvalley_vendor_app/features/order_details/domain/models/order_details_model.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/alline_customer_card_widget.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/alline_delivery_address_card_widget.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/alline_order_action_bar_widget.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/alline_order_header_card_widget.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/alline_order_progress_widget.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/alline_order_summary_card_widget.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/alline_payment_info_card_widget.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/delivery_man_information_widget.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/order_details_shimmer.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/order_top_section_widget.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/order_setup_bottom_sheet.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/product_list_widget.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/third_party_delivery_info_widget.dart';
import 'package:sixvalley_vendor_app/features/pos/controllers/customer_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int? orderId;
  final bool fromNotification;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
    this.fromNotification = false,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<CustomerController>(context, listen: false)
        .resetCustomerId(isUpdate: false, customerId: -1);
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.fromNotification &&
        Provider.of<SplashController>(context, listen: false).configModel ==
            null) {
      await Provider.of<SplashController>(context, listen: false).initConfig();
    }
    if (!mounted) return;
    await Provider.of<OrderDetailsController>(context, listen: false)
        .getOrderDetails(widget.orderId.toString());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.fromNotification && Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          Provider.of<OrderDetailsController>(context, listen: false)
              .emptyOrderDetails();
          return;
        }
        if (widget.fromNotification || !Navigator.of(context).canPop()) {
          Provider.of<OrderDetailsController>(context, listen: false)
              .emptyOrderDetails();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
            (_) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: ColorResources.getScaffoldBg(context),
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 64,
          backgroundColor: Theme.of(context).cardColor,
          surfaceTintColor: Theme.of(context).cardColor,
          automaticallyImplyLeading: false,
          titleSpacing: 8,
          title: Consumer<OrderDetailsController>(
            builder: (context, controller, _) {
              final details = controller.orderDetails;
              return OrderTopSectionWidget(
                orderModel: details?.isNotEmpty == true
                    ? details!.first.order
                    : null,
                fromNotification: widget.fromNotification,
              );
            },
          ),
        ),
        body: Consumer<OrderDetailsController>(
          builder: (context, controller, _) {
            final detailRows = controller.orderDetails;
            if (detailRows == null) {
              return controller.hasOrderDetailsError
                  ? _buildLoadError(context)
                  : const OrderDetailsShimmer();
            }
            if (detailRows.isEmpty) return const NoDataScreen();
            if (detailRows.first.order == null) return _buildLoadError(context);

            final order = detailRows.first.order!;
            final onlyDigital = detailRows.every(
              (item) => item.productDetails?.productType == 'digital',
            );
            var itemsPrice = 0.0;
            var discount = 0.0;
            var lineTax = 0.0;
            for (final item in detailRows) {
              itemsPrice += (item.price ?? 0) * (item.qty ?? 0);
              discount += item.discount ?? 0;
              lineTax += item.tax ?? 0;
            }

            final tax = order.totalTaxAmount ?? lineTax;
            final coupon = order.discountAmount ?? 0;
            final shipping = order.isShippingFree == true
                ? 0.0
                : (order.shippingCost ?? 0);
            var extraDiscount = 0.0;
            if (order.orderType == 'POS') {
              if (order.extraDiscountType == 'percent') {
                extraDiscount =
                    (itemsPrice - coupon - discount) * ((order.extraDiscount ?? 0) / 100);
              } else {
                extraDiscount = order.extraDiscount ?? 0;
              }
            }
            final referAndEarnDiscount = order.orderType == 'POS'
                ? 0.0
                : (order.referAndEarnDiscount ?? 0);
            final totalPrice = itemsPrice + tax - discount + shipping - coupon -
                extraDiscount - referAndEarnDiscount;

            return RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        AllineOrderHeaderCardWidget(order: order),
                        AllineOrderProgressWidget(status: order.orderStatus),
                        AllineCustomerCardWidget(order: order),
                        AllineDeliveryAddressCardWidget(order: order),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          child: ProductListWidget(orderId: widget.orderId ?? 0),
                        ),
                        AllineOrderSummaryCardWidget(
                          order: order,
                          itemsPrice: itemsPrice,
                          discount: discount,
                          tax: tax,
                          shipping: shipping,
                          coupon: coupon,
                          extraDiscount: extraDiscount,
                          referAndEarnDiscount: referAndEarnDiscount,
                          totalPrice: totalPrice,
                        ),
                        AllinePaymentInfoCardWidget(order: order),
                        if (!onlyDigital && order.deliveryMan != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 4),
                            child: DeliveryManContactInformationWidget(
                              orderModel: order,
                              orderType: order.orderType,
                              onlyDigital: onlyDigital,
                            ),
                          )
                        else if (!onlyDigital &&
                            order.thirdPartyServiceName == null &&
                            !const {'delivered', 'canceled', 'cancelled', 'failed', 'returned'}
                                .contains(order.orderStatus?.toLowerCase()))
                          _buildUnassignedDelivery(context, order),
                        if (order.thirdPartyServiceName?.isNotEmpty == true)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 4),
                            child: ThirdPartyDeliveryInfoWidget(
                                orderModel: order),
                          ),
                        if (order.orderNote?.trim().isNotEmpty == true)
                          _buildOrderNote(context, order.orderNote!.trim()),
                        _buildOrderActivity(
                          context,
                          createdAt: order.createdAt,
                          updatedAt: order.updatedAt,
                        ),
                        if (detailRows.first.verificationImages?.isNotEmpty ==
                            true)
                          _buildVerificationImages(context, detailRows.first),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: Consumer<OrderDetailsController>(
          builder: (_, controller, __) {
            final details = controller.orderDetails;
            final order = details?.isNotEmpty == true ? details!.first.order : null;
            if (order == null ||
                !const {
                  'pending',
                  'confirmed',
                  'processing',
                  'out_for_delivery',
                }.contains(order.orderStatus?.toLowerCase())) {
              return const SizedBox.shrink();
            }
            return AllineOrderActionBarWidget(
              order: order,
              onlyDigital: details!.every(
                (item) => item.productDetails?.productType == 'digital',
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadError(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_outlined,
                  size: 42, color: ColorResources.getTextSubTitle(context)),
              const SizedBox(height: 12),
              Text(
                'تعذر تحميل تفاصيل الطلب',
                style: TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: ColorResources.getTextTitle(context),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'تحقق من اتصالك وحاول مرة أخرى.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 13,
                  color: ColorResources.getTextSubTitle(context),
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );

  Widget _buildUnassignedDelivery(BuildContext context, Order order) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: ColorResources.getBorder(context)),
        ),
        child: Row(
          children: [
            Icon(Icons.local_shipping_outlined,
                color: ColorResources.getTextSubTitle(context), size: 21),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'التوصيل',
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: ColorResources.getTextTitle(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'لم يتم تعيين مندوب لهذا الطلب بعد.',
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 12,
                      color: ColorResources.getTextSubTitle(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                useSafeArea: true,
                isScrollControlled: true,
                backgroundColor: Theme.of(context).cardColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => OrderSetupBottomSheet(
                  orderModel: order,
                  onlyDigital: false,
                  bottomContext: context,
                ),
              ),
              child: const Text(
                'تعيين',
                style: TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildOrderNote(BuildContext context, String note) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: ColorResources.getBorder(context)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.sticky_note_2_outlined,
                color: ColorResources.getPrimary(context), size: 19),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ملاحظات الطلب',
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: ColorResources.getTextTitle(context),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    note,
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 13,
                      height: 1.5,
                      color: ColorResources.getTextSubTitle(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildOrderActivity(
    BuildContext context, {
    required String? createdAt,
    required String? updatedAt,
  }) {
    final created = DateTime.tryParse(createdAt ?? '');
    final updated = DateTime.tryParse(updatedAt ?? '');
    if (created == null) return const SizedBox.shrink();

    final showUpdated = updated != null && !updated.isAtSameMomentAs(created);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: ColorResources.getBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'نشاط الطلب',
            style: TextStyle(
              fontFamily: 'AllineTajawal',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: ColorResources.getTextTitle(context),
            ),
          ),
          const SizedBox(height: 14),
          _activityRow(
            context,
            label: 'تم إنشاء الطلب',
            time: DateConverter.localDateToIsoStringAMPM(created),
            isLast: !showUpdated,
          ),
          if (showUpdated)
            _activityRow(
              context,
              label: 'آخر تحديث على الطلب',
              time: DateConverter.localDateToIsoStringAMPM(updated),
              isLast: true,
            ),
        ],
      ),
    );
  }

  Widget _activityRow(
    BuildContext context, {
    required String label,
    required String time,
    required bool isLast,
  }) => SizedBox(
        height: isLast ? 24 : 46,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 20,
              child: Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(top: 3),
                    decoration: BoxDecoration(
                      color: ColorResources.getPrimary(context),
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 1.5,
                        color: ColorResources.getBorder(context),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: ColorResources.getTextTitle(context),
                ),
              ),
            ),
            Text(
              time,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 11,
                color: ColorResources.getTextSubTitle(context),
              ),
            ),
          ],
        ),
      );

  Widget _buildVerificationImages(
    BuildContext context,
    OrderDetailsModel details,
  ) {
    final images = details.verificationImages;
    if (images == null || images.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            'صور إثبات التسليم',
            style: TextStyle(
              fontFamily: 'AllineTajawal',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: ColorResources.getTextTitle(context),
            ),
          ),
        ),
        SizedBox(
          height: 112,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            separatorBuilder: (_, __) => const SizedBox(width: 9),
            itemBuilder: (context, index) {
              final imageUrl = images[index].imageFullUrl?.path ?? '';
              if (imageUrl.isEmpty) return const SizedBox.shrink();
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => showDialog<void>(
                  context: context,
                  builder: (_) => ImageDialogWidget(imageUrl: imageUrl),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 144,
                    child: CustomImageWidget(image: imageUrl),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
