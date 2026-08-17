import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/floating_cart_bar.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/no_internet_screen_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/supermarket_product_card.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/domain/models/category_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/seller_product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/controllers/shop_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

/// A dedicated, high-performance Supermarket Store screen tailored for grocery shoppers.
/// Features a store header, sticky grocery-only category navigation bar, high-density product grid with +/- quick add,
/// and a persistent bottom floating cart summary.
class SupermarketStoreScreen extends StatefulWidget {
  final String? slug;
  final int? sellerId;
  final String? name;
  final String? banner;
  final String? image;
  final String? address;
  final double? distanceKm;
  final int? estimatedDeliveryMinutes;

  const SupermarketStoreScreen({
    super.key,
    this.slug,
    this.sellerId,
    this.name,
    this.banner,
    this.image,
    this.address,
    this.distanceKm,
    this.estimatedDeliveryMinutes,
  });

  @override
  State<SupermarketStoreScreen> createState() => _SupermarketStoreScreenState();
}

class _SupermarketStoreScreenState extends State<SupermarketStoreScreen> {
  final ScrollController _scrollController = ScrollController();
  int _selectedCategoryIndex = 0; // 0 means 'All'
  int? _selectedCategoryId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final slug = widget.slug ?? '';
    if (slug.isNotEmpty) {
      await Provider.of<ShopController>(Get.context!, listen: false).getSellerInfo(slug);
      await Provider.of<CategoryController>(Get.context!, listen: false).getSellerWiseCategoryList(slug);
      await Provider.of<SellerProductController>(Get.context!, listen: false).getSellerProductList(slug, 1, "");
    }

    await Provider.of<ProductController>(Get.context!, listen: false).getSupermarketProductList(1);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLtr = Provider.of<LocalizationController>(context, listen: false).isLtr;
    final isDark = Provider.of<ThemeController>(context, listen: false).darkTheme;

    return Scaffold(
      backgroundColor: isDark ? Theme.of(context).cardColor : const Color(0xFFF6F8FA),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar / Header
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: Theme.of(context).primaryColor,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (widget.banner != null && widget.banner!.isNotEmpty)
                        CustomImageWidget(
                          image: widget.banner!,
                          fit: BoxFit.cover,
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor,
                                const Color(0xFF0F5B38),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.3),
                              Colors.black.withValues(alpha: 0.75),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: Dimensions.paddingSizeDefault,
                        right: Dimensions.paddingSizeDefault,
                        bottom: Dimensions.paddingSizeDefault,
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                child: (widget.image != null && widget.image!.isNotEmpty)
                                    ? CustomImageWidget(
                                        image: widget.image!,
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(
                                        Icons.storefront,
                                        color: Theme.of(context).primaryColor,
                                        size: 32,
                                      ),
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.name ?? (isLtr ? 'Supermarket' : 'سوبر ماركت'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textBold.copyWith(
                                      color: Colors.white,
                                      fontSize: Dimensions.fontSizeLarge,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      if (widget.distanceKm != null) ...[
                                        Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: Colors.white.withValues(alpha: 0.85),
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          '${widget.distanceKm!.toStringAsFixed(1)} ${isLtr ? "km" : "كم"}',
                                          style: textRegular.copyWith(
                                            color: Colors.white.withValues(alpha: 0.9),
                                            fontSize: Dimensions.fontSizeExtraSmall,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      if (widget.estimatedDeliveryMinutes != null &&
                                          widget.estimatedDeliveryMinutes! > 0) ...[
                                        Icon(
                                          Icons.timer_outlined,
                                          size: 14,
                                          color: Colors.white.withValues(alpha: 0.85),
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          '${widget.estimatedDeliveryMinutes} ${isLtr ? "min" : "دقيقة"}',
                                          style: textRegular.copyWith(
                                            color: Colors.white.withValues(alpha: 0.9),
                                            fontSize: Dimensions.fontSizeExtraSmall,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Grocery-only Sticky Categories Header
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyCategoryDelegate(
                  child: Consumer<CategoryController>(
                    builder: (context, categoryController, _) {
                      final categories = _getSupermarketCategories(categoryController);

                      return Container(
                        height: 52,
                        color: isDark ? Theme.of(context).cardColor : Colors.white,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeSmall,
                            vertical: 8,
                          ),
                          itemCount: categories.length + 1,
                          itemBuilder: (context, index) {
                            final bool isSelected = _selectedCategoryIndex == index;
                            final String title = index == 0
                                ? (isLtr ? 'All Items' : 'جميع الأصناف')
                                : categories[index - 1].name;

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: ChoiceChip(
                                label: Text(title),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedCategoryIndex = index;
                                      _selectedCategoryId = index == 0 ? null : categories[index - 1].id;
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
                                      : Theme.of(context).textTheme.bodyLarge?.color,
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                                showCheckmark: false,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Colors.transparent,
                                  ),
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

              // Products Grid
              Consumer2<SellerProductController, ProductController>(
                builder: (context, sellerProductController, productController, _) {
                  List<Product> products = [];
                  if (sellerProductController.sellerProduct != null &&
                      sellerProductController.sellerProduct!.products != null &&
                      sellerProductController.sellerProduct!.products!.isNotEmpty) {
                    products = List<Product>.from(sellerProductController.sellerProduct!.products!);
                  } else if (productController.supermarketProductModel?.products != null) {
                    products = List<Product>.from(productController.supermarketProductModel!.products!);
                  }

                  // Filter by category if selected
                  if (_selectedCategoryId != null) {
                    products = products.where((p) {
                      if (p.categoryIds != null && p.categoryIds!.isNotEmpty) {
                        return p.categoryIds!.any((c) => c.id == _selectedCategoryId.toString());
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
                        child: NoInternetOrDataScreenWidget(
                          isNoInternet: false,
                          message: isLtr
                              ? 'No grocery items available in this category'
                              : 'لا توجد منتجات بقالة في هذه الفئة حالياً',
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      Dimensions.paddingSizeSmall,
                      Dimensions.paddingSizeSmall,
                      Dimensions.paddingSizeSmall,
                      80, // Space for floating cart
                    ),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.68,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return SupermarketProductCard(product: products[index]);
                        },
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
  List<_StoreCategoryItem> _getSupermarketCategories(CategoryController controller) {
    final List<_StoreCategoryItem> list = [];

    // 1. Look for root Supermarket category
    CategoryModel? supermarketCat;
    for (final c in controller.categoryList) {
      final name = (c.name ?? '').toLowerCase();
      final slug = (c.slug ?? '').toLowerCase();
      if (slug == 'supermarket' || name.contains('supermarket') || name.contains('سوبر')) {
        supermarketCat = c;
        break;
      }
    }

    // 2. If it has subcategories, add them
    if (supermarketCat != null && supermarketCat.subCategories != null && supermarketCat.subCategories!.isNotEmpty) {
      for (final sub in supermarketCat.subCategories!) {
        list.add(_StoreCategoryItem(id: sub.id, name: sub.name ?? ''));
      }
    }

    // 3. Fallback to standard grocery categories
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
        list.add(_StoreCategoryItem(id: 12139 + i, name: fallbackGroceryNames[i]));
      }
    }

    return list;
  }
}

class _StoreCategoryItem {
  final int? id;
  final String name;
  _StoreCategoryItem({required this.id, required this.name});
}

class _StickyCategoryDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyCategoryDelegate({required this.child});

  @override
  double get minExtent => 52;
  @override
  double get maxExtent => 52;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      elevation: overlapsContent ? 3 : 0,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _StickyCategoryDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
