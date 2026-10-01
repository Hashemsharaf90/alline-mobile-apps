import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/addProduct/screens/add_product_tab_view_screen.dart';
import 'package:sixvalley_vendor_app/features/bank_info/controllers/bank_info_controller.dart';
import 'package:sixvalley_vendor_app/features/chat/screens/inbox_screen.dart';
import 'package:sixvalley_vendor_app/features/order/controllers/order_controller.dart';
import 'package:sixvalley_vendor_app/features/order/domain/models/order_model.dart';
import 'package:sixvalley_vendor_app/features/order_details/screens/order_details_screen.dart';
import 'package:sixvalley_vendor_app/features/pos/screens/pos_screen.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/product_controller.dart';
import 'package:sixvalley_vendor_app/features/product/screens/stock_out_product_screen.dart';
import 'package:sixvalley_vendor_app/features/product_details/screens/product_details_screen.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/features/shop/controllers/shop_controller.dart';
import 'package:sixvalley_vendor_app/features/shop/screens/vacation_mode_setup_screen.dart';
import 'package:sixvalley_vendor_app/features/wallet/screens/wallet_screen.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

/// Alline Seller Home Dashboard Content
///
/// Designed strictly according to the Alline Brand Design System:
/// Primary #015FC9, Dark Navy #032C75, Orange Accent #EC970D, Soft Blue #F4F8FE.
/// Answers the merchant's 4 core questions in 3-5 seconds:
/// 1. Store Status (مفتوح / مغلق / في إجازة)
/// 2. Today's Sales (قيمة مبيعات اليوم بالريال اليمني ومعدل النمو)
/// 3. Orders Overview (طلبات جديدة، قيد التجهيز، مكتملة)
/// 4. Urgent Action Items (طلبات تحتاج موافقة وتنبيهات المخزون)
class SellerDashboardContent extends StatelessWidget {
  const SellerDashboardContent({super.key, required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Consumer5<ProfileController, ShopController, BankInfoController,
        OrderController, ProductController>(
      builder: (context, profile, shop, bank, orders, products, _) {
        final analytics = bank.dashboardTodayAnalytics;
        final actions = bank.dashboardActionAnalytics;
        final totalOrders = analytics == null
            ? null
            : (analytics.pending ?? 0) +
                (analytics.confirmed ?? 0) +
                (analytics.processing ?? 0) +
                (analytics.outForDelivery ?? 0) +
                (analytics.delivered ?? 0) +
                (analytics.canceled ?? 0) +
                (analytics.returned ?? 0) +
                (analytics.failed ?? 0);

        final lowStock = products.stockLimitStatus?.productCount ?? 0;
        final recentOrders =
            orders.dashboardRecentOrders?.orders?.take(4).toList();
        final topProducts =
            products.topSellingProductModel?.products?.take(3).toList();
        final sellerInfo = profile.userInfoModel;
        final sellerName = (sellerInfo?.fName ?? '').trim();
        final storeName = (shop.shopModel?.name ?? '').trim();
        final avatarUrl = sellerInfo?.imageFullUrl?.path?.isNotEmpty == true
            ? sellerInfo!.imageFullUrl!.path
            : shop.shopModel?.imageFullUrl?.path;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Merchant Greeting & Store Header
              _storeHeader(context, sellerName, storeName, avatarUrl),
              const SizedBox(height: 14),

              // 2. Interactive Live Store Status Card
              _storeStatusCard(context, shop),
              const SizedBox(height: 16),

              // 3. Hero Sales Card (Primary Alline Gradient)
              _heroSalesCard(context, bank, totalOrders, analytics?.pending,
                  analytics?.delivered),
              const SizedBox(height: 16),

              // 4. 2x2 KPI Mini Cards (Order Pipeline)
              _kpiGrid(context, analytics),
              const SizedBox(height: 24),

              // 5. Needs Immediate Attention ("يحتاج إلى إجراء فوري")
              _heading(context, 'يحتاج إلى إجراء فوري'),
              const SizedBox(height: 10),
              _needsAttentionSection(context, actions, lowStock, products),
              const SizedBox(height: 24),

              // 6. Quick Actions Grid ("إجراءات سريعة")
              _heading(context, 'إجراءات سريعة'),
              const SizedBox(height: 10),
              _quickActionsGrid(context, profile),
              const SizedBox(height: 24),

              // 7. Recent Orders Preview ("آخر الطلبات")
              _heading(context, 'آخر الطلبات',
                  action: 'عرض الكل', onAction: () => _openOrders(context, 0)),
              const SizedBox(height: 10),
              _recentOrdersSection(context, recentOrders),
              const SizedBox(height: 24),

              // 8. Weekly Earnings Chart ("أداء الأرباح الأسبوعي")
              _heading(context, 'أداء الأرباح الأسبوعي',
                  action: 'التفاصيل', onAction: () => onNavigate(3)),
              const SizedBox(height: 10),
              _earningsChartPanel(context, bank),
              const SizedBox(height: 24),

              // 9. Inventory Alerts ("المخزون والمنتجات")
              _heading(context, 'المخزون يحتاج انتباهك',
                  action: 'إدارة المخزون',
                  onAction: () =>
                      _push(context, const StockOutProductScreen())),
              const SizedBox(height: 10),
              _inventoryPanel(context, products),
              const SizedBox(height: 24),

              // 10. Top Selling Products ("الأكثر مبيعًا")
              if (topProducts != null && topProducts.isNotEmpty) ...[
                _heading(context, 'الأكثر مبيعًا',
                    action: 'عرض المنتجات', onAction: () => onNavigate(2)),
                const SizedBox(height: 10),
                _topProductsPanel(context, topProducts),
                const SizedBox(height: 24),
              ],

              // 11. Wallet Summary Card ("المحفظة وسحب الأرباح")
              _heading(context, 'المحفظة والأرباح',
                  action: 'تفاصيل المحفظة',
                  onAction: () => _push(context, const WalletScreen())),
              const SizedBox(height: 10),
              _walletCard(context, profile),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Typography & Container Helpers
  // ---------------------------------------------------------------------------

  TextStyle _style(
    BuildContext context,
    double size, {
    bool bold = false,
    bool semiBold = false,
    bool muted = false,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: 'AllineTajawal',
      fontSize: size,
      fontWeight: bold
          ? FontWeight.w700
          : semiBold
              ? FontWeight.w600
              : FontWeight.w400,
      color: color ??
          (muted
              ? ColorResources.getTextSubTitle(context)
              : ColorResources.getTextTitle(context)),
      height: 1.35,
    );
  }

  Widget _panel(
    BuildContext context,
    Widget child, {
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    Color? backgroundColor,
    Border? border,
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? ColorResources.getCardBg(context),
        border: border ?? Border.all(color: ColorResources.getBorder(context)),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _heading(
    BuildContext context,
    String title, {
    String? action,
    VoidCallback? onAction,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: _style(context, 17, bold: true)),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              action,
              style: const TextStyle(
                fontFamily: 'AllineTajawal',
                color: AllineColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Merchant Greeting & Store Header
  // ---------------------------------------------------------------------------

  Widget _storeHeader(
    BuildContext context,
    String sellerName,
    String storeName,
    String? avatarUrl,
  ) {
    return Row(
      children: [
        // Store Avatar / Logo
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AllineColors.softBlue,
            shape: BoxShape.circle,
            border: Border.all(
                color: AllineColors.primary.withValues(alpha: 0.2), width: 2),
          ),
          child: ClipOval(
            child: avatarUrl != null && avatarUrl.isNotEmpty
                ? Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.storefront_rounded,
                      color: AllineColors.primary,
                      size: 26,
                    ),
                  )
                : const Icon(
                    Icons.storefront_rounded,
                    color: AllineColors.primary,
                    size: 26,
                  ),
          ),
        ),
        const SizedBox(width: 12),

        // Greeting and Store Identity
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      sellerName.isEmpty ? 'مرحبًا بك 👋' : 'مرحبًا، $sellerName 👋',
                      style: _style(context, 20, bold: true),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.verified_rounded,
                      color: AllineColors.primary, size: 18),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                storeName.isNotEmpty ? storeName : 'متجر Alline المعتمد',
                style: _style(context, 13, muted: true),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Interactive Live Store Status Card
  // ---------------------------------------------------------------------------

  Widget _storeStatusCard(BuildContext context, ShopController shop) {
    final model = shop.shopModel;
    final isVacation = model?.vacationStatus == true;
    final isOpen = model?.temporaryClose == true && !isVacation;

    final Color statusColor = isVacation
        ? AllineColors.orange
        : isOpen
            ? AllineColors.success
            : AllineColors.error;

    final Color bgColor = isVacation
        ? const Color(0xFFFFFBEB)
        : isOpen
            ? const Color(0xFFECFDF5)
            : const Color(0xFFFEF2F2);

    final String title = model == null
        ? 'حالة المتجر غير متاحة'
        : isVacation
            ? 'المتجر في وضع الإجازة'
            : isOpen
                ? 'المتجر مفتوح ويستقبل الطلبات'
                : 'المتجر مغلق مؤقتًا';

    final String subtitle = model == null
        ? 'اسحب للتحديث'
        : isVacation
            ? 'الطلبات متوقفة مؤقتًا حتى انتهاء الإجازة'
            : isOpen
                ? 'العملاء يستطيعون الشراء وتصفح المنتجات الآن'
                : 'الطلبات متوقفة حاليًا • اضغط لتغيير الحالة';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? ColorResources.getCardBg(context)
            : bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.28),
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: model == null ? null : () => _statusSheet(context, shop),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Pulsing dot indicator
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.4),
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Status details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: _style(context, 14, bold: true, color: statusColor),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: _style(context, 11, muted: true),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Action Pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'إدارة',
                        style: TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_left_rounded,
                          size: 16, color: statusColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Hero Sales Card (High Impact Alline Blue Gradient)
  // ---------------------------------------------------------------------------

  Widget _heroSalesCard(
    BuildContext context,
    BankInfoController bank,
    int? totalOrders,
    int? pending,
    int? delivered,
  ) {
    final sales = bank.todaySales;
    final yesterday = bank.yesterdaySales;
    final difference = sales != null && yesterday != null && yesterday > 0
        ? (sales - yesterday) / yesterday * 100
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AllineColors.primary, AllineColors.darkBlue],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AllineColors.primary.withValues(alpha: 0.32),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Icon + Label + Growth Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'قيمة مبيعات اليوم',
                style: TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.88),
                ),
              ),
              const Spacer(),

              // Growth pill
              if (difference != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: (difference >= 0
                            ? AllineColors.success
                            : AllineColors.orange)
                        .withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        difference >= 0
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        color: Colors.white,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${difference.abs().toStringAsFixed(0)}% بالأمس',
                        style: const TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'الطلبات المدفوعة',
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Big Hero Price
          Text(
            sales == null
                ? 'غير متاحة'
                : PriceConverter.convertPrice(context, sales),
            style: const TextStyle(
              fontFamily: 'AllineTajawal',
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),

          Text(
            sales == null
                ? 'تعذر جلب بيانات مبيعات اليوم'
                : 'إجمالي الطلبات المؤكدة والمدفوعة المسجلة اليوم',
            style: TextStyle(
              fontFamily: 'AllineTajawal',
              fontSize: 11.5,
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 16),

          // Translucent separator line
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 14),

          // 3 Mini Stats Bar inside hero card
          Row(
            children: [
              _heroStatItem('طلبات اليوم', totalOrders?.toString() ?? '—'),
              _heroStatItem('قيد الانتظار', pending?.toString() ?? '—'),
              _heroStatItem('تم تسليمها', delivered?.toString() ?? '—'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStatItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'AllineTajawal',
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'AllineTajawal',
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. 2x2 KPI Mini Cards (Order Pipeline)
  // ---------------------------------------------------------------------------

  Widget _kpiGrid(BuildContext context, dynamic analytics) {
    final pendingCount = analytics?.pending ?? 0;
    final processingCount = analytics?.processing ?? 0;
    final deliveredCount = analytics?.delivered ?? 0;
    final otherCount = (analytics?.canceled ?? 0) +
        (analytics?.returned ?? 0) +
        (analytics?.failed ?? 0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            // KPI 1: New / Pending Orders
            _kpiCard(
              context,
              width: cardWidth,
              count: pendingCount,
              label: 'طلبات جديدة',
              subtitle: 'تحتاج موافقة',
              icon: Icons.pending_actions_rounded,
              accentColor: AllineColors.error,
              onTap: () => _openOrders(context, 1),
            ),

            // KPI 2: In-Progress / Processing Orders
            _kpiCard(
              context,
              width: cardWidth,
              count: processingCount,
              label: 'قيد التجهيز',
              subtitle: 'جاري التجهيز',
              icon: Icons.hourglass_top_rounded,
              accentColor: AllineColors.warning,
              onTap: () => _openOrders(context, 2),
            ),

            // KPI 3: Delivered Orders
            _kpiCard(
              context,
              width: cardWidth,
              count: deliveredCount,
              label: 'تم تسليمها',
              subtitle: 'مكتملة بنجاح',
              icon: Icons.check_circle_outline_rounded,
              accentColor: AllineColors.success,
              onTap: () => _openOrders(context, 3),
            ),

            // KPI 4: Returned / Canceled Orders
            _kpiCard(
              context,
              width: cardWidth,
              count: otherCount,
              label: 'ملغية أو مرتجعة',
              subtitle: 'تحتاج مراجعة',
              icon: Icons.cancel_outlined,
              accentColor: AllineColors.coolGray,
              onTap: () => _openOrders(context, 0),
            ),
          ],
        );
      },
    );
  }

  Widget _kpiCard(
    BuildContext context, {
    required double width,
    required int count,
    required String label,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: width,
      child: Material(
        color: ColorResources.getCardBg(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: ColorResources.getBorder(context)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$count',
                        style: _style(context, 20, bold: true),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: _style(context, 13, bold: true),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        subtitle,
                        style: _style(context, 11, muted: true),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accentColor, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Needs Attention Section ("يحتاج إلى إجراء فوري")
  // ---------------------------------------------------------------------------

  Widget _needsAttentionSection(
    BuildContext context,
    dynamic actions,
    int lowStock,
    ProductController products,
  ) {
    if (actions == null && products.stockLimitStatus == null) {
      return _information(context, 'بيانات التنبيهات قيد التحميل أو غير متاحة');
    }

    final pending = actions?.pending ?? 0;
    final processing = actions?.processing ?? 0;

    if (pending == 0 && processing == 0 && lowStock == 0) {
      // Reassuring zero-state banner
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFA7F3D0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified_rounded,
                color: AllineColors.success, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'كل شيء جاهز ومحدث! 🎉',
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF065F46),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'لا توجد طلبات معلقة أو تنبيهات مخزون عاجلة في الوقت الحالي.',
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 12,
                      color: const Color(0xFF047857).withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return _panel(
      context,
      Column(
        children: [
          if (pending > 0)
            _actionRow(
              context,
              Icons.receipt_long_rounded,
              'لديك $pending طلبات جديدة بانتظار التأكيد',
              'مراجعة الطلبات',
              AllineColors.error,
              () => _openOrders(context, 1),
            ),
          if (pending > 0 && (processing > 0 || lowStock > 0))
            Divider(color: ColorResources.getBorder(context), height: 16),
          if (processing > 0)
            _actionRow(
              context,
              Icons.inventory_2_rounded,
              'لديك $processing طلبات قيد التجهيز',
              'متابعة التجهيز',
              AllineColors.warning,
              () => _openOrders(context, 2),
            ),
          if (processing > 0 && lowStock > 0)
            Divider(color: ColorResources.getBorder(context), height: 16),
          if (lowStock > 0)
            _actionRow(
              context,
              Icons.warning_amber_rounded,
              'لديك $lowStock منتجات أوشكت على النفاد',
              'إدارة المخزون',
              AllineColors.orange,
              () => _push(context, const StockOutProductScreen()),
            ),
        ],
      ),
    );
  }

  Widget _actionRow(
    BuildContext context,
    IconData icon,
    String title,
    String action,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: _style(context, 13, bold: true),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AllineColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                action,
                style: const TextStyle(
                  fontFamily: 'AllineTajawal',
                  color: AllineColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. Quick Actions Grid ("إجراءات سريعة")
  // ---------------------------------------------------------------------------

  Widget _quickActionsGrid(BuildContext context, ProfileController profile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 10) / 2;

        final actions = <Widget>[
          _quickActionTile(
            context,
            width: itemWidth,
            icon: Icons.add_circle_outline_rounded,
            label: 'إضافة منتج',
            iconColor: AllineColors.primary,
            onTap: () =>
                _push(context, const AddProductTabView(fromHome: true)),
          ),
          _quickActionTile(
            context,
            width: itemWidth,
            icon: Icons.receipt_long_rounded,
            label: 'جميع الطلبات',
            iconColor: AllineColors.darkBlue,
            onTap: () => _openOrders(context, 0),
          ),
          _quickActionTile(
            context,
            width: itemWidth,
            icon: Icons.warehouse_rounded,
            label: 'إدارة المخزون',
            iconColor: AllineColors.orange,
            onTap: () => _push(context, const StockOutProductScreen()),
          ),
          _quickActionTile(
            context,
            width: itemWidth,
            icon: Icons.account_balance_wallet_rounded,
            label: 'المحفظة والسحب',
            iconColor: AllineColors.primary,
            onTap: () => _push(context, const WalletScreen()),
          ),
          if (profile.userInfoModel?.posActive == 1)
            _quickActionTile(
              context,
              width: itemWidth,
              icon: Icons.point_of_sale_rounded,
              label: 'نقطة البيع (POS)',
              iconColor: AllineColors.brightBlue,
              onTap: () => _push(context, const PosScreen()),
            ),
          _quickActionTile(
            context,
            width: itemWidth,
            icon: Icons.forum_rounded,
            label: 'الرسائل والمحادثات',
            iconColor: AllineColors.coolGray,
            onTap: () => _push(context, const InboxScreen()),
          ),
        ];

        return Wrap(spacing: 10, runSpacing: 10, children: actions);
      },
    );
  }

  Widget _quickActionTile(
    BuildContext context, {
    required double width,
    required IconData icon,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: width,
      child: Material(
        color: ColorResources.getCardBg(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: ColorResources.getBorder(context)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: _style(context, 13, bold: true),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 7. Recent Orders Preview ("آخر الطلبات")
  // ---------------------------------------------------------------------------

  Widget _recentOrdersSection(BuildContext context, List<Order>? recentOrders) {
    if (recentOrders == null) {
      return _information(
        context,
        'تعذر تحميل الطلبات الحديثة',
        retry: () =>
            context.read<OrderController>().getDashboardRecentOrders(),
      );
    }

    if (recentOrders.isEmpty) {
      return _panel(
        context,
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              const Icon(Icons.inbox_outlined,
                  size: 40, color: AllineColors.coolGray),
              const SizedBox(height: 8),
              Text(
                'لا توجد طلبات مسجلة بعد',
                style: _style(context, 15, bold: true),
              ),
              const SizedBox(height: 2),
              Text(
                'ستظهر الطلبات الجديدة هنا فور استلامها من العملاء.',
                style: _style(context, 12, muted: true),
              ),
            ],
          ),
        ),
      );
    }

    return _panel(
      context,
      Column(
        children: [
          for (var i = 0; i < recentOrders.length; i++) ...[
            _orderRow(context, recentOrders[i]),
            if (i < recentOrders.length - 1)
              Divider(color: ColorResources.getBorder(context), height: 16),
          ],
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    );
  }

  Widget _orderRow(BuildContext context, Order order) {
    final customer =
        '${order.customer?.fName ?? ''} ${order.customer?.lName ?? ''}'.trim();

    final (statusLabel, statusColor, statusBg) = switch (order.orderStatus) {
      'pending' => ('جديد', AllineColors.error, const Color(0xFFFEF2F2)),
      'confirmed' => ('مؤكد', AllineColors.primary, const Color(0xFFEFF6FF)),
      'processing' => ('قيد التجهيز', AllineColors.warning, const Color(0xFFFFFBEB)),
      'out_for_delivery' => ('في الطريق', const Color(0xFF8B5CF6), const Color(0xFFF5F3FF)),
      'delivered' => ('مكتمل', AllineColors.success, const Color(0xFFECFDF5)),
      'canceled' => ('ملغي', AllineColors.coolGray, const Color(0xFFF8FAFC)),
      'returned' => ('مرتجع', AllineColors.orange, const Color(0xFFFFF7ED)),
      _ => (order.orderStatus ?? 'غير معروف', AllineColors.coolGray, const Color(0xFFF8FAFC)),
    };

    final createdAt = DateTime.tryParse(order.createdAt ?? '')?.toLocal();
    final time = createdAt == null
        ? ''
        : '${createdAt.day}/${createdAt.month} • ${TimeOfDay.fromDateTime(createdAt).format(context)}';

    return InkWell(
      onTap: () => _push(context, OrderDetailsScreen(orderId: order.id)),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // Order Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AllineColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: AllineColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Order details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'طلب #${order.id}',
                        style: _style(context, 14, bold: true),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    customer.isEmpty ? 'عميل Alline' : customer,
                    style: _style(context, 12, muted: true),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (time.isNotEmpty)
                    Text(time, style: _style(context, 10.5, muted: true)),
                ],
              ),
            ),

            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  PriceConverter.convertPrice(context, order.orderAmount ?? 0),
                  style: const TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AllineColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(
                  Icons.chevron_left_rounded,
                  size: 18,
                  color: AllineColors.coolGray,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 8. Weekly Earnings Chart ("أداء الأرباح الأسبوعي")
  // ---------------------------------------------------------------------------

  Widget _earningsChartPanel(BuildContext context, BankInfoController bank) {
    final points = bank.dashboardWeekEarnings;
    if (points == null || points.isEmpty) {
      return _information(
          context, 'لا توجد بيانات أرباح كافية لعرض الرسم البياني الأسبوعي');
    }

    final values = points;
    final maxValue =
        values.fold<double>(0, (max, value) => value > max ? value : max);

    final dayLabels = ['السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];

    return _panel(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('أرباح آخر 7 أيام', style: _style(context, 13, muted: true)),
              const Spacer(),
              if (maxValue > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AllineColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'الأعلى: ${PriceConverter.convertPrice(context, maxValue)}',
                    style: const TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AllineColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),

          // Custom Bars
          SizedBox(
            height: 90,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < values.length; i++) ...[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: maxValue == 0
                                ? 6
                                : 6 + 68 * (values[i] / maxValue),
                            decoration: BoxDecoration(
                              color: values[i] == maxValue && maxValue > 0
                                  ? AllineColors.primary
                                  : AllineColors.primary.withValues(
                                      alpha: values[i] == 0 ? 0.12 : 0.45),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            i < dayLabels.length
                                ? dayLabels[i].substring(0, 3)
                                : 'يوم',
                            style: TextStyle(
                              fontFamily: 'AllineTajawal',
                              fontSize: 10,
                              fontWeight: values[i] == maxValue && maxValue > 0
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: values[i] == maxValue && maxValue > 0
                                  ? AllineColors.primary
                                  : ColorResources.getTextSubTitle(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'الأرباح الفعلية المحسوبة لمتجرك بحسب مبيعات الأسبوع',
            style: _style(context, 11, muted: true),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 9. Inventory Alerts ("المخزون والمنتجات")
  // ---------------------------------------------------------------------------

  Widget _inventoryPanel(BuildContext context, ProductController products) {
    final list = products.stockOutProductList;
    if (list == null) return _information(context, 'تعذر تحميل حالة المخزون');
    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFA7F3D0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AllineColors.success, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'جميع منتجاتك متوفرة بكميات كافية في المستودع 👍',
                style: const TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF065F46),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _panel(
      context,
      Column(
        children: [
          for (final product in list.take(3))
            InkWell(
              onTap: () =>
                  _push(context, ProductDetailsScreen(productModel: product)),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 42,
                        height: 42,
                        child: product.thumbnailFullUrl?.path?.isNotEmpty == true
                            ? Image.network(
                                product.thumbnailFullUrl!.path!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.inventory_2_outlined,
                                  color: AllineColors.orange,
                                ),
                              )
                            : const Icon(
                                Icons.inventory_2_outlined,
                                color: AllineColors.orange,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        product.name ?? 'منتج',
                        style: _style(context, 13, bold: true),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (product.currentStock == 0
                                ? AllineColors.error
                                : AllineColors.orange)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.currentStock == 0
                            ? 'نفد المخزون'
                            : 'متبقي ${product.currentStock ?? '—'} فقط',
                        style: TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: product.currentStock == 0
                              ? AllineColors.error
                              : AllineColors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    );
  }

  // ---------------------------------------------------------------------------
  // 10. Top Selling Products ("الأكثر مبيعًا")
  // ---------------------------------------------------------------------------

  Widget _topProductsPanel(BuildContext context, List<dynamic> topProducts) {
    return _panel(
      context,
      Column(
        children: [
          for (var i = 0; i < topProducts.length; i++) ...[
            _topProductRow(
              context,
              i + 1,
              topProducts[i].product?.name ?? 'منتج',
              topProducts[i].count ?? '0',
              topProducts[i].product?.thumbnailFullUrl?.path,
            ),
            if (i < topProducts.length - 1)
              Divider(color: ColorResources.getBorder(context), height: 16),
          ],
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    );
  }

  Widget _topProductRow(
    BuildContext context,
    int rank,
    String name,
    String count,
    String? imageUrl,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: rank == 1
                  ? AllineColors.orange
                  : AllineColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$rank',
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: rank == 1 ? Colors.white : AllineColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 38,
              height: 38,
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_outlined),
                    )
                  : const Icon(Icons.image_outlined),
            ),
          ),
          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Text(
              name,
              style: _style(context, 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Sales Count Pill
          Text(
            '$count مبيعًا',
            style: const TextStyle(
              fontFamily: 'AllineTajawal',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AllineColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 11. Wallet Summary Card ("المحفظة وسحب الأرباح")
  // ---------------------------------------------------------------------------

  Widget _walletCard(BuildContext context, ProfileController profile) {
    final wallet = profile.userInfoModel?.wallet;
    if (wallet == null) {
      return _information(context, 'بيانات المحفظة غير متاحة حاليًا');
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AllineColors.darkBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AllineColors.primary.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AllineColors.darkBlue.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'الرصيد المتاح للسحب',
                style: TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Total Earnings Amount
          Text(
            PriceConverter.convertPrice(context, wallet.totalEarning ?? 0),
            style: const TextStyle(
              fontFamily: 'AllineTajawal',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),

          // Divider
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.14),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'السحب المعلق',
                      style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      PriceConverter.convertPrice(
                          context, wallet.pendingWithdraw ?? 0),
                      style: const TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Withdraw button
              FilledButton(
                onPressed: () => _push(context, const WalletScreen()),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AllineColors.darkBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
                child: const Text(
                  'سحب الأرباح',
                  style: TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Status Modal Bottom Sheet & Navigation
  // ---------------------------------------------------------------------------

  Widget _information(
    BuildContext context,
    String message, {
    VoidCallback? retry,
  }) {
    return _panel(
      context,
      Row(
        children: [
          Expanded(
            child: Text(message, style: _style(context, 13, muted: true)),
          ),
          if (retry != null)
            TextButton(
              onPressed: retry,
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontFamily: 'AllineTajawal',
                  color: AllineColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openOrders(BuildContext context, int tab) {
    context.read<OrderController>().setIndex(context, tab);
    onNavigate(1);
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _statusSheet(BuildContext context, ShopController shop) {
    final open = shop.shopModel?.temporaryClose == true;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: ColorResources.getCardBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'إدارة حالة المتجر',
                style: _style(context, 18, bold: true),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                open
                    ? 'عند الإغلاق المؤقت، لن يتمكن العملاء من تقديم طلبات جديدة حتى إعادة الفتح.'
                    : 'عند فتح المتجر، سيظهر متجرك نشطاً ويمكن للعملاء تقديم طلبات شراء.',
                style: _style(context, 13, muted: true),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Toggle Button
              FilledButton.icon(
                icon: Icon(open
                    ? Icons.store_mall_directory_outlined
                    : Icons.storefront_rounded),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      open ? AllineColors.error : AllineColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(sheetContext);
                  shop.shopTemporaryClose(context, open ? 1 : 0);
                },
                label: Text(
                  open ? 'إغلاق المتجر مؤقتًا' : 'فتح المتجر واستقبال الطلبات',
                  style: const TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Vacation Mode Option
              OutlinedButton.icon(
                icon: const Icon(Icons.beach_access_rounded),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: ColorResources.getBorder(context)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(sheetContext);
                  _push(context, const VacationModeScreen());
                },
                label: Text(
                  'إعدادات وضع الإجازة',
                  style: _style(context, 14, bold: true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
