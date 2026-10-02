import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sixvalley_vendor_app/features/ai_chat/screens/ai_chat_screen.dart';
import 'package:sixvalley_vendor_app/features/bank_info/screens/bank_info_screen.dart';
import 'package:sixvalley_vendor_app/features/coupon/screens/coupon_list_screen.dart';
import 'package:sixvalley_vendor_app/features/dashboard/screens/nav_bar_screen.dart';
import 'package:sixvalley_vendor_app/features/delivery_man/screens/delivery_man_setup_screen.dart';
import 'package:sixvalley_vendor_app/features/menu/widgets/sign_out_confirmation_dialog_widget.dart';
import 'package:sixvalley_vendor_app/features/notification/controllers/notification_controller.dart';
import 'package:sixvalley_vendor_app/features/notification/screens/notification_screen.dart';
import 'package:sixvalley_vendor_app/features/more/screens/html_view_screen.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/features/profile/screens/profile_screen.dart';
import 'package:sixvalley_vendor_app/features/refund/screens/refund_screen.dart';
import 'package:sixvalley_vendor_app/features/review/screens/product_review_screen.dart';
import 'package:sixvalley_vendor_app/features/settings/screens/setting_screen.dart';
import 'package:sixvalley_vendor_app/features/shop/controllers/shop_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/domain/models/business_pages_model.dart';
import 'package:sixvalley_vendor_app/features/shop/screens/shop_screen.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/features/wallet/screens/wallet_screen.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';
import 'package:url_launcher/url_launcher.dart';

class SellerAccountScreen extends StatefulWidget {
  const SellerAccountScreen({super.key});

  @override
  State<SellerAccountScreen> createState() => _SellerAccountScreenState();
}

