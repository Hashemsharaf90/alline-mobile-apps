import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/controllers/address_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/domain/models/address_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/controllers/banner_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/brand/controllers/brand_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/widgets/floating_smart_cart_bar.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/clearance_sale/widgets/clearance_sale_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/controllers/featured_deal_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_categories_grid_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_featured_offers_section_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_nearby_stores_section_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_promo_banner_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_search_field_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_smart_header_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_supermarket_section_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/product_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/product_type_popup_menu_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/controllers/notification_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/order/controllers/order_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/seller_product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/widgets/home_category_product_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/widgets/latest_product_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/widgets/recommended_product_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/controllers/shop_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class AsterThemeHomeScreen extends StatefulWidget {
  const AsterThemeHomeScreen({super.key});

  static bool _locationServicePromptShowing = false;
  static bool _locationServicePromptDismissed = false;
  static bool _locationSettingsOpened = false;

  @override
  State<AsterThemeHomeScreen> createState() => _AsterThemeHomeScreenState();

  static bool _hasUsableCoordinates(AddressModel address) {
    return (address.latitude?.trim().isNotEmpty ?? false) &&
        (address.longitude?.trim().isNotEmpty ?? false);
  }

  static Future<List<String>?> _getCurrentLocationCoordinates() async {
    try {
      final serviceEnabled = await _ensureLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null ||
          (position.latitude == 0 && position.longitude == 0)) {
        return null;
      }

      return [position.latitude.toString(), position.longitude.toString()];
    } catch (_) {
      return null;
    }
  }

  static Future<bool> _ensureLocationServiceEnabled() async {
    if (await Geolocator.isLocationServiceEnabled()) {
      return true;
    }

    await _showEnableLocationServiceDialog();
    return Geolocator.isLocationServiceEnabled();
  }

  static Future<void> _showEnableLocationServiceDialog() async {
    final context = Get.context;
    if (context == null ||
        _locationServicePromptShowing ||
        _locationServicePromptDismissed) {
      return;
    }

    _locationServicePromptShowing = true;
    final isLtr = Directionality.of(context) == TextDirection.ltr;
    final openSettings = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        title: Text(isLtr ? 'Enable location' : 'تشغيل الموقع'),
        content: Text(
          isLtr
              ? 'Turn on GPS so we can show nearby supermarkets on the map.'
              : 'فعّل GPS حتى نعرض لك السوبرماركت الأقرب على الخريطة حسب موقعك الحالي.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(isLtr ? 'Later' : 'لاحقًا'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(isLtr ? 'Open settings' : 'فتح الإعدادات'),
          ),
        ],
      ),
    );

    _locationServicePromptShowing = false;
    if (openSettings == true) {
      _locationSettingsOpened = true;
      await Geolocator.openLocationSettings();
      return;
    }

    _locationServicePromptDismissed = true;
  }

  static Future<void> loadData(bool reload) async {
    final shopController =
        Provider.of<ShopController>(Get.context!, listen: false);
    final addressController =
        Provider.of<AddressController>(Get.context!, listen: false);
    final categoryController =
        Provider.of<CategoryController>(Get.context!, listen: false);
    final bannerController =
        Provider.of<BannerController>(Get.context!, listen: false);
    final productController =
        Provider.of<ProductController>(Get.context!, listen: false);
    final brandController =
        Provider.of<BrandController>(Get.context!, listen: false);
    final featuredDealController =
        Provider.of<FeaturedDealController>(Get.context!, listen: false);
    final notificationController =
        Provider.of<NotificationController>(Get.context!, listen: false);
    final cartController =
        Provider.of<CartController>(Get.context!, listen: false);
    final profileController =
        Provider.of<ProfileController>(Get.context!, listen: false);
    final sellerProductController =
        Provider.of<SellerProductController>(Get.context!, listen: false);
    final orderController =
        Provider.of<OrderController>(Get.context!, listen: false);
    final splashController =
        Provider.of<SplashController>(Get.context!, listen: false);

    splashController.initConfig(Get.context!, null, null);

    shopController.getAllSellerList(offset: 1, isUpdate: reload);

    cartController.getCartData(Get.context!);

    bannerController.getBannerList();

    categoryController.getCategoryList(reload);

    final addresses = await addressController.getAddressList();
    AddressModel? locationAddress;
    for (final address in addresses ?? []) {
      if (_hasUsableCoordinates(address) && address.isBilling != true) {
        locationAddress = address;
        break;
      }
    }
    for (final address in addresses ?? []) {
      if (locationAddress == null && _hasUsableCoordinates(address)) {
        locationAddress = address;
        break;
      }
    }
    final currentLocationCoordinates = await _getCurrentLocationCoordinates();
    final supermarketLatitude =
        currentLocationCoordinates?[0] ?? locationAddress?.latitude;
    final supermarketLongitude =
        currentLocationCoordinates?[1] ?? locationAddress?.longitude;
    productController.setSupermarketLocationSource(
      latitude: supermarketLatitude,
      longitude: supermarketLongitude,
      usingCurrentLocation: currentLocationCoordinates != null,
    );

    productController.getHomeCategoryProductList(reload);

    shopController.getTopSellerList(offset: 1, isUpdate: reload);

    brandController.getBrandList(offset: 1, isUpdate: reload);

    productController.getLatestProductList(1, isUpdate: false);
    productController.getSupermarketProductList(
      1,
      isUpdate: reload,
      latitude: supermarketLatitude,
      longitude: supermarketLongitude,
    );
    productController.getNearbySupermarkets(
      isUpdate: reload,
      latitude: supermarketLatitude,
      longitude: supermarketLongitude,
    );
    productController.getSelectedProductModel(1, isUpdate: false);

    productController.getFeaturedProductModel(1, isUpdate: reload);

    featuredDealController.getFeaturedDealList();

    // productController.getLProductList('1', reload: reload);

    productController.getRecommendedProduct();

    productController.findWhatYouNeed();

    productController.getJustForYouProduct(1, isUpdate: reload);

    shopController.getMoreStore();

    productController.getClearanceAllProductList(1, isUpdate: reload);

    if (notificationController.notificationModel == null ||
        (notificationController.notificationModel != null &&
            notificationController.notificationModel!.notification!.isEmpty) ||
        reload) {
      notificationController.getNotificationList(1);
    }

    if (Provider.of<AuthController>(Get.context!, listen: false).isLoggedIn()) {
      if (profileController.userInfoModel == null) {
        profileController.getUserInfo(Get.context!);
      }

      sellerProductController.getShopAgainFromRecentStore();

      if (orderController.orderModel == null ||
          (orderController.orderModel != null &&
              orderController.orderModel!.orders!.isEmpty) ||
          reload) {
        orderController.getOrderList(1, 'delivered', type: 'reorder');
      }
    }
  }
}

