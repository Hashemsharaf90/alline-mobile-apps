import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/config_model.dart';
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
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/controllers/banner_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/widgets/banners_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/widgets/footer_banner_slider_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/widgets/single_banner_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/brand/controllers/brand_controller.dart';
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
import 'package:flutter_sixvalley_ecommerce/features/home/shimmers/order_again_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/shimmers/top_store_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/announcement_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/aster_theme/find_what_you_need_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/aster_theme/find_what_you_need_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/aster_theme/more_store_list_view_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/aster_theme/order_again_list_view_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/featured_product_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/just_for_you/just_for_you_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/product_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/product_type_popup_menu_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/search_home_page_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/controllers/notification_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/order/controllers/order_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/seller_product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/enums/product_type.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/widgets/home_category_product_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/widgets/latest_product_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/widgets/recommended_product_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/controllers/shop_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/widgets/more_store_list_view.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/top_seller_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/responsive_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';

class AsterThemeHomeScreen extends StatefulWidget {
  const AsterThemeHomeScreen({super.key});

  @override
  State<AsterThemeHomeScreen> createState() => _AsterThemeHomeScreenState();

  static Future<void> loadData(bool reload) async {
    final shopController =
        Provider.of<ShopController>(Get.context!, listen: false);
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

    productController.getHomeCategoryProductList(reload);

    shopController.getTopSellerList(offset: 1, isUpdate: reload);

    brandController.getBrandList(offset: 1, isUpdate: reload);

    productController.getLatestProductList(1, isUpdate: false);
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

class _AsterThemeHomeScreenState extends State<AsterThemeHomeScreen> {
  final ScrollController _scrollController = ScrollController();

  void passData(int index, String title) {
    index = index;
    title = title;
  }

  bool singleVendor = false;
  @override
  void initState() {
    super.initState();

    singleVendor = Provider.of<SplashController>(context, listen: false)
            .configModel
            ?.businessMode ==
        "single";
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
