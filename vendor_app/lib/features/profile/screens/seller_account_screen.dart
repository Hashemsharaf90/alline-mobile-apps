import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/ai_chat/screens/ai_chat_screen.dart';
import 'package:sixvalley_vendor_app/features/bank_info/screens/bank_info_screen.dart';
import 'package:sixvalley_vendor_app/features/coupon/screens/coupon_list_screen.dart';
import 'package:sixvalley_vendor_app/features/dashboard/screens/nav_bar_screen.dart';
import 'package:sixvalley_vendor_app/features/delivery_man/screens/delivery_man_setup_screen.dart';
import 'package:sixvalley_vendor_app/features/menu/widgets/sign_out_confirmation_dialog_widget.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/features/profile/screens/profile_view_screen.dart';
import 'package:sixvalley_vendor_app/features/refund/screens/refund_screen.dart';
import 'package:sixvalley_vendor_app/features/review/screens/product_review_screen.dart';
import 'package:sixvalley_vendor_app/features/settings/screens/setting_screen.dart';
import 'package:sixvalley_vendor_app/features/shop/controllers/shop_controller.dart';
import 'package:sixvalley_vendor_app/features/shop/screens/shop_screen.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/features/wallet/screens/wallet_screen.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';
import 'package:url_launcher/url_launcher.dart';

class SellerAccountScreen extends StatelessWidget {
  const SellerAccountScreen({super.key});

