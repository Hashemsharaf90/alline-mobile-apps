import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_tokens.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/alline_state_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/floating_cart_bar.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/no_internet_screen_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/supermarket_product_card.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/seller_product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/controllers/shop_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/supermarket/widgets/sm_skeleton_widget.dart';
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
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final slug = widget.slug ?? '';
    final productController = context.read<SellerProductController>();
    try {
      if (slug.isNotEmpty) {
        await Future.wait([
          context.read<ShopController>().getSellerInfo(slug),
          context.read<CategoryController>().getSellerWiseCategoryList(slug),
        ]);
        final response =
            await productController.getSellerProductList(slug, 1, '');
        if (response.response?.statusCode != 200) _hasError = true;
      }
    } catch (_) {
      if (mounted) _hasError = true;
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLtr =
        Provider.of<LocalizationController>(context, listen: false).isLtr;
    final colors = context.allineColors;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar / Header
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: primary,
                leading: IconButton(
                  icon: Icon(
                    isLtr
                        ? Icons.arrow_back_ios_new_rounded
                        : Icons.arrow_forward_ios_rounded,
                    color: AllineColors.white,
                  ),
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
                        ColoredBox(color: primary),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AllineColors.primaryDark.withValues(alpha: 0.28),
                              AllineColors.primaryDark.withValues(alpha: 0.70),
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
                                color: colors.surfaceElevated,
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault),
                                border: Border.all(color: colors.border),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault),
                                child: (widget.image != null &&
                                        widget.image!.isNotEmpty)
                                    ? CustomImageWidget(
                                        image: widget.image!,
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(
                                        Icons.storefront,
                                        color: primary,
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
                                    widget.name ??
                                        (isLtr ? 'Supermarket' : 'سوبر ماركت'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textBold.copyWith(
                                      color: AllineColors.white,
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
                                          color: AllineColors.white
                                              .withValues(alpha: 0.85),
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          '${widget.distanceKm!.toStringAsFixed(1)} ${isLtr ? "km" : "كم"}',
                                          style: textRegular.copyWith(
                                            color: AllineColors.white
                                                .withValues(alpha: 0.9),
                                            fontSize:
                                                Dimensions.fontSizeExtraSmall,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      if (widget.estimatedDeliveryMinutes !=
                                              null &&
                                          widget.estimatedDeliveryMinutes! >
                                              0) ...[
                                        Icon(
                                          Icons.timer_outlined,
                                          size: 14,
                                          color: AllineColors.white
                                              .withValues(alpha: 0.85),
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          '${widget.estimatedDeliveryMinutes} ${isLtr ? "min" : "دقيقة"}',
                                          style: textRegular.copyWith(
                                            color: AllineColors.white
                                                .withValues(alpha: 0.9),
                                            fontSize:
                                                Dimensions.fontSizeExtraSmall,
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
              if (!_isLoading &&
                  context
                      .watch<CategoryController>()
                      .sellerWiseCategoryList
                      .isNotEmpty)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyCategoryDelegate(
                    child: Consumer<CategoryController>(
                      builder: (context, categoryController, _) {
                        final categories =
                            _getSupermarketCategories(categoryController);
                        if (categories.isEmpty) return const SizedBox.shrink();

                        return Container(
                          height: 52,
                          color: colors.surface,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall,
                              vertical: 8,
                            ),
                            itemCount: categories.length + 1,
                            itemBuilder: (context, index) {
                              final bool isSelected =
                                  _selectedCategoryIndex == index;
                              final String title = index == 0
                                  ? (isLtr ? 'All Items' : 'جميع الأصناف')
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
                                  selectedColor: primary,
                                  backgroundColor: colors.background,
                                  labelStyle: textMedium.copyWith(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.onPrimary
                                        : colors.textPrimary,
                                    fontSize: Dimensions.fontSizeSmall,
                                  ),
                                  showCheckmark: false,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color:
                                          isSelected ? primary : colors.border,
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
              Consumer<SellerProductController>(
                builder: (context, sellerProductController, _) {
                  List<Product> products = widget.slug?.isNotEmpty == true
                      ? List<Product>.from(
                          sellerProductController.sellerProduct?.products ??
                              <Product>[],
                        )
                      : <Product>[];

                  // Filter by category if selected
                  if (_selectedCategoryId != null) {
                    products = products.where((p) {
                      if (p.categoryIds != null && p.categoryIds!.isNotEmpty) {
                        return p.categoryIds!
                            .any((c) => c.id == _selectedCategoryId.toString());
                      }
                      return false;
                    }).toList();
                  }

                  if (_isLoading) {
                    return const SliverFillRemaining(
                      child: SmProductListSkeleton(),
                    );
                  }

                  if (_hasError) {
                    return SliverFillRemaining(
                      child: AllineErrorState(
                        title: 'تعذر تحميل منتجات المتجر',
                        message: 'تحقق من اتصالك ثم حاول مرة أخرى.',
                        onRetry: _loadData,
                      ),
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
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AllineSpacing.sm,
                      AllineSpacing.sm,
                      AllineSpacing.sm,
                      96, // Space for floating cart
                    ),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            MediaQuery.sizeOf(context).width < 320 ? 1 : 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        mainAxisExtent: 268,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return SupermarketProductCard(
                              product: products[index]);
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
  List<_StoreCategoryItem> _getSupermarketCategories(
      CategoryController controller) {
    final List<_StoreCategoryItem> list = [];

    for (final category in controller.sellerWiseCategoryList) {
      if (category.id != null && (category.name?.trim().isNotEmpty ?? false)) {
        list.add(_StoreCategoryItem(id: category.id, name: category.name!));
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
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      elevation: overlapsContent ? 3 : 0,
      shadowColor: Theme.of(context).shadowColor.withValues(alpha: 0.10),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _StickyCategoryDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
