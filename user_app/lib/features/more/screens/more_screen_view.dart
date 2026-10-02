import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/not_logged_in_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/more/widgets/logout_confirm_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/controllers/notification_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/setting/widgets/select_language_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/business_pages_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/wallet/widgets/add_fund_dialogue_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/wallet/widgets/top_up_wallet_bottom_sheet.dart';
import 'package:flutter_sixvalley_ecommerce/features/wishlist/controllers/wishlist_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

/// Alline Account Screen / "حسابي"
///
/// Pixel-perfect, high-end reference implementation for Alline e-commerce marketplace.
/// Designed according to the Alline design system:
/// - Brand Blue: #0757D5 / #032C75
/// - Accent: restrained blue tones with semantic colors only
/// - Arabic RTL First, responsive typography & soft diffused shadows.
class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  // Brand color tokens
  static const Color brandBlue = Color(0xFF0757D5);
  static const Color brandDarkBlue = Color(0xFF032C75);
  static const Color brandAccent = Color(0xFF1675D1);
  static const Color brandGreen = Color(0xFF25D366);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authController = Provider.of<AuthController>(context, listen: false);
    if (authController.isLoggedIn()) {
      Provider.of<ProfileController>(context, listen: false).getUserInfo(context);
      Provider.of<WishListController>(context, listen: false).getWishList('');
      Provider.of<NotificationController>(context, listen: false).getNotificationList(1);
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
      final bool launched = await launchUrl(appUri, mode: LaunchMode.externalApplication);
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

  void _navigateOrLogin(BuildContext context, bool isGuest, VoidCallback onLoggedIn) {
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

  BusinessPageModel? _getPageBySlug(String slug, List<BusinessPageModel>? pagesList) {
    if (pagesList != null && pagesList.isNotEmpty) {
      for (final page in pagesList) {
        if (page.slug == slug) {
          return page;
        }
      }
    }
    return null;
  }

  void _onRechargeWallet(BuildContext context, bool isGuest) {
    _navigateOrLogin(context, isGuest, () {
      final splash = Provider.of<SplashController>(context, listen: false);
      if (splash.configModel?.addFundsToWallet == 1) {
        final walletController = Provider.of<WalletController>(context, listen: false);
        walletController.clearLocalWalletTopUpDraft();
        walletController.getLocalWalletMethods(reload: true);
        showDialog(
          context: context,
          builder: (_) => AddFundDialogueWidget(
            focusNode: FocusNode(),
            inputAmountController: TextEditingController(),
          ),
        );
      } else {
        RouterHelper.getWalletRoute(action: RouteAction.push, isBackButtonExist: true);
      }
    });
  }

  void _openLocalWalletsBottomSheet(BuildContext context, bool isGuest) {
    _navigateOrLogin(context, isGuest, () {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const TopUpWalletBottomSheet(),
      );
    });
  }

  void _openPaymentMethodsBottomSheet(BuildContext context) {
    final colors = AllineThemeColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Icon(Icons.credit_card_rounded, color: brandBlue, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'طرق الدفع المعتمدة في Alline',
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildPaymentOptionRow(
                icon: Icons.money_rounded,
                title: 'الدفع عند الاستلام',
                subtitle: 'ادفع نقداً عند استلام طلبك لباب منزلك',
                colors: colors,
                color: brandBlue,
              ),
              const Divider(height: 16),
              _buildPaymentOptionRow(
                icon: Icons.account_balance_wallet_rounded,
                title: 'رصيد محفظة Alline',
                subtitle: 'دفع فوري بضغطة زر واحدة مع خصومات خاصة',
                colors: colors,
                color: brandAccent,
              ),
              const Divider(height: 16),
              _buildPaymentOptionRow(
                icon: Icons.phone_android_rounded,
                title: 'المحافظ الإلكترونية اليمنية',
                subtitle: 'محفظة جيب، جوالي، ون كاش، فلوسك، محفظة كاش',
                colors: colors,
                color: brandGreen,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _openLocalWalletsBottomSheet(context, !Provider.of<AuthController>(context, listen: false).isLoggedIn());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 18),
                  label: const Text(
                    'شحن رصيد المحفظة الآن',
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
      },
    );
  }

  Widget _buildPaymentOptionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required AllineThemeColors colors,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 12,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openSecurityAndPrivacyBottomSheet(BuildContext context, SplashController splash) {
    final colors = AllineThemeColors.of(context);
    final terms = _getPageBySlug('terms-and-conditions', splash.defaultBusinessPages);
    final privacy = _getPageBySlug('privacy-policy', splash.defaultBusinessPages);
    final refund = _getPageBySlug('refund-policy', splash.defaultBusinessPages);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Icon(Icons.shield_outlined, color: brandBlue, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'الأمان والخصوصية',
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (privacy != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.privacy_tip_outlined, color: brandBlue),
                  title: Text(
                    'سياسة الخصوصية',
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  trailing: Icon(Icons.chevron_left_rounded, color: colors.textSecondary),
                  onTap: () {
                    Navigator.pop(ctx);
                    RouterHelper.getHtmlViewRoute(page: privacy);
                  },
                ),
              if (terms != null) ...[
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.description_outlined, color: brandBlue),
                  title: Text(
                    'الشروط والأحكام',
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  trailing: Icon(Icons.chevron_left_rounded, color: colors.textSecondary),
                  onTap: () {
                    Navigator.pop(ctx);
                    RouterHelper.getHtmlViewRoute(page: terms);
                  },
                ),
              ],
              if (refund != null) ...[
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.replay_rounded, color: brandBlue),
                  title: Text(
                    'سياسة الإرجاع والاستبدال',
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  trailing: Icon(Icons.chevron_left_rounded, color: colors.textSecondary),
                  onTap: () {
                    Navigator.pop(ctx);
                    RouterHelper.getHtmlViewRoute(page: refund);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AllineThemeColors.of(context);
    final themeController = Provider.of<ThemeController>(context);
    final isDark = themeController.darkTheme;

    return Scaffold(
      backgroundColor: isDark ? colors.background : const Color(0xFFF7FAFD),
      body: SafeArea(
        child: Consumer<AuthController>(
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
                              color: brandBlue,
                              onRefresh: _onRefresh,
                              child: Column(
                                children: [
                                  // Top Custom Header / AppBar
                                  _buildTopAppBar(context, colors, isGuest, notificationController),

                                  // Scrollable Content
                                  Expanded(
                                    child: SingleChildScrollView(
                                      physics: const AlwaysScrollableScrollPhysics(
                                        parent: BouncingScrollPhysics(),
                                      ),
                                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          // 1. Profile Header Card
                                          _buildProfileCard(context, colors, profileController, isGuest),
                                          const SizedBox(height: 14),

                                          // 2. Alline Wallet Banner Card
                                          _buildWalletCard(context, colors, profileController, isGuest),
                                          const SizedBox(height: 14),

                                          // 3. Four Quick Action Cards (Row of 4)
                                          _buildQuickActionCards(context, colors, isGuest),
                                          const SizedBox(height: 16),

                                          // 4. Section 1: Settings and Services
                                          _buildSettingsAndServicesSection(
                                            context,
                                            colors,
                                            isGuest,
                                            notificationController,
                                            splashController,
                                          ),
                                          const SizedBox(height: 14),

                                          // 5. Section 2: Contact Us
                                          _buildContactUsSection(context, colors),
                                          const SizedBox(height: 14),

                                          // 6. About App & Version Tile
                                          _buildAboutAppTile(context, colors, splashController),
                                          const SizedBox(height: 14),

                                          // 7. Logout / Login Action Button
                                          _buildLogoutButton(context, colors, isGuest),
                                          const SizedBox(height: 28),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
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
      ),
    );
  }

  // ==========================================
  // TOP APP BAR
  // ==========================================
  Widget _buildTopAppBar(
    BuildContext context,
    AllineThemeColors colors,
    bool isGuest,
    NotificationController notificationController,
  ) {
    final themeController = Provider.of<ThemeController>(context);
    final hasUnread = !isGuest && (notificationController.notificationModel?.newNotificationItem ?? 0) > 0;

    return Container(
      color: colors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: restrained account mark (no oversized Alline logo image).
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: brandBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: brandBlue.withValues(alpha: 0.14)),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: brandBlue,
              size: 20,
            ),
          ),

          // Center (Title)
          Text(
            'حسابي',
            style: TextStyle(
              fontFamily: 'AllineTajawal',
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),

          // Right Actions (Notifications & Dark/Light mode)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Notification Bell
              InkWell(
                onTap: () {
                  _navigateOrLogin(
                    context,
                    isGuest,
                    () => RouterHelper.getNotificationRoute(action: RouteAction.push),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 24,
                        color: colors.textPrimary,
                      ),
                      if (hasUnread)
                        Positioned(
                          top: 1,
                          right: 1,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: brandAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Dark/Light Mode Moon
              InkWell(
                onTap: () => themeController.toggleTheme(),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    themeController.darkTheme ? Icons.light_mode_outlined : Icons.nightlight_outlined,
                    size: 24,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 1. PROFILE HEADER CARD
  // ==========================================
  Widget _buildProfileCard(
    BuildContext context,
    AllineThemeColors colors,
    ProfileController profile,
    bool isGuest,
  ) {
    if (isGuest) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: brandDarkBlue.withValues(alpha: 0.03),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar Placeholder
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: brandBlue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(color: brandBlue.withValues(alpha: 0.2), width: 2),
              ),
              child: const Center(
                child: Icon(Icons.person_outline_rounded, size: 38, color: brandBlue),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرحباً بك في Alline',
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'سجّل الدخول للوصول لمحفظتك ومتابعة طلباتك',
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 12,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      RouterHelper.getLoginRoute(
                        action: RouteAction.push,
                        fromPage: '${RouterHelper.dashboardScreen}?page=more',
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: brandBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.login_rounded, size: 15, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            'تسجيل الدخول / إنشاء حساب',
                            style: TextStyle(
                              fontFamily: 'AllineTajawal',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
          height: 110,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: brandDarkBlue.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left in RTL: User Details & Edit Profile Button
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name
                Text(
                  displayName,
                  style: TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),

                // Phone
                if (contactInfo.isNotEmpty)
                  Text(
                    contactInfo,
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                const SizedBox(height: 10),

                // Edit Profile Button (Outlined pill with pen icon)
                InkWell(
                  onTap: () => RouterHelper.getProfileScreen1Route(action: RouteAction.push),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: brandBlue.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: brandBlue.withValues(alpha: 0.45), width: 1.2),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_outlined, size: 14, color: brandBlue),
                        SizedBox(width: 6),
                        Text(
                          'تعديل الملف الشخصي',
                          style: TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: brandBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Right in RTL: Avatar with Camera Badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: brandBlue.withValues(alpha: 0.15), width: 2),
                  gradient: LinearGradient(
                    colors: [
                      brandBlue.withValues(alpha: 0.1),
                      brandBlue.withValues(alpha: 0.25),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ClipOval(
                  child: (avatarUrl != null && avatarUrl.isNotEmpty)
                      ? CustomImageWidget(
                          image: avatarUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder: Images.guestProfile,
                        )
                      : const Center(
                          child: Icon(Icons.person_rounded, size: 44, color: brandBlue),
                        ),
                ),
              ),

              // Camera Badge Button (bottom-left in RTL)
              PositionedDirectional(
                bottom: 0,
                end: 0,
                child: InkWell(
                  onTap: () => RouterHelper.getProfileScreen1Route(action: RouteAction.push),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: brandBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. ALLINE WALLET BANNER CARD
  // ==========================================
  Widget _buildWalletCard(
    BuildContext context,
    AllineThemeColors colors,
    ProfileController profile,
    bool isGuest,
  ) {
    final user = profile.userInfoModel;
    final double rawBalance = user?.walletBalance?.toDouble() ?? 0.0;
    final String formattedBalance = PriceConverter.convertPrice(context, rawBalance);

    // Extract numerical digits and currency symbol neatly
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0858D6), Color(0xFF023696)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0858D6).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side in RTL: Actions (Wallet icon & Orange recharge pill)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Wallet Icon Square
              InkWell(
                onTap: () {
                  _navigateOrLogin(
                    context,
                    isGuest,
                    () => RouterHelper.getWalletRoute(action: RouteAction.push, isBackButtonExist: true),
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: const Center(
                    child: Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Secondary "شحن الرصيد" action
              InkWell(
                onTap: () => _onRechargeWallet(context, isGuest),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 5),
                      Text(
                        'شحن الرصيد',
                        style: TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Right side in RTL: Title & Balance
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'محفظة Alline',
                style: TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'الرصيد الحالي',
                style: TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 12.5,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 4),
              // Huge Balance Number
              Text(
                isGuest ? '0 ر.ي' : formattedBalance,
                style: const TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. FOUR QUICK ACTION CARDS (ROW OF 4)
  // ==========================================
  Widget _buildQuickActionCards(
    BuildContext context,
    AllineThemeColors colors,
    bool isGuest,
  ) {
    return Row(
      children: [
        // 1. المحافظ المحلية (Local Wallets)
        Expanded(
          child: _buildQuickActionItem(
            icon: Icons.account_balance_wallet_outlined,
            title: 'المحافظ المحلية',
            iconColor: brandAccent,
            colors: colors,
            onTap: () => _openLocalWalletsBottomSheet(context, isGuest),
          ),
        ),
        const SizedBox(width: 8),

        // 2. المفضلة (Wishlist)
        Expanded(
          child: _buildQuickActionItem(
            icon: Icons.favorite_border_rounded,
            title: 'المفضلة',
            iconColor: brandAccent,
            colors: colors,
            onTap: () {
              _navigateOrLogin(
                context,
                isGuest,
                () => RouterHelper.getWishListRoute(action: RouteAction.push),
              );
            },
          ),
        ),
        const SizedBox(width: 8),

        // 3. عناويني (Addresses)
        Expanded(
          child: _buildQuickActionItem(
            icon: Icons.location_on_outlined,
            title: 'عناويني',
            iconColor: brandBlue,
            colors: colors,
            onTap: () {
              _navigateOrLogin(
                context,
                isGuest,
                () => RouterHelper.getAddressListScreen(action: RouteAction.push),
              );
            },
          ),
        ),
        const SizedBox(width: 8),

        // 4. طلباتي (My Orders)
        Expanded(
          child: _buildQuickActionItem(
            icon: Icons.shopping_bag_outlined,
            title: 'طلباتي',
            iconColor: brandBlue,
            colors: colors,
            onTap: () {
              _navigateOrLogin(
                context,
                isGuest,
                () => RouterHelper.getOrderScreenRoute(isBackButtonExist: true),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String title,
    required Color iconColor,
    required AllineThemeColors colors,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: brandDarkBlue.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: iconColor),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 4. SECTION 1: SETTINGS & SERVICES
  // ==========================================
  Widget _buildSettingsAndServicesSection(
    BuildContext context,
    AllineThemeColors colors,
    bool isGuest,
    NotificationController notificationController,
    SplashController splashController,
  ) {
    final themeController = Provider.of<ThemeController>(context);
    final isArabic = Provider.of<LocalizationController>(context).locale.languageCode == 'ar';
    final hasUnread = !isGuest && (notificationController.notificationModel?.newNotificationItem ?? 0) > 0;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: brandDarkBlue.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(
              'الإعدادات والخدمات',
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
          ),

          // 1. المظهر
          _buildSettingsTile(
            icon: Icons.dark_mode_outlined,
            title: 'المظهر: ${themeController.darkTheme ? 'الوضع الليلي' : 'تلقائي حسب الجهاز'}',
            colors: colors,
            onTap: () => themeController.toggleTheme(),
          ),
          _buildSectionDivider(colors),

          // 2. اللغة
          _buildSettingsTile(
            icon: Icons.language_rounded,
            title: 'اللغة: ${isArabic ? 'العربية' : 'English'}',
            colors: colors,
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const SelectLanguageBottomSheetWidget(),
              );
            },
          ),
          _buildSectionDivider(colors),

          // 3. الإشعارات
          _buildSettingsTile(
            icon: Icons.notifications_none_rounded,
            title: 'الإشعارات',
            colors: colors,
            badge: hasUnread
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: brandAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${notificationController.notificationModel!.newNotificationItem}',
                      style: const TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 10,
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
                () => RouterHelper.getNotificationRoute(action: RouteAction.push),
              );
            },
          ),
          _buildSectionDivider(colors),

          // 4. الأمان والخصوصية
          _buildSettingsTile(
            icon: Icons.shield_outlined,
            title: 'الأمان والخصوصية',
            colors: colors,
            onTap: () => _openSecurityAndPrivacyBottomSheet(context, splashController),
          ),
          _buildSectionDivider(colors),

          // 5. طرق الدفع
          _buildSettingsTile(
            icon: Icons.credit_card_outlined,
            title: 'طرق الدفع',
            colors: colors,
            onTap: () => _openPaymentMethodsBottomSheet(context),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 5. SECTION 2: CONTACT US
  // ==========================================
  Widget _buildContactUsSection(
    BuildContext context,
    AllineThemeColors colors,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: brandDarkBlue.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(
              'تواصل معنا',
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
          ),

          // 1. مركز المساعدة
          _buildSettingsTile(
            icon: Icons.headset_mic_outlined,
            title: 'مركز المساعدة',
            colors: colors,
            onTap: () => RouterHelper.getContactUsScreenRoute(action: RouteAction.push),
          ),
          _buildSectionDivider(colors),

          // 2. تواصل عبر واتساب
          _buildSettingsTile(
            icon: Icons.chat_bubble_outline_rounded,
            iconWidget: SvgPicture.asset(
              'assets/svg/whatsapp_official.svg',
              width: 22,
              height: 22,
            ),
            iconColor: brandGreen,
            title: 'تواصل عبر واتساب',
            colors: colors,
            onTap: _openWhatsAppSupport,
          ),
          _buildSectionDivider(colors),

          // 3. الأسئلة الشائعة
          _buildSettingsTile(
            icon: Icons.help_outline_rounded,
            title: 'الأسئلة الشائعة',
            colors: colors,
            onTap: () => RouterHelper.getFaqRoute(action: RouteAction.push),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 6. ABOUT APP TILE
  // ==========================================
  Widget _buildAboutAppTile(
    BuildContext context,
    AllineThemeColors colors,
    SplashController splash,
  ) {
    final aboutUs = _getPageBySlug('about-us', splash.defaultBusinessPages);

    return InkWell(
      onTap: () {
        if (aboutUs != null) {
          RouterHelper.getHtmlViewRoute(page: aboutUs);
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: brandDarkBlue.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Right in RTL: Icon + About Alline
            Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 20, color: colors.textPrimary),
                const SizedBox(width: 10),
                Text(
                  'عن Alline',
                  style: TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),

            // Left in RTL: Version text
            Text(
              'الإصدار ${AppConstants.appVersion}',
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 12.5,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 7. LOGOUT / LOGIN ACTION BUTTON
  // ==========================================
  Widget _buildLogoutButton(
    BuildContext context,
    AllineThemeColors colors,
    bool isGuest,
  ) {
    if (isGuest) {
      return InkWell(
        onTap: () {
          RouterHelper.getLoginRoute(
            action: RouteAction.push,
            fromPage: '${RouterHelper.dashboardScreen}?page=more',
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: brandBlue.withValues(alpha: 0.4), width: 1.2),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login_rounded, size: 20, color: brandBlue),
              SizedBox(width: 8),
              Text(
                'تسجيل الدخول / إنشاء حساب جديد',
                style: TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: brandBlue,
                ),
              ),
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF97066), width: 1.2),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, size: 20, color: Color(0xFFD92D20)),
            SizedBox(width: 8),
            Text(
              'تسجيل الخروج',
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD92D20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SHARED SECTION TILE & DIVIDER
  // ==========================================
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required AllineThemeColors colors,
    required VoidCallback onTap,
    Color iconColor = brandBlue,
    Widget? badge,
    Widget? iconWidget,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Icon
            iconWidget ?? Icon(icon, size: 22, color: iconColor),
            const SizedBox(width: 14),

            // Title
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ),

            // Optional Badge
            if (badge != null) ...[
              badge,
              const SizedBox(width: 8),
            ],

            // Chevron
            Icon(
              Icons.chevron_left_rounded,
              size: 20,
              color: colors.textSecondary.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionDivider(AllineThemeColors colors) {
    return Divider(
      height: 1,
      thickness: 1,
      color: colors.border.withValues(alpha: 0.7),
      indent: 52,
      endIndent: 16,
    );
  }
}