  Future<void> _openWhatsAppSupport() async {
    final Uri appUri = Uri.parse(
      'whatsapp://send?phone=967775667733&text=${Uri.encodeComponent('مرحباً خدمة دعم تجار Alline، أحتاج إلى استفسار/مساعدة بخصوص متجري.')}',
    );
    final Uri webUri = Uri.parse(
      'https://wa.me/967775667733?text=${Uri.encodeComponent('مرحباً خدمة دعم تجار Alline، أحتاج إلى استفسار/مساعدة بخصوص متجري.')}',
    );

    try {
      final bool launched = await launchUrl(appUri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('Failed to launch WhatsApp: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final configModel = Provider.of<SplashController>(context, listen: false).configModel;

    return Scaffold(
      backgroundColor: AllineColors.softBlue,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'إدارة الحساب والمتجر',
          style: TextStyle(
            fontFamily: 'AllineTajawal',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AllineColors.navyText,
          ),
        ),
      ),
      body: Consumer2<ProfileController, ShopController>(
        builder: (context, profileCtrl, shopCtrl, _) {
          final seller = profileCtrl.userInfoModel;
          final shop = shopCtrl.shopModel;
          final wallet = seller?.wallet;

          final String storeName = shop?.name ??
              ((seller?.fName != null) ? '${seller!.fName} ${seller.lName ?? ""}'.trim() : 'متجري في Alline');
          final String phone = seller?.phone ?? '';
          final String? logoUrl = shop?.imageFullUrl?.path ?? seller?.imageFullUrl?.path;
          final bool isVacation = shop?.vacationStatus ?? false;
          final bool isTemporaryClosed = shop?.temporaryClose ?? false;

          return RefreshIndicator(
            color: AllineColors.primary,
            onRefresh: () async {
              await profileCtrl.getSellerInfo();
              if (context.mounted) {
                await shopCtrl.getShopInfo();
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Store & Seller Profile Header Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AllineColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: AllineColors.darkBlue.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AllineColors.softBlue,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AllineColors.border),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: (logoUrl != null && logoUrl.isNotEmpty)
                                    ? Image.network(
                                        logoUrl,
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
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    storeName,
                                    style: const TextStyle(
                                      fontFamily: 'AllineTajawal',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AllineColors.navyText,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (phone.isNotEmpty) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      phone,
                                      style: const TextStyle(
                                        fontFamily: 'AllineTajawal',
                                        fontSize: 12,
                                        color: AllineColors.coolGray,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 5),
                                  // Store status badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (isVacation || isTemporaryClosed)
                                          ? const Color(0xFFFEF5E7)
                                          : const Color(0xFFE8F7EE),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isVacation
                                          ? 'في إجازة'
                                          : (isTemporaryClosed ? 'مغلق مؤقتاً' : 'المتجر نشط ومتاح'),
                                      style: TextStyle(
                                        fontFamily: 'AllineTajawal',
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: (isVacation || isTemporaryClosed)
                                            ? AllineColors.orange
                                            : AllineColors.success,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: AllineColors.border),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ShopScreen()),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.store_rounded, size: 16, color: AllineColors.primary),
                                    SizedBox(width: 6),
                                    Text(
                                      'إعدادات المتجر',
                                      style: TextStyle(
                                        fontFamily: 'AllineTajawal',
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AllineColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(height: 18, width: 1, color: AllineColors.border),
                            Expanded(
                              child: InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ProfileScreenView()),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.person_outline_rounded, size: 16, color: AllineColors.primary),
                                    SizedBox(width: 6),
                                    Text(
                                      'الملف الشخصي',
                                      style: TextStyle(
                                        fontFamily: 'AllineTajawal',
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AllineColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Wallet & Finance Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AllineColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.account_balance_wallet_rounded, color: AllineColors.primary, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'المحفظة والأرباح',
                                  style: TextStyle(
                                    fontFamily: 'AllineTajawal',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AllineColors.navyText,
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const WalletScreen()),
                              ),
                              child: const Text(
                                'عرض التفاصيل >',
                                style: TextStyle(
                                  fontFamily: 'AllineTajawal',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AllineColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'الرصيد القابل للسحب',
                                    style: TextStyle(
                                      fontFamily: 'AllineTajawal',
                                      fontSize: 11,
                                      color: AllineColors.coolGray,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    PriceConverter.convertPrice(
                                      context,
                                      (wallet?.totalEarning ?? 0) - (wallet?.withdrawn ?? 0),
                                    ),
                                    style: const TextStyle(
                                      fontFamily: 'AllineTajawal',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AllineColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'إجمالي المسحوبات',
                                    style: TextStyle(
                                      fontFamily: 'AllineTajawal',
                                      fontSize: 11,
                                      color: AllineColors.coolGray,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    PriceConverter.convertPrice(
                                      context,
                                      wallet?.withdrawn ?? 0,
                                    ),
                                    style: const TextStyle(
                                      fontFamily: 'AllineTajawal',
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AllineColors.navyText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. Quick Operations Section
                  _buildSectionTitle('عمليات المتجر'),
                  _buildSectionCard(
                    children: [
                      _buildMenuItem(
                        icon: Icons.account_balance_rounded,
                        title: 'البيانات البنكية وطرق الاستلام',
                        subtitle: 'إدارة حساباتك البنكية وبوابات الدفع',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BankInfoScreen()),
                        ),
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.two_wheeler_rounded,
                        title: 'إدارة مندوبي التوصيل',
                        subtitle: 'تعيين المندوبين ومتابعة كشف الحسابات',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const DeliveryManSetupScreen()),
                        ),
                      ),
                      if (configModel?.posActive == 1 && seller?.posActive == 1) ...[
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.point_of_sale_rounded,
                          title: 'نقطة البيع السريعة (POS)',
                          subtitle: 'إصدار فواتير فورية وطباعة حرارية',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NavBarScreen()),
                          ),
                        ),
                      ],
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.local_offer_rounded,
                        title: 'القسائم والعروض الترويجية',
                        subtitle: 'إدارة كوبونات الخصم والتخفيضات',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CouponListScreen()),
                        ),
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.replay_rounded,
                        title: 'طلبات الاسترداد',
                        subtitle: 'متابعة وفحص طلبات استرجاع المنتجات',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RefundScreen(fromNotification: false)),
                        ),
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.star_rate_rounded,
                        title: 'تقييمات المتجر والمنتجات',
                        subtitle: 'آراء وملاحظات المشترين والرد عليها',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProductReviewScreen()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 4. Tools & AI
                  _buildSectionTitle('الأدوات والإعدادات'),
                  _buildSectionCard(
                    children: [
                      _buildMenuItem(
                        icon: Icons.smart_toy_outlined,
                        iconColor: AllineColors.orange,
                        iconBg: const Color(0xFFFEF5E7),
                        title: 'مساعد Alline الذكي للتاجر',
                        subtitle: 'أدوات مساعدة لتوليد الوصف وتحليل المبيعات',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AiChatScreen()),
                        ),
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.settings_rounded,
                        title: 'إعدادات التطبيق',
                        subtitle: 'اللغة والإشعارات وتفضيلات التاجر',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 5. Help & Support Section
                  _buildSectionTitle('المساعدة وخدمة التجار'),
                  _buildSectionCard(
                    children: [
                      _buildMenuItem(
                        icon: Icons.chat_rounded,
                        iconColor: AllineColors.success,
                        iconBg: const Color(0xFFE8F7EE),
                        title: 'واتساب خدمة تجار Alline',
                        subtitle: '+967 775 667 733 — دعم فني مباشر',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F7EE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'متاح الآن',
                            style: TextStyle(
                              fontFamily: 'AllineTajawal',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AllineColors.success,
                            ),
                          ),
                        ),
                        onTap: _openWhatsAppSupport,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 6. Sign Out Button
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (_) => const SignOutConfirmationDialogWidget(),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AllineColors.error.withValues(alpha: 0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: AllineColors.error.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.logout_rounded, size: 22, color: AllineColors.error),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'تسجيل الخروج',
                                  style: TextStyle(
                                    fontFamily: 'AllineTajawal',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AllineColors.error,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'الخروج من حساب التاجر على هذا الهاتف',
                                  style: TextStyle(
                                    fontFamily: 'AllineTajawal',
                                    fontSize: 11,
                                    color: AllineColors.coolGray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_left_rounded, size: 20, color: AllineColors.error),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 7. Footer
                  const Center(
                    child: Column(
                      children: [
                        Text(
                          'تطبيق التاجر — منظومة Alline التجارية',
                          style: TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AllineColors.coolGray,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'الإصدار ${AppConstants.appVersion}',
                          style: TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 11,
                            color: AllineColors.coolGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'AllineTajawal',
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AllineColors.navyText,
        ),
      ),
    );
  }

  Widget _buildSectionCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AllineColors.border),
        boxShadow: [
          BoxShadow(
            color: AllineColors.darkBlue.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AllineColors.softBlue,
      indent: 68,
      endIndent: 14,
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = AllineColors.primary,
    Color iconBg = const Color(0xFFF4F8FE),
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AllineColors.border),
              ),
              child: Center(
                child: Icon(icon, size: 22, color: iconColor),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AllineColors.navyText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 12,
                      color: AllineColors.coolGray,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              trailing,
              const SizedBox(width: 8),
            ],
            const Icon(
              Icons.chevron_left_rounded,
              size: 20,
              color: AllineColors.coolGray,
            ),
          ],
        ),
      ),
    );
  }
}