class _AsterThemeHomeScreenState extends State<AsterThemeHomeScreen>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        AsterThemeHomeScreen._locationSettingsOpened) {
      AsterThemeHomeScreen._locationSettingsOpened = false;
      AsterThemeHomeScreen._locationServicePromptDismissed = false;
      AsterThemeHomeScreen.loadData(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
          onRefresh: () async {
            await AsterThemeHomeScreen.loadData(true);
          },
          child: CustomScrollView(
            controller: _scrollController,
                        slivers: [
              const SliverToBoxAdapter(child: AllineSmartHeaderWidget()),
              const SliverToBoxAdapter(child: AllineSearchFieldWidget()),
              const SliverToBoxAdapter(child: AllineCategoriesGridWidget()),
              const SliverToBoxAdapter(child: AllinePromoBannerWidget()),
              const SliverToBoxAdapter(child: AllineNearbyStoresSectionWidget()),
              const SliverToBoxAdapter(child: AllineFeaturedOffersSectionWidget()),
              const SliverToBoxAdapter(child: AllineSupermarketSectionWidget()),
              const SliverToBoxAdapter(child: ClearanceListWidget()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: RecommendedProductWidget(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: LatestProductListWidget(),
                ),
              ),
              const HomeCategoryProductWidget(isHomePage: true),
              SliverPersistentHeader(
                pinned: true,
                delegate: SliverDelegate(
                  height: 50,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: const ProductPopupFilterWidget(),
                    ),
                  ),
                ),
              ),
              HomeProductListWidget(scrollController: _scrollController),
              const SliverToBoxAdapter(child: SizedBox(height: 90)),
            ],
          ),
        ),
        const FloatingSmartCartBar(),
      ],
    ),
  ),
);
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;
  SliverDelegate({required this.child, this.height = 70});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height ||
        oldDelegate.minExtent != height ||
        child != oldDelegate.child;
  }
}
