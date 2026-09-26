import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/not_logged_in_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/screens/global_shopping_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/screens/my_global_orders_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/more/widgets/logout_confirm_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/controllers/notification_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/business_pages_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/wishlist/controllers/wishlist_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

/// Alline Account Screen / "حسابي"
///
/// Production-Ready Central Navigation Hub for Alline e-commerce marketplace.
/// Arabic-first, Fully RTL, Yemen-focused, and adhering strictly to the Alline design system.
class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authController = Provider.of<AuthController>(context, listen: false);
    if (authController.isLoggedIn()) {
      Provider.of<ProfileController>(context, listen: false)
          .getUserInfo(context);
      Provider.of<WishListController>(context, listen: false).getWishList('');
      Provider.of<NotificationController>(context, listen: false)
          .getNotificationList(1);
    }
  }

  Future<void> _onRefresh() async {
    _loadData();
  }

  Future<void> _openWhatsAppSupport() async {
    final Uri appUri = Uri.parse(
      'whatsapp://send?phone=967775667733&text=${Uri.encodeComponent('مرحباً خدمة عملاء Alline، أحتاج إلى مساعدة بخصوص حسابي/طلبي.')}',
    );
    final Uri webUri = Uri.parse(
      'https://wa.me/967775667733?text=${Uri.encodeComponent('مرحباً خدمة عملاء Alline، أحتاج إلى مساعدة بخصوص حسابي/طلبي.')}',
    );

    try {
      final bool launched =
          await launchUrl(appUri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('Failed to open WhatsApp: $e');
      }
    }
  }

  void _navigateOrLogin(
      BuildContext context, bool isGuest, VoidCallback onLoggedIn) {
    if (isGuest) {
      showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (_) => NotLoggedInBottomSheetWidget(
          fromPage: '${RouterHelper.dashboardScreen}?page=more',
        ),
      );
    } else {
      onLoggedIn();
    }
  }

  BusinessPageModel? _getPageBySlug(
      String slug, List<BusinessPageModel>? pagesList) {
    if (pagesList != null && pagesList.isNotEmpty) {
      for (final page in pagesList) {
        if (page.slug == slug) {
          return page;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AllineThemeColors.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('حسابي', style: Theme.of(context).textTheme.titleLarge),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: InkWell(
              onTap: _openWhatsAppSupport,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F7EE),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AllineColors.success.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_rounded,
                      size: 14,
                      color: AllineColors.success,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'الدعم',
                      style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AllineColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<AuthController>(
        builder: (context, authController, _) {
          final bool isGuest = !authController.isLoggedIn();

          return Consumer<ProfileController>(
            builder: (context, profileController, _) {
              return Consumer<SplashController>(
                builder: (context, splashController, _) {
                  return Consumer<WishListController>(
                    builder: (context, wishListController, _) {
                      return Consumer<NotificationController>(
                        builder: (context, notificationController, _) {
                          return RefreshIndicator(
                            color: Theme.of(context).colorScheme.primary,
                            onRefresh: _onRefresh,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 1. Profile Header
                                  _buildProfileHeader(
                                    context,
                                    profileController,
                                    isGuest,
                                  ),
                                  const SizedBox(height: 14),

                                  // 2. Account Summary (When logged in)
                                  if (!isGuest) ...[
                                    _buildAccountSummary(
                                      context,
                                      profileController,
                                      wishListController,
                                    ),
                                    const SizedBox(height: 18),
                                  ],

                                  // 3. Quick Access Section
                                  _buildSectionTitle('الوصول السريع'),
                                  _buildSectionCard(
                                    children: [
                                      _buildMenuItem(
                                        icon: Icons.receipt_long_rounded,
                                        title: 'الطلبات',
                                        subtitle:
                                            'تابع طلباتك الحالية وتفاصيل الشحن',
                                        onTap: () {
                                          _navigateOrLogin(
                                            context,
                                            isGuest,
                                            () => RouterHelper
                                                .getOrderScreenRoute(
                                              isBackButtonExist: true,
                                            ),
                                          );
                                        },
                                      ),
                                      _buildDivider(),
                                      _buildMenuItem(
                                        icon: Icons
                                            .account_balance_wallet_rounded,
                                        title: 'المحفظة',
                                        subtitle: isGuest
                                            ? 'إدارة رصيدك وعملياتك المالية'
                                            : (profileController.userInfoModel
                                                        ?.walletBalance !=
                                                    null
                                                ? 'الرصيد: ${PriceConverter.convertPrice(context, profileController.userInfoModel!.walletBalance)}'
                                                : 'إدارة رصيدك وعملياتك المالية'),
                                        onTap: () {
                                          _navigateOrLogin(
                                            context,
                                            isGuest,
                                            () => RouterHelper.getWalletRoute(
                                              action: RouteAction.push,
                                              isBackButtonExist: true,
                                            ),
                                          );
                                        },
                                      ),
                                      _buildDivider(),
                                      _buildMenuItem(
                                        icon: Icons.location_on_rounded,
                                        title: 'العناوين',
                                        subtitle: 'إدارة وتعديل عناوين التوصيل',
                                        onTap: () {
                                          _navigateOrLogin(
                                            context,
                                            isGuest,
                                            () => RouterHelper
                                                .getAddressListScreen(
                                              action: RouteAction.push,
                                            ),
                                          );
                                        },
                                      ),
                                      _buildDivider(),
                                      _buildMenuItem(
                                        icon: Icons.favorite_rounded,
                                        title: 'المفضلة',
                                        subtitle: 'المنتجات التي قمت بحفظها',
                                        trailing: (!isGuest &&
                                                (wishListController
                                                            .wishList?.length ??
                                                        0) >
                                                    0)
                                            ? Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: colors.background,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: AllineColors.accent
                                                        .withValues(alpha: 0.4),
                                                  ),
                                                ),
                                                child: Text(
                                                  '${wishListController.wishList!.length}',
                                                  style: const TextStyle(
                                                    fontFamily: 'AllineTajawal',
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: AllineColors.accent,
                                                  ),
                                                ),
                                              )
                                            : null,
                                        onTap: () {
                                          _navigateOrLogin(
                                            context,
                                            isGuest,
                                            () => RouterHelper.getWishListRoute(
                                              action: RouteAction.push,
                                            ),
                                          );
                                        },
                                      ),
                                      _buildDivider(),
                                      _buildMenuItem(
                                        icon: Icons.public_rounded,
                                        title: 'التسوق الدولي',
                                        subtitle:
                                            'شراء من المتاجر العالمية بضمان Alline',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const GlobalShoppingScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                      if (!isGuest) ...[
                                        _buildDivider(),
                                        _buildMenuItem(
                                          icon: Icons.history_edu_rounded,
                                          title: 'طلباتي الدولية',
                                          subtitle:
                                              'متابعة طلبات الشراء الدولي وحالاتها',
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const MyGlobalOrdersScreen(),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 18),

                                  // 4. Account & Preferences Section
                                  _buildSectionTitle('الحساب والتفضيلات'),
                                  _buildSectionCard(
                                    children: [
                                      _buildMenuItem(
                                        icon: Icons.notifications_rounded,
                                        title: 'الإشعارات',
                                        subtitle:
                                            'تنبيهات العروض وتحديثات الطلبات',
                                        trailing: (!isGuest &&
                                                (notificationController
                                                            .notificationModel
                                                            ?.newNotificationItem ??
                                                        0) >
                                                    0)
                                            ? Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AllineColors.accent,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  '${notificationController.notificationModel!.newNotificationItem}',
                                                  style: const TextStyle(
                                                    fontFamily: 'AllineTajawal',
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              )
                                            : null,
                                        onTap: () {
                                          _navigateOrLogin(
                                            context,
                                            isGuest,
                                            () => RouterHelper
                                                .getNotificationRoute(
                                              action: RouteAction.push,
                                            ),
                                          );
                                        },
                                      ),
                                      _buildDivider(),
                                      _buildMenuItem(
                                        icon: Icons.settings_rounded,
                                        title: 'الإعدادات',
                                        subtitle: 'اللغة والإشعارات والتفضيلات',
                                        onTap: () {
                                          RouterHelper.getSettingsRoute(
                                            action: RouteAction.push,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),

                                  // 5. Help & Support Section
                                  _buildSectionTitle('المساعدة والدعم'),
                                  _buildSectionCard(
                                    children: [
                                      _buildMenuItem(
                                        icon: Icons.support_agent_rounded,
                                        title: 'تذاكر الدعم والاستفسارات',
                                        subtitle:
                                            'فريق الدعم الفني جاهز لمساعدتك',
                                        onTap: () {
                                          _navigateOrLogin(
                                            context,
                                            isGuest,
                                            () => RouterHelper
                                                .getSupportTicketRoute(
                                              action: RouteAction.push,
                                            ),
                                          );
                                        },
                                      ),
                                      _buildDivider(),
                                      _buildMenuItem(
                                        icon: Icons.chat_rounded,
                                        iconColor: AllineColors.success,
                                        iconBgColor: const Color(0xFFE8F7EE),
                                        title: 'واتساب خدمة العملاء',
                                        subtitle:
                                            '+967 775 667 733 — محادثة فورية',
                                        trailing: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 7,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE8F7EE),
                                            borderRadius:
                                                BorderRadius.circular(8),
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
                                      _buildDivider(),
                                      _buildMenuItem(
                                        icon: Icons.help_outline_rounded,
                                        title: 'الأسئلة الشائعة',
                                        subtitle:
                                            'إجابات عن أكثر الأسئلة تكراراً',
                                        onTap: () {
                                          RouterHelper.getFaqRoute(
                                            action: RouteAction.push,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),

                                  // 6. Legal / Secondary Links
                                  _buildLegalLinks(context, splashController),
                                  const SizedBox(height: 12),

                                  // 7. Logout / Sign In Action Card
                                  _buildLogoutCard(context, isGuest),
                                  const SizedBox(height: 20),

                                  // 8. Footer Info
                                  Center(
                                    child: Column(
                                      children: [
                                        Text(
                                          'Alline — السوق الشامل في اليمن',
                                          style: TextStyle(
                                            fontFamily: 'AllineTajawal',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: colors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'الإصدار ${AppConstants.appVersion}',
                                          style: TextStyle(
                                            fontFamily: 'AllineTajawal',
                                            fontSize: 11,
                                            color: colors.textSecondary,
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
                      );
                    },
                  );
                },
              );
            },
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
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }

  Widget _buildSectionCard({required List<Widget> children}) {
    final colors = AllineThemeColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? null
            : [
                BoxShadow(
                  color: AllineColors.primaryDark.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AllineThemeColors.of(context).border,
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
    Color? iconBgColor,
    Widget? trailing,
  }) {
    final colors = AllineThemeColors.of(context);
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
                color: iconBgColor ??
                    Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
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
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
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
            Icon(
              Icons.chevron_left_rounded,
              size: 20,
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    ProfileController profile,
    bool isGuest,
  ) {
    final colors = AllineThemeColors.of(context);
    if (isGuest) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.border),
          boxShadow: Theme.of(context).brightness == Brightness.dark
              ? null
              : [
                  BoxShadow(
                    color: AllineColors.primaryDark.withValues(alpha: 0.03),
                    blurRadius: 12,
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
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.border, width: 2),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person_outline_rounded,
                      size: 32,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مرحباً بك في Alline',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'سجّل الدخول لتجربة تسوق متكاملة ومتابعة طلباتك ومحفظتك',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AllineColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  RouterHelper.getLoginRoute(
                    action: RouteAction.push,
                    fromPage: '${RouterHelper.dashboardScreen}?page=more',
                  );
                },
                icon: const Icon(Icons.login_rounded,
                    size: 18, color: Colors.white),
                label: const Text(
                  'تسجيل الدخول / إنشاء حساب جديد',
                  style: TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final user = profile.userInfoModel;
    final bool isLoading = profile.isLoading && user == null;

    if (isLoading) {
      return Shimmer.fromColors(
        baseColor: colors.skeletonBase,
        highlightColor: colors.skeletonHighlight,
        child: Container(
          height: 130,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      );
    }

    final String fullName = '${user?.fName ?? ''} ${user?.lName ?? ''}'.trim();
    final String displayName = fullName.isNotEmpty ? fullName : 'عميل Alline';
    final String contactInfo = (user?.phone != null && user!.phone!.isNotEmpty)
        ? user.phone!
        : (user?.email ?? '');
    final String? avatarUrl = user?.imageFullUrl?.path;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? null
            : [
                BoxShadow(
                  color: AllineColors.primaryDark.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AllineColors.primary.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(33),
                      child: (avatarUrl != null && avatarUrl.isNotEmpty)
                          ? CustomImageWidget(
                              image: avatarUrl,
                              width: 66,
                              height: 66,
                              fit: BoxFit.cover,
                              placeholder: Images.guestProfile,
                            )
                          : const Center(
                              child: Icon(
                                Icons.person_rounded,
                                size: 36,
                                color: AllineColors.primary,
                              ),
                            ),
                    ),
                  ),
                  InkWell(
                    onTap: () => RouterHelper.getProfileScreen1Route(
                        action: RouteAction.push),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AllineColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        size: 11,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أهلاً بك،',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      displayName,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (contactInfo.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            contactInfo.contains('@')
                                ? Icons.email_outlined
                                : Icons.phone_iphone_rounded,
                            size: 13,
                            color: colors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              contactInfo,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: () =>
                RouterHelper.getProfileScreen1Route(action: RouteAction.push),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 38,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AllineColors.primary.withValues(alpha: 0.15),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_note_rounded,
                      size: 18, color: AllineColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'تعديل الملف الشخصي والمعلومات',
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
    );
  }

  Widget _buildAccountSummary(
    BuildContext context,
    ProfileController profile,
    WishListController wishList,
  ) {
    final colors = AllineThemeColors.of(context);
    final user = profile.userInfoModel;
    final int ordersCount = user?.totalOrder?.toInt() ?? 0;
    final int favoritesCount = wishList.wishList?.length ?? 0;
    final String walletFormatted = user?.walletBalance != null
        ? PriceConverter.convertPrice(context, user!.walletBalance)
        : '0 ر.ي';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? null
            : [
                BoxShadow(
                  color: AllineColors.primaryDark.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Row(
        children: [
          // Orders
          Expanded(
            child: InkWell(
              onTap: () =>
                  RouterHelper.getOrderScreenRoute(isBackButtonExist: true),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    Text(
                      '$ordersCount',
                      style: const TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AllineColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'الطلبات',
                      style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(height: 28, width: 1, color: colors.border),
          // Favorites
          Expanded(
            child: InkWell(
              onTap: () =>
                  RouterHelper.getWishListRoute(action: RouteAction.push),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    Text(
                      '$favoritesCount',
                      style: const TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AllineColors.accent,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'المفضلة',
                      style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(height: 28, width: 1, color: colors.border),
          // Wallet
          Expanded(
            child: InkWell(
              onTap: () => RouterHelper.getWalletRoute(
                  action: RouteAction.push, isBackButtonExist: true),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    Text(
                      walletFormatted,
                      style: const TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AllineColors.success,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'المحفظة',
                      style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalLinks(BuildContext context, SplashController splash) {
    final colors = AllineThemeColors.of(context);
    final terms =
        _getPageBySlug('terms-and-conditions', splash.defaultBusinessPages);
    final privacy =
        _getPageBySlug('privacy-policy', splash.defaultBusinessPages);
    final aboutUs = _getPageBySlug('about-us', splash.defaultBusinessPages);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 8,
        children: [
          if (terms != null)
            InkWell(
              onTap: () => RouterHelper.getHtmlViewRoute(page: terms),
              child: Text(
                'الشروط والأحكام',
                style: TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 12,
                  color: colors.textSecondary,
                  decoration: TextDecoration.underline,
                  decorationColor: colors.border,
                ),
              ),
            ),
          if (privacy != null)
            InkWell(
              onTap: () => RouterHelper.getHtmlViewRoute(page: privacy),
              child: Text(
                'سياسة الخصوصية',
                style: TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 12,
                  color: colors.textSecondary,
                  decoration: TextDecoration.underline,
                  decorationColor: colors.border,
                ),
              ),
            ),
          if (aboutUs != null)
            InkWell(
              onTap: () => RouterHelper.getHtmlViewRoute(page: aboutUs),
              child: Text(
                'عن Alline',
                style: TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 12,
                  color: colors.textSecondary,
                  decoration: TextDecoration.underline,
                  decorationColor: colors.border,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLogoutCard(BuildContext context, bool isGuest) {
    final colors = AllineThemeColors.of(context);
    if (isGuest) {
      return InkWell(
        onTap: () {
          RouterHelper.getLoginRoute(
            action: RouteAction.push,
            fromPage: '${RouterHelper.dashboardScreen}?page=more',
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: AllineColors.primary.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: AllineColors.primaryDark.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.login_rounded, size: 22, color: AllineColors.primary),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  'تسجيل الدخول / إنشاء حساب',
                  style: TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AllineColors.primary,
                  ),
                ),
              ),
              Icon(Icons.chevron_left_rounded,
                  size: 20, color: AllineColors.primary),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: context,
          builder: (_) => const LogoutCustomBottomSheetWidget(),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.surface,
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
        child: Row(
          children: [
            const Icon(Icons.logout_rounded,
                size: 22, color: AllineColors.error),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'تسجيل الخروج',
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AllineColors.error,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'الخروج من الحساب الحالي على هذا الهاتف',
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 11,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_left_rounded,
                size: 20, color: AllineColors.error),
          ],
        ),
      ),
    );
  }
}
