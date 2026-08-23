import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_smart_header_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_search_field_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_categories_grid_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_promo_banner_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_nearby_stores_section_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_featured_offers_section_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/widgets/floating_smart_cart_bar.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/widgets/floating_smart_cart_bar.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_smart_header_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_operation_status_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_services_grid_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_store_tabs_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/title_row_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/controllers/address_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/domain/models/address_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/controllers/banner_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/widgets/banners_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/widgets/footer_banner_slider_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/widgets/single_banner_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/brand/controllers/brand_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/brand/widgets/brand_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/widgets/category_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/clearance_sale/widgets/clearance_sale_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/controllers/featured_deal_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/controllers/flash_deal_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/widgets/featured_deal_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/widgets/flash_deals_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/widgets/global_shopping_section_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_supermarket_section_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/shimmers/flash_deal_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/announcement_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/aster_theme/find_what_you_need_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/featured_product_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/product_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/product_type_popup_menu_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/search_home_page_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/controllers/notification_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/widgets/home_category_product_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/widgets/latest_product_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/widgets/recommended_product_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/controllers/shop_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/top_seller_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/config_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/responsive_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static bool _locationServicePromptShowing = false;
  static bool _locationServicePromptDismissed = false;
  static bool _locationSettingsOpened = false;

  @override
  State<HomePage> createState() => _HomePageState();

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

      if (position == null) {
        return null;
      }

      if (position.latitude == 0 && position.longitude == 0) {
        return null;
      }

      return [
        position.latitude.toString(),
        position.longitude.toString(),
      ];
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
    final flashDealController =
        Provider.of<FlashDealController>(Get.context!, listen: false);
    final shopController =
        Provider.of<ShopController>(Get.context!, listen: false);
    final categoryController =
        Provider.of<CategoryController>(Get.context!, listen: false);
    final bannerController =
        Provider.of<BannerController>(Get.context!, listen: false);
    final addressController =
        Provider.of<AddressController>(Get.context!, listen: false);
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
    final splashController =
        Provider.of<SplashController>(Get.context!, listen: false);

    if (flashDealController.flashDealList.isEmpty || reload) {
      // await flashDealController.getFlashDealList(reload, false);
    }

    splashController.initConfig(Get.context!, null, null);

    categoryController.getCategoryList(reload);

    bannerController.getBannerList();

    shopController.getAllSellerList(offset: 1, isUpdate: reload);
    shopController.getTopSellerList(offset: 1, isUpdate: reload);

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

    cartController.getCartData(Get.context!);

    productController.getHomeCategoryProductList(reload);

    brandController.getBrandList(offset: 1, isUpdate: reload);

    featuredDealController.getFeaturedDealList();

    // productController.getLProductList('1', reload: reload);

    productController.getLatestProductList(1, isUpdate: reload);
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
    productController.getSelectedProductModel(1, isUpdate: reload);

    productController.getFeaturedProductModel(1, isUpdate: reload);

    productController.getRecommendedProduct();

    productController.getClearanceAllProductList(1, isUpdate: reload);

    if (notificationController.notificationModel == null ||
        (notificationController.notificationModel != null &&
            notificationController.notificationModel!.notification!.isEmpty) ||
        reload) {
      notificationController.getNotificationList(1);
    }

    if (Provider.of<AuthController>(Get.context!, listen: false).isLoggedIn() &&
        profileController.userInfoModel == null) {
      await profileController.getUserInfo(Get.context!);
    }
  }
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();

  void passData(int index, String title) {
    index = index;
    title = title;
  }

  bool singleVendor = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    singleVendor = Provider.of<SplashController>(context, listen: false)
            .configModel
            ?.businessMode ==
        "single";
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
        HomePage._locationSettingsOpened) {
      HomePage._locationSettingsOpened = false;
      HomePage._locationServicePromptDismissed = false;
      HomePage.loadData(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ConfigModel? configModel =
        Provider.of<SplashController>(context, listen: false).configModel;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
          onRefresh: () async {
            await HomePage.loadData(true);
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
              const SliverToBoxAdapter(child: GlobalShoppingSectionWidget()),
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
  SliverDelegate({required this.child, this.height = 50});

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

class SliverSearchDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;
  SliverSearchDelegate({required this.child, this.height = 70});

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
  bool shouldRebuild(covariant SliverSearchDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
