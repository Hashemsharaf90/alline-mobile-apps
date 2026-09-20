import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/addProduct/screens/add_product_tab_view_screen.dart';
import 'package:sixvalley_vendor_app/features/bank_info/controllers/bank_info_controller.dart';
import 'package:sixvalley_vendor_app/features/chat/screens/inbox_screen.dart';
import 'package:sixvalley_vendor_app/features/order/controllers/order_controller.dart';
import 'package:sixvalley_vendor_app/features/product/screens/product_list_screen.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/features/review/screens/product_review_screen.dart';
import 'package:sixvalley_vendor_app/features/shop/screens/shop_screen.dart';
import 'package:sixvalley_vendor_app/features/wallet/screens/wallet_screen.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';

class AllineVendorDashboardWidget extends StatelessWidget {
  final Function? callback;
  const AllineVendorDashboardWidget({super.key, this.callback});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProfileController, BankInfoController>(
      builder: (context, profileCtrl, bankCtrl, _) {
        final sellerInfo = profileCtrl.userInfoModel;
        final analytics = bankCtrl.businessAnalyticsFilterData;

        final pendingCount = analytics?.pending ?? 0;
        final processingCount = analytics?.processing ?? 0;
        final deliveredCount = analytics?.delivered ?? 0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Store Header & Live Status Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFF7931A).withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Store Avatar
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: sellerInfo?.imageFullUrl?.path != null && sellerInfo!.imageFullUrl!.path!.isNotEmpty
                            ? Image.network(
                                sellerInfo.imageFullUrl!.path!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.storefront_rounded,
                                  color: Color(0xFF0F172A),
                                  size: 28,
                                ),
                              )
                            : const Icon(
                                Icons.storefront_rounded,
                                color: Color(0xFF0F172A),
                                size: 28,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Store Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sellerInfo?.fName != null ? '${sellerInfo!.fName} ${sellerInfo.lName ?? ""}' : 'متجر Alline المعتمد',
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'لوحة تحكم البائع المباشرة',
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Open / Active Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF10B981)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'المتجر نشط 🟢',
                            style: robotoBold.copyWith(
                              color: const Color(0xFF10B981),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 1.5 Quick Wallet & Earnings Ribbon
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
                    gradient: const LinearGradient(
                      colors: [Color(0xFF065F46), Color(0xFF047857)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF059669).withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
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
                                color: Colors.white.withValues(alpha: 0.85),
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
                                color: Colors.white,
                                fontSize: Dimensions.fontSizeLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'سحب أرباح',
                              style: robotoBold.copyWith(
                                color: const Color(0xFF065F46),
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 11,
                              color: Color(0xFF065F46),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // 2. Operational Live KPI Metrics (3 big cards)
              Row(
                children: [
                  // Pending Orders
                  Expanded(
                    child: _buildMetricCard(
                      title: 'طلبات جديدة',
                      count: '$pendingCount',
                      badge: 'تنبيه 🔥',
                      gradient: const [Color(0xFFEF4444), Color(0xFFDC2626)],
                      icon: Icons.notifications_active_rounded,
                      onTap: () {
                        Provider.of<OrderController>(context, listen: false).setIndex(context, 1);
                        if (callback != null) callback!();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Processing Orders
                  Expanded(
                    child: _buildMetricCard(
                      title: 'قيد التجهيز',
                      count: '$processingCount',
                      badge: 'جاري ⏳',
                      gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                      icon: Icons.outdoor_grill_rounded,
                      onTap: () {
                        Provider.of<OrderController>(context, listen: false).setIndex(context, 2);
                        if (callback != null) callback!();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Delivered Orders
                  Expanded(
                    child: _buildMetricCard(
                      title: 'تم التسليم',
                      count: '$deliveredCount',
                      badge: 'اليوم ✅',
                      gradient: const [Color(0xFF10B981), Color(0xFF059669)],
                      icon: Icons.task_alt_rounded,
                      onTap: () {
                        Provider.of<OrderController>(context, listen: false).setIndex(context, 3);
                        if (callback != null) callback!();
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 3. Quick Actions Header
              Text(
                'الخدمات والإدارة السريعة ⚡',
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 10),

              // 4. Quick Actions Grid (6 Clean Distinctive Cards)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.05,
                children: [
                  _buildActionTile(
                    context,
                    title: 'إضافة منتج',
                    subtitle: 'صنف جديد',
                    icon: Icons.add_circle_outline_rounded,
                    color: const Color(0xFFE8115B),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddProductTabView(fromHome: true)),
                      );
                    },
                  ),
                  _buildActionTile(
                    context,
                    title: 'قائمة المنتجات',
                    subtitle: 'تعديل المخزون',
                    icon: Icons.inventory_2_outlined,
                    color: const Color(0xFF0284C7),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProductListMenuScreen()),
                      );
                    },
                  ),
                  _buildActionTile(
                    context,
                    title: 'المحادثات',
                    subtitle: 'العملاء والمناديب',
                    icon: Icons.chat_bubble_outline_rounded,
                    color: const Color(0xFF8B5CF6),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const InboxScreen()),
                      );
                    },
                  ),
                  _buildActionTile(
                    context,
                    title: 'الأرباح والمحفظة',
                    subtitle: 'السحب المالي',
                    icon: Icons.account_balance_wallet_outlined,
                    color: const Color(0xFF10B981),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WalletScreen()),
                      );
                    },
                  ),
                  _buildActionTile(
                    context,
                    title: 'تقييمات المتجر',
                    subtitle: 'آراء العملاء',
                    icon: Icons.star_outline_rounded,
                    color: const Color(0xFFF59E0B),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProductReviewScreen()),
                      );
                    },
                  ),
                  _buildActionTile(
                    context,
                    title: 'إعدادات المتجر',
                    subtitle: 'الموقع والدوام',
                    icon: Icons.storefront_outlined,
                    color: const Color(0xFF64748B),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ShopScreen()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String count,
    required String badge,
    required List<Color> gradient,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: robotoBold.copyWith(fontSize: 8, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              count,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeExtraLarge,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: robotoRegular.copyWith(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.9),
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
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
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: robotoRegular.copyWith(
                fontSize: 8,
                color: const Color(0xFF94A3B8),
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
}
