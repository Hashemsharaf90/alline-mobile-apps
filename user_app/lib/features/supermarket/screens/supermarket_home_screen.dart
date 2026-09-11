import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/floating_cart_bar.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/supermarket_product_card.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/domain/models/category_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/supermarket/screens/supermarket_store_screen.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

/// The Dedicated Supermarket Module Home Screen.
/// Filters strictly to Supermarket-only subcategories (Dairy, Produce, Canned, Drinks...)
/// and Supermarket-only products.
class SupermarketHomeScreen extends StatefulWidget {
  const SupermarketHomeScreen({super.key});

  @override
  State<SupermarketHomeScreen> createState() => _SupermarketHomeScreenState();
}

class _SupermarketHomeScreenState extends State<SupermarketHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  int _selectedCategoryIndex = 0;
  int? _selectedCategoryId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final productCtrl =
        Provider.of<ProductController>(Get.context!, listen: false);
    final catCtrl =
        Provider.of<CategoryController>(Get.context!, listen: false);

    await Future.wait([
      productCtrl.getSupermarketProductList(1),
      productCtrl.getNearbySupermarkets(
        latitude: productCtrl.supermarketLatitude,
        longitude: productCtrl.supermarketLongitude,
      ),
      catCtrl.getCategoryList(false),
    ]);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLtr =
        Provider.of<LocalizationController>(context, listen: false).isLtr;
    final isDark =
        Provider.of<ThemeController>(context, listen: false).darkTheme;

    return Scaffold(
      backgroundColor:
          isDark ? Theme.of(context).cardColor : const Color(0xFFF7F9FA),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Custom Supermarket App Bar
              SliverAppBar(
                pinned: true,
                floating: false,
                elevation: 1,
                backgroundColor: Theme.of(context).primaryColor,
                leading: IconButton(
                  icon:
                      const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Row(
                  children: [
                    const Icon(Icons.shopping_basket_rounded,
                        color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isLtr ? 'Alline Supermarket' : 'سوبر ماركت أونلاين',
                          style: textBold.copyWith(
                              color: Colors.white,
                              fontSize: Dimensions.fontSizeLarge),
                        ),
                        Consumer<ProductController>(
                          builder: (context, productController, _) {
                            final lat = productController.supermarketLatitude;
                            return Text(
                              lat != null
                                  ? (isLtr
                                      ? 'Near you • Fast Delivery'
                                      : 'بالقرب منك • توصيل سريع')
                                  : (isLtr
                                      ? 'Select delivery location'
                                      : 'حدد موقع التوصيل'),
                              style: textRegular.copyWith(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 11),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Interactive Nearby Stores Map & List
              SliverToBoxAdapter(
                child: Consumer<ProductController>(
                  builder: (context, productController, _) {
                    final stores = productController.nearbySupermarkets
                        .whereType<Map>()
                        .toList();
                    final userLocation = _parseLatLng(
                        productController.supermarketLatitude,
                        productController.supermarketLongitude);

                    if (stores.isEmpty) return const SizedBox();

                    return Container(
                      margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusDefault),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(
                                Dimensions.paddingSizeSmall),
                            child: Row(
                              children: [
                                Icon(Icons.near_me_rounded,
                                    color: Theme.of(context).primaryColor,
                                    size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  isLtr
                                      ? 'Nearby Supermarkets on Map'
                                      : 'السوبرماركتات القريبة على الخريطة',
                                  style: textBold.copyWith(
                                      fontSize: Dimensions.fontSizeDefault),
                                ),
                                const Spacer(),
                                Text(
                                  '${stores.length} ${isLtr ? "stores" : "متاجر"}',
                                  style: textRegular.copyWith(
                                      color: Theme.of(context).hintColor,
                                      fontSize: Dimensions.fontSizeExtraSmall),
                                ),
                              ],
                            ),
                          ),

                          if (userLocation != null)
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radiusSmall),
                              child: Container(
                                height: 160,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeSmall),
                                child: GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: userLocation,
                                    zoom: 13,
                                  ),
                                  mapType: MapType.normal,
                                  compassEnabled: false,
                                  myLocationButtonEnabled: false,
                                  zoomControlsEnabled: false,
                                  mapToolbarEnabled: false,
                                  markers: {
                                    Marker(
                                      markerId:
                                          const MarkerId('customer-location'),
                                      position: userLocation,
                                      icon:
                                          BitmapDescriptor.defaultMarkerWithHue(
                                        BitmapDescriptor.hueAzure,
                                      ),
                                      infoWindow: const InfoWindow(
                                          title: 'Your location'),
                                    ),
                                    ...stores.map((store) {
                                      final lat = double.tryParse(
                                          store['latitude']?.toString() ?? '');
                                      final lng = double.tryParse(
                                          store['longitude']?.toString() ?? '');
                                      if (lat == null || lng == null)
                                        return null;
                                      final markerKey =
                                          store['id']?.toString() ??
                                              '$lat,$lng';

                                      return Marker(
                                        markerId:
                                            MarkerId('supermarket-$markerKey'),
                                        position: LatLng(lat, lng),
                                        icon: BitmapDescriptor
                                            .defaultMarkerWithHue(
                                          BitmapDescriptor.hueGreen,
                                        ),
                                        infoWindow: InfoWindow(
                                          title:
                                              store['name']?.toString() ?? '',
                                        ),
                                        onTap: () => _openStore(context, store),
                                      );
                                    }).whereType<Marker>(),
                                  },
                                ),
                              ),
                            ),

                          const SizedBox(height: 10),

                          // Horizontal Stores Row
                          SizedBox(
                            height: 85,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeSmall),
                              itemCount: stores.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final store = stores[index];
                                final name = store['name']?.toString() ?? '';
                                final distance = store['distance_km'] != null
                                    ? '${store['distance_km']} كم'
                                    : '';

                                return InkWell(
                                  onTap: () => _openStore(context, store),
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall),
                                  child: Container(
                                    width: 170,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Theme.of(context).highlightColor
                                          : const Color(0xFFF9FAFB),
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radiusSmall),
                                      border: Border.all(
                                          color: Theme.of(context)
                                              .dividerColor
                                              .withValues(alpha: 0.5)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .primaryColor
                                                .withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(
                                                Dimensions.radiusSmall),
                                          ),
                                          child: Icon(Icons.storefront_outlined,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              size: 20),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: textBold.copyWith(
                                                      fontSize: 12)),
                                              if (distance.isNotEmpty)
                                                Text(distance,
                                                    style: textRegular.copyWith(
                                                        color: Theme.of(context)
                                                            .hintColor,
                                                        fontSize: 10)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Supermarket-ONLY Sticky Category Bar
              SliverPersistentHeader(
                pinned: true,
                delegate: _SupermarketCategoryHeaderDelegate(
                  child: Consumer<CategoryController>(
                    builder: (context, categoryController, _) {
                      final categories =
                          _getSupermarketCategories(categoryController);

                      return Container(
                        height: 50,
                        color:
                            isDark ? Theme.of(context).cardColor : Colors.white,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall,
                              vertical: 6),
                          itemCount: categories.length + 1,
                          itemBuilder: (context, index) {
                            final bool isSelected =
                                _selectedCategoryIndex == index;
                            final String title = index == 0
                                ? (isLtr ? 'All Groceries' : 'جميع البقالة')
                                : categories[index - 1].name;

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: ChoiceChip(
                                label: Text(title),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedCategoryIndex = index;
                                      _selectedCategoryId = index == 0
                                          ? null
                                          : categories[index - 1].id;
                                    });
                                  }
                                },
                                selectedColor: Theme.of(context).primaryColor,
                                backgroundColor: isDark
                                    ? Theme.of(context).highlightColor
                                    : const Color(0xFFF0F2F5),
                                labelStyle: textMedium.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                                showCheckmark: false,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : Colors.transparent),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Grocery Products Grid
              Consumer<ProductController>(
                builder: (context, productController, _) {
                  List<Product> products =
                      productController.supermarketProductModel?.products ?? [];

                  if (_selectedCategoryId != null) {
                    products = products.where((p) {
                      if (p.categoryIds != null && p.categoryIds!.isNotEmpty) {
                        return p.categoryIds!
                            .any((c) => c.id == _selectedCategoryId.toString());
                      }
                      return true;
                    }).toList();
                  }

                  if (_isLoading) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (products.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          isLtr
                              ? 'No products found'
                              : 'لا توجد منتجات بقالة حالياً',
                          style: textMedium.copyWith(
                              color: Theme.of(context).hintColor),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      Dimensions.paddingSizeSmall,
                      Dimensions.paddingSizeSmall,
                      Dimensions.paddingSizeSmall,
                      80,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.68,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            SupermarketProductCard(product: products[index]),
                        childCount: products.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          // Persistent Floating Cart Summary Bar
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingCartBar(),
          ),
        ],
      ),
    );
  }

  /// Extracts ONLY Supermarket-specific categories & subcategories
  List<_GroceryCategoryItem> _getSupermarketCategories(
      CategoryController controller) {
    final List<_GroceryCategoryItem> list = [];

    // 1. Look for root Supermarket category
    CategoryModel? supermarketCat;
    for (final c in controller.categoryList) {
      final name = (c.name ?? '').toLowerCase();
      final slug = (c.slug ?? '').toLowerCase();
      if (slug == 'supermarket' ||
          name.contains('supermarket') ||
          name.contains('سوبر')) {
        supermarketCat = c;
        break;
      }
    }

    // 2. If it has subcategories, add them
    if (supermarketCat != null &&
        supermarketCat.subCategories != null &&
        supermarketCat.subCategories!.isNotEmpty) {
      for (final sub in supermarketCat.subCategories!) {
        list.add(_GroceryCategoryItem(id: sub.id, name: sub.name ?? ''));
      }
    }

    // 3. Fallback to standard grocery categories if subcategories not loaded yet in tree
    if (list.isEmpty) {
      final fallbackGroceryNames = [
        'ألبان وأجبان وبيض',
        'زيوت وسمن وأرز وسكر',
        'معلبات وبقوليات وتونة',
        'مشروبات وعصائر ومياه',
        'مخبوزات وحلويات وشوكولاتة',
        'خضار وفواكه طازجة',
        'لحوم ودواجن ومجمدات',
        'منظفات وعناية منزلية',
        'بهارات وتوابل ومكسرات',
      ];
      for (int i = 0; i < fallbackGroceryNames.length; i++) {
        list.add(
            _GroceryCategoryItem(id: 12139 + i, name: fallbackGroceryNames[i]));
      }
    }

    return list;
  }

  LatLng? _parseLatLng(String? lat, String? lng) {
    if (lat == null || lng == null) return const LatLng(15.3484, 44.2065);
    final double? parsedLat = double.tryParse(lat.trim());
    final double? parsedLng = double.tryParse(lng.trim());
    if (parsedLat == null || parsedLng == null)
      return const LatLng(15.3484, 44.2065);
    return LatLng(parsedLat, parsedLng);
  }

  void _openStore(BuildContext context, Map store) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SupermarketStoreScreen(
          slug: store['slug']?.toString(),
          sellerId: int.tryParse(store['seller_id']?.toString() ?? ''),
          name: store['name']?.toString(),
          banner: store['banner']?.toString(),
          image: store['image']?.toString(),
          address: store['address']?.toString(),
          distanceKm: double.tryParse(store['distance_km']?.toString() ?? ''),
          estimatedDeliveryMinutes: int.tryParse(
              store['estimated_delivery_minutes']?.toString() ?? ''),
        ),
      ),
    );
  }
}

class _GroceryCategoryItem {
  final int? id;
  final String name;
  _GroceryCategoryItem({required this.id, required this.name});
}

class _SupermarketCategoryHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  final Widget child;
  _SupermarketCategoryHeaderDelegate({required this.child});

  @override
  double get minExtent => 50;
  @override
  double get maxExtent => 50;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      elevation: overlapsContent ? 2 : 0,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _SupermarketCategoryHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
