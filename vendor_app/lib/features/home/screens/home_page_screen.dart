import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/bank_info/controllers/bank_info_controller.dart';
import 'package:sixvalley_vendor_app/features/delivery_man/controllers/delivery_man_controller.dart';
import 'package:sixvalley_vendor_app/features/delivery_man/widgets/top_delivery_man_view_widget.dart';
import 'package:sixvalley_vendor_app/features/home/widgets/seller_dashboard_content.dart';
import 'package:sixvalley_vendor_app/features/notification/controllers/notification_controller.dart';
import 'package:sixvalley_vendor_app/features/notification/screens/notification_screen.dart';
import 'package:sixvalley_vendor_app/features/order/controllers/order_controller.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/product_controller.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/features/review/controllers/product_review_controller.dart';
import 'package:sixvalley_vendor_app/features/shipping/controllers/shipping_controller.dart';
import 'package:sixvalley_vendor_app/features/shop/controllers/shop_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key, required this.onNavigate});
  final ValueChanged<int> onNavigate;

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  bool _initialLoading = true;
  bool _essentialLoadFailed = false;

  Future<void> _safe(Future<dynamic> request) async {
    try {
      await request;
    } catch (_) {
      // A failed panel does not hide other successfully loaded panels.
    }
  }

  Future<void> _loadData(bool reload) async {
    final bank = context.read<BankInfoController>();
    final orders = context.read<OrderController>();
    final products = context.read<ProductController>();
    final profile = context.read<ProfileController>();
    final shop = context.read<ShopController>();
    final essential = <Future<void>>[
      if (reload || profile.userInfoModel == null)
        _safe(profile.getSellerInfo()),
      if (reload || shop.shopModel == null) _safe(shop.getShopInfo()),
      _safe(bank.getDashboardSalesSummary()),
      _safe(bank.getDashboardTodayAnalytics()),
      _safe(bank.getDashboardActionAnalytics()),
      _safe(orders.getDashboardRecentOrders()),
      _safe(products.getStockLimitStatus(context)),
      _safe(context.read<NotificationController>().getNotificationList(1)),
    ];
    final secondary = <Future<void>>[
      _safe(products.getStockOutProductList(1, 'en', reload: reload)),
      _safe(
          products.getTopSellingProductList(1, context, 'en', reload: reload)),
      _safe(bank.getDashboardWeekEarnings()),
      _safe(bank.getBankInfo(context)),
      _safe(context.read<SplashController>().getColorList()),
      _safe(context.read<ShippingController>().getCategoryWiseShippingMethod()),
      _safe(context
          .read<ShippingController>()
          .getSelectedShippingMethodType(context)),
      _safe(
          context.read<DeliveryManController>().getTopDeliveryManList(context)),
      _safe(
          products.getMostPopularProductList(1, context, 'en', reload: reload)),
      _safe(context.read<ProductReviewController>().getReviewList(context)),
    ];
    await Future.wait(essential);
    if (reload) {
      await Future.wait(secondary);
    } else {
      unawaited(Future.wait(secondary).then((_) {}));
    }
    if (!mounted) return;
    setState(() {
      _initialLoading = false;
      _essentialLoadFailed = shop.shopModel == null &&
          profile.userInfoModel == null &&
          orders.dashboardRecentOrders == null &&
          bank.dashboardTodayAnalytics == null;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadData(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationCount = context.select<NotificationController, int>(
        (controller) => controller.notificationModel?.newNotificationItem ?? 0);
    return Scaffold(
      backgroundColor: ColorResources.getScaffoldBg(context),
      body: RefreshIndicator(
        onRefresh: () => _loadData(true),
        child: CustomScrollView(slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: ColorResources.getCardBg(context),
            surfaceTintColor: ColorResources.getCardBg(context),
            automaticallyImplyLeading: false,
            title: Image.asset(Images.logoWithAppName, height: 29),
            actions: [
              IconButton(
                tooltip:
                    'الإشعارات${notificationCount > 0 ? '، $notificationCount جديدة' : ''}',
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationScreen())),
                icon: Badge(
                    isLabelVisible: notificationCount > 0,
                    label: Text(
                        notificationCount > 99 ? '99+' : '$notificationCount'),
                    child: const Icon(CupertinoIcons.bell,
                        color: AllineColors.primary)),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
              child: _initialLoading
                  ? const _DashboardSkeleton()
                  : _essentialLoadFailed
                      ? _DashboardError(onRetry: () {
                          setState(() => _initialLoading = true);
                          _loadData(true);
                        })
                      : Column(children: [
                          SellerDashboardContent(onNavigate: widget.onNavigate),
                          if (context
                                  .read<SplashController>()
                                  .configModel
                                  ?.shippingMethod !=
                              'inhouse_shipping')
                            const TopDeliveryManViewWidget(isMain: true),
                          const SizedBox(height: 16),
                        ])),
        ]),
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final highlightColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC);

    Widget box(double height, double width, {double radius = 12}) => Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
          ),
        );

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                box(52, 52, radius: 26),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      box(18, 160, radius: 8),
                      const SizedBox(height: 6),
                      box(13, 110, radius: 6),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Store Status
            box(58, double.infinity, radius: 16),
            const SizedBox(height: 16),

            // Hero Sales Card
            box(185, double.infinity, radius: 22),
            const SizedBox(height: 16),

            // 2x2 KPI Grid
            Row(
              children: [
                Expanded(child: box(78, double.infinity, radius: 16)),
                const SizedBox(width: 12),
                Expanded(child: box(78, double.infinity, radius: 16)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: box(78, double.infinity, radius: 16)),
                const SizedBox(width: 12),
                Expanded(child: box(78, double.infinity, radius: 16)),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            box(18, 120, radius: 8),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: box(68, double.infinity, radius: 16)),
                const SizedBox(width: 10),
                Expanded(child: box(68, double.infinity, radius: 16)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: box(68, double.infinity, radius: 16)),
                const SizedBox(width: 10),
                Expanded(child: box(68, double.infinity, radius: 16)),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Orders
            box(18, 140, radius: 8),
            const SizedBox(height: 12),
            box(72, double.infinity, radius: 16),
            const SizedBox(height: 10),
            box(72, double.infinity, radius: 16),
          ],
        ),
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        const Icon(Icons.wifi_off_rounded,
            color: AllineColors.primary, size: 40),
        const SizedBox(height: 12),
        Text('تعذر تحميل بيانات المتجر',
            style: TextStyle(
                color: ColorResources.getTextTitle(context),
                fontSize: 17,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        FilledButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
      ]));
}
