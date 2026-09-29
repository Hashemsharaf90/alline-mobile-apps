import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/addProduct/screens/add_product_tab_view_screen.dart';
import 'package:sixvalley_vendor_app/features/bank_info/controllers/bank_info_controller.dart';
import 'package:sixvalley_vendor_app/features/chat/screens/inbox_screen.dart';
import 'package:sixvalley_vendor_app/features/order/controllers/order_controller.dart';
import 'package:sixvalley_vendor_app/features/pos/screens/pos_screen.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/product_controller.dart';
import 'package:sixvalley_vendor_app/features/product/screens/stock_out_product_screen.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/features/shop/controllers/shop_controller.dart';
import 'package:sixvalley_vendor_app/features/shop/screens/vacation_mode_setup_screen.dart';
import 'package:sixvalley_vendor_app/features/wallet/screens/wallet_screen.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class AllineVendorDashboardWidget extends StatelessWidget {
  final Function? callback;
  const AllineVendorDashboardWidget({super.key, this.callback});

  @override
  Widget build(BuildContext context) {
    return Consumer4<ProfileController, BankInfoController, ProductController, ShopController>(
      builder: (context, profileCtrl, bankCtrl, productCtrl, shopCtrl, _) {
        final sellerInfo = profileCtrl.userInfoModel;
        final analytics = bankCtrl.businessAnalyticsFilterData;

        final pendingCount = analytics?.pending ?? 0;
        final processingCount = analytics?.processing ?? 0;
        final lowStockCount = productCtrl.stockLimitStatus?.productCount ?? 0;

        final storeName = (shopCtrl.shopModel?.name != null && shopCtrl.shopModel!.name!.isNotEmpty)
            ? shopCtrl.shopModel!.name!
            : (sellerInfo?.fName != null ? '${sellerInfo!.fName} ${sellerInfo.lName ?? ""}' : 'متجر Alline');

        final isShopActive = !(shopCtrl.shopModel?.temporaryClose ?? false);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Store Header & Live Status Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: const [AllineColors.primary, AllineColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AllineColors.secondary.withValues(alpha: 0.28),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Store Avatar
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: sellerInfo?.imageFullUrl?.path != null && sellerInfo!.imageFullUrl!.path!.isNotEmpty
                            ? Image.network(
                                sellerInfo.imageFullUrl!.path!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.storefront_rounded,
                                  color: AllineColors.primary,
                                  size: 30,
                                ),
                              )
                            : const Icon(
                                Icons.storefront_rounded,
                                color: AllineColors.primary,
                                size: 30,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Store Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'مرحباً، $storeName',
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified_rounded,
                                color: Color(0xFF60A5FA),
                                size: 16,
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'لوحة تحكم البائع المباشرة • Alline اليمن',
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Interactive Open / Active Status Pill
                    InkWell(
                      onTap: () => _showStoreStatusDialog(context, shopCtrl),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isShopActive
                              ? AllineColors.success.withValues(alpha: 0.2)
                              : AllineColors.danger.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isShopActive ? AllineColors.success : AllineColors.danger,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isShopActive ? AllineColors.success : AllineColors.danger,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isShopActive ? 'نشط 🟢' : 'مغلق 🔴',
                              style: robotoBold.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Needs Attention Section (Alerts for Pending, Processing, Low Stock)
              if (pendingCount > 0 || processingCount > 0 || lowStockCount > 0) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD97706).withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.bolt_rounded, color: Color(0xFFD97706), size: 16),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'يحتاج انتباهك الآن ⚡',
                            style: robotoBold.copyWith(fontSize: 13, color: AllineColors.navyText),
                          ),
                        ],
                      ),
                      if (pendingCount > 0)
                        _buildAttentionItem(
                          context,
                          icon: Icons.notifications_active_rounded,
                          color: AllineColors.danger,
                          text: 'لديك $pendingCount طلبات جديدة تحتاج موافقتك',
                          buttonLabel: 'مراجعة',
                          onTap: () {
                            Provider.of<OrderController>(context, listen: false).setIndex(context, 1);
                            if (callback != null) callback!();
                          },
                        ),
                      if (processingCount > 0)
                        _buildAttentionItem(
                          context,
                          icon: Icons.hourglass_top_rounded,
                          color: const Color(0xFFF59E0B),
                          text: 'لديك $processingCount طلبات قيد التجهيز تحتاج تسليم للمندوب',
                          buttonLabel: 'متابعة',
                          onTap: () {
                            Provider.of<OrderController>(context, listen: false).setIndex(context, 2);
                            if (callback != null) callback!();
                          },
                        ),
                      if (lowStockCount > 0)
                        _buildAttentionItem(
                          context,
                          icon: Icons.warning_amber_rounded,
                          color: const Color(0xFFEA580C),
                          text: 'لديك $lowStockCount منتجات أوشكت على النفاد من المخزون',
                          buttonLabel: 'تحديث',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const StockOutProductScreen()),
                            );
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // 2. Quick Wallet & Earnings Summary Banner
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WalletScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AllineColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: AllineColors.secondary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          color: AllineColors.secondary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'رصيد المحفظة والأرباح 💰',
                              style: robotoRegular.copyWith(
                                color: AllineColors.textLight,
                                fontSize: Dimensions.fontSizeExtraSmall,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              PriceConverter.convertPrice(
                                context,
                                sellerInfo?.wallet?.totalEarning ?? 0,
                              ),
                              style: robotoBold.copyWith(
                                color: AllineColors.textDark,
                                fontSize: Dimensions.fontSizeLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AllineColors.secondary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'سحب أرباح',
                              style: robotoBold.copyWith(
                                color: Colors.white,
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 10,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // 3. Operational Live KPI Metrics (4 Key Stats in 2x2 Grid)
              Row(
                children: [
                  // 1. Today's Sales
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      title: 'مبيعات اليوم',
                      count: PriceConverter.convertPrice(
                        context,
                        (sellerInfo?.wallet?.withdrawn != null)
                            ? (sellerInfo?.wallet?.totalEarning ?? 0)
                            : 0,
                      ),
                      badge: 'أرباح 📈',
                      icon: Icons.payments_rounded,
                      color: AllineColors.secondary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const WalletScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),

                  // 2. New Orders
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      title: 'طلبات جديدة',
                      count: '$pendingCount',
                      badge: 'تنبيه 🔥',
                      icon: Icons.notifications_active_rounded,
                      color: AllineColors.danger,
                      onTap: () {
                        Provider.of<OrderController>(context, listen: false).setIndex(context, 1);
                        if (callback != null) callback!();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  // 3. Processing Orders
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      title: 'قيد التجهيز',
                      count: '$processingCount',
                      badge: 'جاري ⏳',
                      icon: Icons.pending_actions_rounded,
                      color: const Color(0xFFF59E0B),
                      onTap: () {
                        Provider.of<OrderController>(context, listen: false).setIndex(context, 2);
                        if (callback != null) callback!();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),

                  // 4. Low Stock Products
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      title: 'منخفض المخزون',
                      count: '$lowStockCount',
                      badge: 'مخزون ⚠️',
                      icon: Icons.warning_amber_rounded,
                      color: const Color(0xFFD97706),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const StockOutProductScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 4. Quick Actions Header (4 Action Buttons)
              Text(
                'الإجراءات السريعة ⚡',
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 10),

              // 4 Quick Actions Grid (4 Distinctive Cards)
              Row(
                children: [
                  // Action 1: Add Product
                  Expanded(
                    child: _buildActionTile(
                      context,
                      title: 'إضافة منتج',
                      subtitle: 'صنف جديد',
                      icon: Icons.add_box_rounded,
                      color: AllineColors.secondary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddProductTabView(fromHome: true)),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Action 2: Pending Orders
                  Expanded(
                    child: _buildActionTile(
                      context,
                      title: 'الطلبات المعلقة',
                      subtitle: '$pendingCount طلب',
                      icon: Icons.assignment_late_rounded,
                      color: AllineColors.danger,
                      onTap: () {
                        Provider.of<OrderController>(context, listen: false).setIndex(context, 1);
                        if (callback != null) callback!();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Action 3: POS
                  Expanded(
                    child: _buildActionTile(
                      context,
                      title: 'نقطة البيع POS',
                      subtitle: 'كاشير مباشر',
                      icon: Icons.point_of_sale_rounded,
                      color: AllineColors.success,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PosScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Action 4: Customer Chat
                  Expanded(
                    child: _buildActionTile(
                      context,
                      title: 'المحادثات',
                      subtitle: 'العملاء والمناديب',
                      icon: Icons.chat_bubble_rounded,
                      color: const Color(0xFF8B5CF6),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const InboxScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String count,
    required String badge,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: robotoBold.copyWith(fontSize: 9, color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              count,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall,
                color: AllineColors.textLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AllineColors.borderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: robotoBold.copyWith(
                fontSize: 11,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: robotoRegular.copyWith(
                fontSize: 8,
                color: AllineColors.textLight,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttentionItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String text,
    required String buttonLabel,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                buttonLabel,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStoreStatusDialog(BuildContext context, ShopController shopCtrl) {
    final isShopActive = !(shopCtrl.shopModel?.temporaryClose ?? false);
    final isVacation = shopCtrl.shopModel?.vacationStatus ?? false;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).cardColor,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isShopActive ? AllineColors.success : AllineColors.danger).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isShopActive ? Icons.storefront_rounded : Icons.store_mall_directory_outlined,
                        color: isShopActive ? AllineColors.success : AllineColors.danger,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'حالة المتجر والتشغيل',
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                          ),
                          Text(
                            isVacation
                                ? 'المتجر حالياً في وضع الإجازة'
                                : (isShopActive ? 'المتجر متاح لاستقبال طلبات العملاء' : 'المتجر مغلق مؤقتاً ولا يستقبل طلبات جديدة'),
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: AllineColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isShopActive ? AllineColors.danger : AllineColors.success,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: Icon(
                    isShopActive ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
                    color: Colors.white,
                  ),
                  label: Text(
                    isShopActive ? 'إغلاق المتجر مؤقتاً' : 'إعادة فتح وتنشيط المتجر الآن',
                    style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault),
                  ),
                  onPressed: () {
                    shopCtrl.shopTemporaryClose(bottomSheetContext, isShopActive ? 1 : 0);
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(color: AllineColors.secondary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.beach_access_rounded, color: AllineColors.secondary),
                  label: Text(
                    'إعدادات وضع الإجازة (Vacation Mode)',
                    style: robotoBold.copyWith(color: AllineColors.secondary, fontSize: Dimensions.fontSizeDefault),
                  ),
                  onPressed: () {
                    Navigator.pop(bottomSheetContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VacationModeScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
