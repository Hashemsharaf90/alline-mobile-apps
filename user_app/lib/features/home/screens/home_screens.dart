import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_smart_header_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_search_field_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_categories_grid_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_promo_banner_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_nearby_stores_section_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_featured_offers_section_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_services_grid_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_home_all_products_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/controllers/address_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/domain/models/address_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/controllers/banner_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/brand/controllers/brand_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/controllers/featured_deal_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/controllers/flash_deal_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/controllers/notification_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/controllers/shop_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/features/location/controllers/location_controller.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();

  static bool _hasUsableCoordinates(AddressModel address) {
    return (address.latitude?.trim().isNotEmpty ?? false) &&
        (address.longitude?.trim().isNotEmpty ?? false);
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
    final location =
        Provider.of<LocationController>(Get.context!, listen: false);
    await location.restoreDeliveryLocation();
    if (location.deliveryLatitude == null && locationAddress != null) {
      final lat = double.tryParse(locationAddress.latitude ?? '');
      final lng = double.tryParse(locationAddress.longitude ?? '');
      if (lat != null && lng != null) {
        await location.setPickedCoordinates(
            latitude: lat,
            longitude: lng,
            fromAddress: true,
            address: locationAddress.address?.isNotEmpty == true
                ? locationAddress.address
                : 'موقع التوصيل المحدد',
            context: Get.context!);
        await location.confirmDeliveryLocation();
      }
    }
    final supermarketLatitude = location.deliveryLatitude?.toString();
    final supermarketLongitude = location.deliveryLongitude?.toString();
    productController.setSupermarketLocationSource(
      latitude: supermarketLatitude,
      longitude: supermarketLongitude,
      usingCurrentLocation: false,
    );

    cartController.getCartData(Get.context!);

    productController.getHomeCategoryProductList(reload);

    brandController.getBrandList(offset: 1, isUpdate: reload);

    featuredDealController.getFeaturedDealList();

    // productController.getLProductList('1', reload: reload);

    productController.getLatestProductList(1, isUpdate: reload);
    productController.getHomeBestSellingProducts(reload: reload);
    productController.getDiscountedProductList(1, reload);
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

    productController.getHomeAllProductList(1, reload: reload);

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
    _scrollController.addListener(_onScroll);

    singleVendor = Provider.of<SplashController>(context, listen: false)
            .configModel
            ?.businessMode ==
        "single";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productController =
          Provider.of<ProductController>(context, listen: false);
      if (productController.homeAllProductModel == null) {
        productController.getHomeAllProductList(1);
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= 600) {
      final productController =
          Provider.of<ProductController>(context, listen: false);
      final model = productController.homeAllProductModel;
      if (model != null &&
          !productController.isHomeAllProductLoading &&
          !productController.isHomeAllProductLoadingMore) {
        final totalSize = model.totalSize;
        final currentLength = model.products?.length ?? 0;
        if (totalSize == null || currentLength < totalSize) {
          final nextOffset = (model.offset ?? 1) + 1;
          productController.getHomeAllProductList(nextOffset);
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? context.allineColors.background
          : context.allineColors.surface,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await HomePage.loadData(true);
          },
          child: CustomScrollView(
            key: const PageStorageKey<String>('home_screen_scroll_key'),
            controller: _scrollController,
            cacheExtent: 900,
            slivers: [
              const SliverToBoxAdapter(child: AllineSmartHeaderWidget()),
              const SliverToBoxAdapter(child: AllineSearchFieldWidget()),
              const SliverToBoxAdapter(child: AllineServicesGridWidget()),
              const SliverToBoxAdapter(child: AllineCategoriesGridWidget()),
              const SliverToBoxAdapter(child: AllinePromoBannerWidget()),
              const SliverToBoxAdapter(
                  child: AllineNearbyStoresSectionWidget()),
              const SliverToBoxAdapter(child: AllineHomeProductDiscovery()),
              const AllineHomeAllProductsSectionWidget(),
              const SliverToBoxAdapter(child: SizedBox(height: 104)),
            ],
          ),
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
