import 'package:sixvalley_delivery_boy/common/basewidgets/alline/alline_tracking_indicator.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/alline/alline_states.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/features/order/controllers/order_controller.dart';
import 'package:sixvalley_delivery_boy/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_delivery_boy/utill/dimensions.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/alline/alline_empty_state.dart';
import 'package:sixvalley_delivery_boy/features/home/widgets/permission_dialog_widget.dart';
import 'package:sixvalley_delivery_boy/features/home/widgets/alline_home_hero_widget.dart';
import 'package:sixvalley_delivery_boy/features/home/widgets/alline_active_delivery_card.dart';
import 'package:sixvalley_delivery_boy/theme/alline/alline_colors.dart';
import 'package:sixvalley_delivery_boy/theme/alline/alline_typography.dart';
import 'package:sixvalley_delivery_boy/helper/price_converter.dart';

class HomeScreen extends StatefulWidget {
  final Function(int index) onTap;
  const HomeScreen({super.key, required this.onTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Future<void> _loadData() async {
    await Get.find<ProfileController>().getProfile();
    await Get.find<OrderController>().getCurrentOrders();
  }

  @override
  void initState() {
    _checkPermission(context);
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBarWidget(
        title: 'dashboard'.tr,
        isSwitch: false, // We've moved it to the hero
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AllineColors.primaryBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AllineHomeHeroWidget(),
              const AllineTrackingIndicator(),
              const SizedBox(height: 24),

              GetBuilder<ProfileController>(builder:(profileController)=>GetBuilder<OrderController>(
                builder: (orderController) {
                  if (orderController.isLoading) {
                    return const AllineSkeleton(count: 1);
                  }

                  if (orderController.currentOrdersFailed && orderController.currentOrders.isEmpty) return AllineErrorState(onRetry: () => orderController.getCurrentOrders());
                  final activeStatuses = [
                    'assigned', 'accepted', 'heading_to_store',
                    'arrived_at_store', 'picked_up', 'heading_to_customer',
                    'arrived_at_customer', 'out_for_delivery'
                  ];

                  final activeOrders = orderController.currentOrders.where((order) =>
                    activeStatuses.contains(order.driverJourneyStatus) ||
                    activeStatuses.contains(order.orderStatus)
                  ).toList();

                  if (activeOrders.isNotEmpty) {
                    // Show active delivery hero
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'active_delivery'.tr,
                          style: AllineTypography.titleMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
                        ),
                        const SizedBox(height: 12),
                        AllineActiveDeliveryCard(order: activeOrders.first),
                      ],
                    );
                  } else {
                    // Show empty state / ready state
                    final isOnline = Get.find<ProfileController>().profileModel?.isOnline == 1;

                    if (isOnline) {
                      return AllineEmptyState(
                        title: 'ready_for_delivery'.tr,
                        subtitle: 'will_notify_you_when_new_task'.tr,
                        icon: Icons.check_circle_outline_rounded,
                      );
                    } else {
                      return AllineEmptyState(title: 'offline_now'.tr, subtitle: 'you_are_offline_wont_receive_orders'.tr, icon: Icons.power_settings_new_rounded);
                    }
                  }
                }
              )),

              const SizedBox(height: 24),
              _buildTodaySummary(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodaySummary() {
    return GetBuilder<ProfileController>(
      builder: (profileController) {
        if (profileController.profileModel == null) return const SizedBox.shrink();

        final profile = profileController.profileModel!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'today_summary'.tr,
              style: AllineTypography.titleMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'completed_deliveries'.tr,
                    value: profile.completedDelivery?.toString() ?? '—',
                    icon: Icons.local_shipping_rounded,
                    color: AllineColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'cash_in_hand'.tr,
                    value: profile.cashInHand == null ? '—' : PriceConverter.convertPrice(profile.cashInHand),
                    icon: Icons.account_balance_wallet_rounded,
                    color: AllineColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'today_earn'.tr,
                    value: profile.totalEarn == null ? '—' : PriceConverter.convertPrice(profile.totalEarn),
                    icon: Icons.monetization_on_rounded,
                    color: AllineColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'total_delivery'.tr,
                    value: profile.totalDelivery?.toString() ?? '—',
                    icon: Icons.assignment_rounded,
                    color: AllineColors.brightBlue,
                  ),
                ),
              ],
            )
          ],
        );
      }
    );
  }

  Widget _buildMetricCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AllineTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AllineTypography.titleMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _checkPermission(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied) {
      showDialog(context: Get.context!, barrierDismissible: false, builder: (context) => PermissionDialogWidget(isDenied: true,
          onPressed: () async {
            Navigator.pop(context);
            await Geolocator.requestPermission();
          }));
    }else if(permission == LocationPermission.deniedForever) {
      showDialog(context: Get.context!, barrierDismissible: false, builder: (context) => PermissionDialogWidget(isDenied: false,
          onPressed: () async {
            Navigator.pop(context);
            await Geolocator.openAppSettings();
          }));
    }
  }
}