class _SellerAccountScreenState extends State<SellerAccountScreen> {
  bool _isInitialLoadFailed = false;
  bool _isLoadingInitialData = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadProfileData();
    });
  }

  Future<void> _loadProfileData({bool showSkeleton = false}) async {
    if (showSkeleton && mounted) {
      setState(() {
        _isLoadingInitialData = true;
        _isInitialLoadFailed = false;
      });
    }
    try {
      await Future.wait<void>([
        context.read<ProfileController>().getSellerInfo().then((_) {}),
        context.read<ShopController>().getShopInfo().then((_) {}),
        context.read<NotificationController>().getNotificationList(1),
      ]);
    } catch (_) {
      // The screen below presents a retry state if essential data is missing.
    }
    if (!mounted) return;
    setState(() {
      _isLoadingInitialData = false;
      _isInitialLoadFailed =
          context.read<ProfileController>().userInfoModel == null &&
              context.read<ShopController>().shopModel == null;
    });
  }

  Future<void> _refresh() async {
    await _loadProfileData();
  }

  void _openNotifications() {
    _push(const NotificationScreen());
  }

  Future<void> _updateStoreStatus(bool isOpen) async {
    final updated = await context.read<ShopController>().updateStoreOpenStatus(
          isOpen: isOpen,
        );
    if (!mounted) return;
    final color = updated
        ? ColorResources.getSuccess(context)
        : ColorResources.getError(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: color,
          content: Text(
            updated
                ? (isOpen
                    ? 'تم فتح المتجر وتأكيد الحالة من الخادم'
                    : 'تم إغلاق المتجر وتأكيد الحالة من الخادم')
                : 'تعذر تحديث حالة المتجر. حاول مرة أخرى.',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'AllineTajawal',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
  }

  Future<void> _openWhatsAppSupport() async {
    const message =
        'مرحباً خدمة دعم تجار Alline، أحتاج إلى مساعدة بخصوص متجري.';
    final appUri = Uri.parse(
      'whatsapp://send?phone=967775667733&text=${Uri.encodeComponent(message)}',
    );
    final webUri = Uri.parse(
      'https://wa.me/967775667733?text=${Uri.encodeComponent(message)}',
    );

    try {
      final launched = await launchUrl(
        appUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (error) {
        debugPrint('Failed to launch WhatsApp support: $error');
      }
    }
  }

  Future<void> _openExternalHelpPage(String? url) async {
    final uri = Uri.tryParse(url?.trim() ?? '');
    if (uri == null ||
        !uri.hasAuthority ||
        !{'http', 'https'}.contains(uri.scheme.toLowerCase())) {
      return;
    }
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح صفحة المساعدة.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح صفحة المساعدة.')),
      );
    }
  }

  void _push(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _openShopManagement() async {
    final profile = context.read<ProfileController>();
    if (profile.userInfoModel == null) {
      try {
        await profile.getSellerInfo();
      } catch (_) {
        // The guarded check below keeps the route closed when loading fails.
      }
    }
    if (!mounted) return;
    if (profile.userInfoModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('تعذر تحميل بيانات البائع. اسحب للتحديث.')),
      );
      return;
    }
    _push(const ShopScreen());
  }

  @override
  Widget build(BuildContext context) {
    final config = context.read<SplashController>().configModel;
    final businessPages =
        context.watch<SplashController>().defaultBusinessPages ??
            <BusinessPageModel>[];
    final legalPages = <(String, String, IconData)>[
      ('terms-and-conditions', 'الشروط والأحكام', Icons.description_outlined),
      ('privacy-policy', 'سياسة الخصوصية', Icons.privacy_tip_outlined),
      ('about-us', 'حول Alline', Icons.info_outline_rounded),
    ]
        .map((entry) {
          return (
            _businessPageBySlug(entry.$1, businessPages),
            entry.$2,
            entry.$3,
          );
        })
        .where((entry) => entry.$1 != null)
        .toList();

    return Scaffold(
      backgroundColor: ColorResources.getScaffoldBg(context),
      appBar: AppBar(
        backgroundColor: ColorResources.getScaffoldBg(context),
        foregroundColor: ColorResources.getTextTitle(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'حسابي',
          style: _textStyle(
            context,
            size: 19,
            weight: FontWeight.w700,
            color: ColorResources.getTextTitle(context),
          ),
        ),
        actions: [
          _NotificationAction(
            count: context.select<NotificationController, int>(
              (controller) =>
                  controller.notificationModel?.newNotificationItem ?? 0,
            ),
            onTap: _openNotifications,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body:
          Consumer3<ProfileController, ShopController, NotificationController>(
        builder: (context, profileController, shopController,
            notificationController, _) {
          final seller = profileController.userInfoModel;
          final shop = shopController.shopModel;
          final storeName = shop?.name?.trim() ?? '';
          final sellerName =
              '${seller?.fName ?? ''} ${seller?.lName ?? ''}'.trim();
          final isVacation = shop?.vacationStatus ?? false;
          // In the existing API model, temporaryClose is normalized to true
          // when the store is accepting orders.
          final isOpen = shop?.temporaryClose == true && !isVacation;
          final notificationCount =
              notificationController.notificationModel?.newNotificationItem ??
                  0;

          return RefreshIndicator(
            color: ColorResources.getPrimary(context),
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 28),
              children: [
                if (seller == null && shop == null && _isInitialLoadFailed)
                  _ProfileLoadError(onRetry: () {
                    _loadProfileData(showSkeleton: true);
                  })
                else if (seller == null &&
                    shop == null &&
                    _isLoadingInitialData)
                  const _ProfileLoadingSkeleton()
                else
                  _ProfileHeader(
                    storeName: storeName.isNotEmpty ? storeName : 'متجرك',
                    sellerName: sellerName,
                    logoUrl: shop?.imageFullUrl?.path,
                    coverUrl: shop?.bannerFullUrl?.path,
                  ),
                const SizedBox(height: 14),
                _StoreStatusCard(
                  isOpen: isOpen,
                  isVacation: isVacation,
                  hasStoreData: shop != null,
                  isLoadingData: _isLoadingInitialData,
                  isUpdating: shopController.isLoading,
                  onChanged: (value) => _updateStoreStatus(value),
                  onRetry: () => _loadProfileData(showSkeleton: true),
                  onManageVacation: _openShopManagement,
                ),
                const SizedBox(height: 22),
                _SectionHeading(
                  title: 'بيانات المتجر',
                  actionLabel: 'تعديل',
                  onAction: _openShopManagement,
                ),
                const SizedBox(height: 10),
                _StoreInformationCard(
                  name: shop?.name,
                  phone: shop?.contact,
                  address: shop?.address,
                  storeType: shop?.storeType,
                  latitude: shop?.latitude,
                  longitude: shop?.longitude,
                  onEdit: _openShopManagement,
                ),
                const SizedBox(height: 22),
                const _SectionHeading(title: 'إدارة المتجر'),
                const SizedBox(height: 10),
                _ActionGrid(
                  actions: [
                    _ActionItem(
                      icon: Icons.storefront_rounded,
                      title: 'إعدادات المتجر',
                      onTap: _openShopManagement,
                    ),
                    _ActionItem(
                      icon: Icons.account_balance_rounded,
                      title: 'البيانات البنكية',
                      onTap: () => _push(const BankInfoScreen()),
                    ),
                    _ActionItem(
                      icon: Icons.delivery_dining_rounded,
                      title: 'مندوبي التوصيل',
                      onTap: () => _push(const DeliveryManSetupScreen()),
                    ),
                    _ActionItem(
                      icon: Icons.local_offer_rounded,
                      title: 'القسائم والعروض',
                      onTap: () => _push(const CouponListScreen()),
                    ),
                    _ActionItem(
                      icon: Icons.replay_rounded,
                      title: 'طلبات الاسترداد',
                      onTap: () => _push(
                        const RefundScreen(fromNotification: false),
                      ),
                    ),
                    _ActionItem(
                      icon: Icons.star_rate_rounded,
                      title: 'التقييمات',
                      onTap: () => _push(const ProductReviewScreen()),
                    ),
                    if (config?.posActive == 1 && seller?.posActive == 1)
                      _ActionItem(
                        icon: Icons.point_of_sale_rounded,
                        title: 'نقطة البيع',
                        onTap: () => _push(const NavBarScreen()),
                      ),
                    _ActionItem(
                      icon: Icons.auto_awesome_rounded,
                      title: 'مساعد Alline',
                      iconColor: ColorResources.getSecondary(context),
                      onTap: () => _push(const AiChatScreen()),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _SectionHeading(title: 'المحفظة'),
                const SizedBox(height: 10),
                _WalletShortcut(
                  balance: seller?.wallet?.totalEarning ?? 0.0,
                  onTap: () => _push(const WalletScreen()),
                ),
                const SizedBox(height: 22),
                _SectionHeading(
                  title: 'الإشعارات',
                  actionLabel: 'عرض الكل',
                  onAction: _openNotifications,
                ),
                const SizedBox(height: 10),
                _SurfaceCard(
                  padding: EdgeInsets.zero,
                  child: _MenuRow(
                    icon: Icons.notifications_none_rounded,
                    title: 'مركز الإشعارات',
                    subtitle: notificationCount > 0
                        ? '$notificationCount إشعار جديد'
                        : 'تابع تحديثات الطلبات والمتجر',
                    trailing: notificationCount > 0
                        ? _CountBadge(count: notificationCount)
                        : null,
                    onTap: _openNotifications,
                  ),
                ),
                const SizedBox(height: 22),
                const _SectionHeading(title: 'الحساب والتفضيلات'),
                const SizedBox(height: 10),
                _SurfaceCard(
                  child: _SellerInformation(
                    name: sellerName,
                    phone: seller?.phone,
                    email: seller?.email,
                    onEdit: () => _push(const ProfileScreen()),
                  ),
                ),
                const SizedBox(height: 10),
                _SurfaceCard(
                  padding: EdgeInsets.zero,
                  child: _MenuRow(
                    icon: Icons.tune_rounded,
                    title: 'إعدادات التطبيق',
                    subtitle: 'اللغة وإعدادات الشحن',
                    onTap: () => _push(const SettingsScreen()),
                  ),
                ),
                const SizedBox(height: 22),
                const _SectionHeading(title: 'المساعدة والدعم'),
                const SizedBox(height: 10),
                _SurfaceCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _MenuRow(
                        icon: Icons.chat_bubble_outline_rounded,
                        iconColor: ColorResources.getSuccess(context),
                        title: 'تواصل مع دعم التجار',
                        subtitle: '+967 775 667 733',
                        onTap: _openWhatsAppSupport,
                      ),
                      if (config?.staticUrls?.faq?.trim().isNotEmpty ==
                          true) ...[
                        _RowDivider(),
                        _MenuRow(
                          icon: Icons.help_outline_rounded,
                          title: 'الأسئلة الشائعة',
                          subtitle: 'إجابات ومعلومات المساعدة',
                          onTap: () => _openExternalHelpPage(
                            config?.staticUrls?.faq,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (legalPages.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  const _SectionHeading(title: 'معلومات قانونية'),
                  const SizedBox(height: 10),
                  _SurfaceCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (var index = 0;
                            index < legalPages.length;
                            index++) ...[
                          if (index > 0) _RowDivider(),
                          _MenuRow(
                            icon: legalPages[index].$3,
                            title: legalPages[index].$2,
                            subtitle: 'معلومات Alline الرسمية',
                            onTap: () => _push(
                              HtmlViewScreen(page: legalPages[index].$1!),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                _LogoutTile(
                  onTap: () => showModalBottomSheet<void>(
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (_) => const SignOutConfirmationDialogWidget(),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'تطبيق التاجر من Alline  ·  الإصدار ${AppConstants.appVersion}',
                  textAlign: TextAlign.center,
                  style: _textStyle(
                    context,
                    size: 11,
                    color: ColorResources.getTextSubTitle(context),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}

BusinessPageModel? _businessPageBySlug(
  String slug,
  List<BusinessPageModel> pages,
) {
  for (final page in pages) {
    if (page.slug == slug) return page;
  }
  return null;
}

TextStyle _textStyle(
  BuildContext context, {
  double size = 14,
  FontWeight weight = FontWeight.w400,
  Color? color,
}) {
  return TextStyle(
    fontFamily: 'AllineTajawal',
    fontSize: size,
    fontWeight: weight,
    color: color ?? ColorResources.getTextTitle(context),
  );
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.storeName,
    required this.sellerName,
    required this.logoUrl,
    required this.coverUrl,
  });

  final String storeName;
  final String sellerName;
  final String? logoUrl;
  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    final hasCover = coverUrl?.isNotEmpty == true;
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        height: 176,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                  colors: [Color(0xFF032C75), Color(0xFF015FC9)],
                ),
              ),
            ),
            if (hasCover)
              Image.network(
                coverUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: AlignmentDirectional.topCenter,
                  end: AlignmentDirectional.bottomCenter,
                  colors: [Color(0x12032C75), Color(0xA8032C75)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(18, 18, 18, 18),
              child: Align(
                alignment: AlignmentDirectional.bottomStart,
                child: Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 14,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: logoUrl?.isNotEmpty == true
                            ? Image.network(
                                logoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const _StorePlaceholder(),
                              )
                            : const _StorePlaceholder(),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            storeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _textStyle(
                              context,
                              size: 21,
                              weight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            sellerName.isNotEmpty
                                ? 'حساب البائع · $sellerName'
                                : 'حساب البائع على Alline',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _textStyle(
                              context,
                              size: 12,
                              color: Colors.white.withValues(alpha: .82),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StorePlaceholder extends StatelessWidget {
  const _StorePlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF4F8FE),
      child: Icon(
        Icons.storefront_rounded,
        color: ColorResources.getPrimary(context),
        size: 34,
      ),
    );
  }
}

class _ProfileLoadingSkeleton extends StatelessWidget {
  const _ProfileLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF22314A)
        : const Color(0xFFE8EEF7);
    final highlight = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2C3E5C)
        : Colors.white;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Column(
        children: [
          Container(
            height: 176,
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(22),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileLoadError extends StatelessWidget {
  const _ProfileLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 30,
            color: ColorResources.getTextSubTitle(context),
          ),
          const SizedBox(height: 8),
          Text(
            'تعذر تحميل بيانات الحساب',
            style: _textStyle(context, size: 15, weight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}

class _StoreStatusCard extends StatelessWidget {
  const _StoreStatusCard({
    required this.isOpen,
    required this.isVacation,
    required this.hasStoreData,
    required this.isLoadingData,
    required this.isUpdating,
    required this.onChanged,
    required this.onRetry,
    required this.onManageVacation,
  });

  final bool isOpen;
  final bool isVacation;
  final bool hasStoreData;
  final bool isLoadingData;
  final bool isUpdating;
  final ValueChanged<bool> onChanged;
  final VoidCallback onRetry;
  final VoidCallback onManageVacation;

  @override
  Widget build(BuildContext context) {
    final stateColor = isVacation
        ? ColorResources.getWarning(context)
        : isOpen
            ? ColorResources.getSuccess(context)
            : ColorResources.getError(context);
    final title = !hasStoreData
        ? isLoadingData
            ? 'جارٍ تحميل حالة المتجر'
            : 'تعذر تحميل حالة المتجر'
        : isVacation
            ? 'المتجر في إجازة'
            : isOpen
                ? 'المتجر مفتوح'
                : 'المتجر مغلق';
    final subtitle = !hasStoreData
        ? isLoadingData
            ? 'نحمّل بيانات متجرك الآن'
            : 'تحقق من الاتصال ثم أعد المحاولة'
        : isVacation
            ? 'لن يستقبل المتجر طلبات أثناء الإجازة'
            : isOpen
                ? 'يستقبل الطلبات الآن'
                : 'لن يستقبل طلبات جديدة حتى إعادة الفتح';

    return _SurfaceCard(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 12, 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: stateColor.withValues(alpha: .11),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isVacation
                  ? Icons.beach_access_rounded
                  : Icons.store_mall_directory_outlined,
              color: stateColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: _textStyle(context, size: 15, weight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _textStyle(
                    context,
                    size: 12,
                    color: ColorResources.getTextSubTitle(context),
                  ),
                ),
                if (!hasStoreData && !isLoadingData) ...[
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: onRetry,
                    child: Text(
                      'إعادة المحاولة',
                      style: _textStyle(
                        context,
                        size: 12,
                        weight: FontWeight.w700,
                        color: ColorResources.getPrimary(context),
                      ),
                    ),
                  ),
                ],
                if (isVacation && hasStoreData) ...[
                  const SizedBox(height: 7),
                  InkWell(
                    onTap: onManageVacation,
                    child: Text(
                      'إدارة الإجازة',
                      style: _textStyle(
                        context,
                        size: 12,
                        weight: FontWeight.w700,
                        color: ColorResources.getPrimary(context),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isUpdating || (!hasStoreData && isLoadingData))
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: ColorResources.getPrimary(context),
              ),
            )
          else
            Switch.adaptive(
              value: isOpen,
              onChanged: hasStoreData && !isVacation ? onChanged : null,
              activeTrackColor: ColorResources.getSuccess(context),
            ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: _textStyle(context, size: 17, weight: FontWeight.w700),
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              minimumSize: const Size(44, 44),
              padding: const EdgeInsetsDirectional.only(start: 8, end: 4),
              foregroundColor: ColorResources.getPrimary(context),
            ),
            child: Text(
              actionLabel!,
              style: _textStyle(
                context,
                size: 13,
                weight: FontWeight.w700,
                color: ColorResources.getPrimary(context),
              ),
            ),
          ),
      ],
    );
  }
}

class _StoreInformationCard extends StatelessWidget {
  const _StoreInformationCard({
    required this.name,
    required this.phone,
    required this.address,
    required this.storeType,
    required this.latitude,
    required this.longitude,
    required this.onEdit,
  });

  final String? name;
  final String? phone;
  final String? address;
  final String? storeType;
  final String? latitude;
  final String? longitude;
  final VoidCallback onEdit;

  String _display(String? value, {String fallback = 'لم تتم إضافته'}) {
    return value?.trim().isNotEmpty == true ? value!.trim() : fallback;
  }

  @override
  Widget build(BuildContext context) {
    final latitudeValue = double.tryParse(latitude ?? '');
    final longitudeValue = double.tryParse(longitude ?? '');
    final position = latitudeValue != null &&
            longitudeValue != null &&
            latitudeValue.isFinite &&
            longitudeValue.isFinite &&
            latitudeValue >= -90 &&
            latitudeValue <= 90 &&
            longitudeValue >= -180 &&
            longitudeValue <= 180
        ? LatLng(latitudeValue, longitudeValue)
        : null;
    final location = address?.trim().isNotEmpty == true
        ? address!.trim()
        : position != null
            ? 'تم تحديد إحداثيات الموقع'
            : 'لم يتم تحديد موقع المتجر';
    return _SurfaceCard(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 5, 16, 10),
      child: Column(
        children: [
          _StoreDataRow(
            icon: Icons.store_outlined,
            label: 'اسم المتجر',
            value: _display(name),
            onTap: onEdit,
          ),
          _RowDivider(),
          _StoreDataRow(
            icon: Icons.category_outlined,
            label: 'نوع المتجر',
            value: storeType == 'supermarket'
                ? 'سوبر ماركت'
                : storeType == 'general'
                    ? 'متجر عام'
                    : 'غير محدد',
            onTap: onEdit,
          ),
          _RowDivider(),
          _StoreDataRow(
            icon: Icons.phone_outlined,
            label: 'هاتف المتجر',
            value: _display(phone),
            ltrValue: phone?.trim().isNotEmpty == true,
            onTap: onEdit,
          ),
          _RowDivider(),
          _StoreDataRow(
            icon: Icons.location_on_outlined,
            label: 'موقع المتجر',
            value: location,
            missing: address?.trim().isNotEmpty != true && position == null,
            onTap: onEdit,
          ),
          if (position != null) ...[
            const SizedBox(height: 7),
            _StoreMapPreview(position: position),
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 17),
              label: const Text('تعديل بيانات المتجر'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ColorResources.getPrimary(context),
                side: BorderSide(color: ColorResources.getBorder(context)),
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle:
                    _textStyle(context, size: 14, weight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreMapPreview extends StatelessWidget {
  const _StoreMapPreview({required this.position});

  final LatLng position;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 112,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: position, zoom: 14),
          markers: {
            Marker(
                markerId: const MarkerId('seller_store'), position: position),
          },
          zoomControlsEnabled: false,
          zoomGesturesEnabled: false,
          scrollGesturesEnabled: false,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
        ),
      ),
    );
  }
}

class _StoreDataRow extends StatelessWidget {
  const _StoreDataRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.ltrValue = false,
    this.missing = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool ltrValue;
  final bool missing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Icon(icon, color: ColorResources.getPrimary(context), size: 20),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: _textStyle(
                      context,
                      size: 11,
                      color: ColorResources.getTextSubTitle(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Directionality(
                    textDirection:
                        ltrValue ? TextDirection.ltr : TextDirection.rtl,
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: ltrValue ? TextAlign.right : TextAlign.start,
                      style: _textStyle(
                        context,
                        size: 14,
                        weight: FontWeight.w600,
                        color: missing
                            ? ColorResources.getTextSubTitle(context)
                            : ColorResources.getTextTitle(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left_rounded,
              size: 21,
              color: ColorResources.getTextSubTitle(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionItem {
  const _ActionItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
}

class _SellerInformation extends StatelessWidget {
  const _SellerInformation({
    required this.name,
    required this.phone,
    required this.email,
    required this.onEdit,
  });

  final String name;
  final String? phone;
  final String? email;
  final VoidCallback onEdit;

  String _value(String? value) =>
      value?.trim().isNotEmpty == true ? value!.trim() : 'لم تتم إضافته';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StoreDataRow(
          icon: Icons.person_outline_rounded,
          label: 'اسم البائع',
          value: _value(name),
          onTap: onEdit,
        ),
        _RowDivider(),
        _StoreDataRow(
          icon: Icons.phone_outlined,
          label: 'هاتف حساب البائع',
          value: _value(phone),
          ltrValue: phone?.trim().isNotEmpty == true,
          onTap: onEdit,
        ),
        _RowDivider(),
        _StoreDataRow(
          icon: Icons.email_outlined,
          label: 'بريد حساب البائع',
          value: _value(email),
          ltrValue: email?.trim().isNotEmpty == true,
          onTap: onEdit,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 17),
            label: const Text('تعديل بيانات الحساب'),
            style: OutlinedButton.styleFrom(
              foregroundColor: ColorResources.getPrimary(context),
              side: BorderSide(color: ColorResources.getBorder(context)),
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: _textStyle(context, size: 14, weight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({required this.actions});

  final List<_ActionItem> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final action in actions)
              SizedBox(
                width: itemWidth,
                child: _SurfaceCard(
                  padding: EdgeInsets.zero,
                  child: InkWell(
                    onTap: action.onTap,
                    borderRadius: BorderRadius.circular(18),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        12,
                        12,
                        12,
                        12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: ColorResources.getPrimary(context)
                                  .withValues(alpha: .09),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              action.icon,
                              color: action.iconColor ??
                                  ColorResources.getPrimary(context),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              action.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: _textStyle(
                                context,
                                size: 13,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _WalletShortcut extends StatelessWidget {
  const _WalletShortcut({required this.balance, required this.onTap});

  final double balance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorResources.getCardBg(context),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 15, 16, 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ColorResources.getBorder(context)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color:
                      ColorResources.getPrimary(context).withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: ColorResources.getPrimary(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الرصيد القابل للسحب',
                      style: _textStyle(
                        context,
                        size: 12,
                        color: ColorResources.getTextSubTitle(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      PriceConverter.convertPrice(context, balance),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _textStyle(context,
                          size: 17, weight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_left_rounded,
                color: ColorResources.getTextSubTitle(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 23,
              color: iconColor ?? ColorResources.getPrimary(context),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        _textStyle(context, size: 14, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _textStyle(
                      context,
                      size: 12,
                      color: ColorResources.getTextSubTitle(context),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_left_rounded,
              size: 21,
              color: ColorResources.getTextSubTitle(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 32,
      color: ColorResources.getBorder(context).withValues(alpha: .75),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard(
      {required this.child, this.padding = const EdgeInsets.all(14)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: ColorResources.getCardBg(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ColorResources.getBorder(context)),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? const []
            : const [
                BoxShadow(
                  color: Color(0x08032C75),
                  blurRadius: 16,
                  offset: Offset(0, 5),
                ),
              ],
      ),
      child: child,
    );
  }
}

class _NotificationAction extends StatelessWidget {
  const _NotificationAction({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: 'الإشعارات',
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            color: ColorResources.getTextTitle(context),
          ),
          if (count > 0)
            PositionedDirectional(
              top: -5,
              end: -7,
              child: Container(
                constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: ColorResources.getError(context),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: ColorResources.getScaffoldBg(context)),
                ),
                child: Center(
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: _textStyle(
                      context,
                      size: 9,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: ColorResources.getPrimary(context).withValues(alpha: .1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: _textStyle(
          context,
          size: 11,
          weight: FontWeight.w700,
          color: ColorResources.getPrimary(context),
        ),
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final error = ColorResources.getError(context);
    return Material(
      color: ColorResources.getCardBg(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 54),
          padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: error.withValues(alpha: .25)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: error, size: 20),
              const SizedBox(width: 9),
              Text(
                'تسجيل الخروج',
                style: _textStyle(
                  context,
                  size: 14,
                  weight: FontWeight.w700,
                  color: error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
