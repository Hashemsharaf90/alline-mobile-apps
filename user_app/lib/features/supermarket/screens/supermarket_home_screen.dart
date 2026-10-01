import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_tokens.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/alline_state_widget.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/floating_cart_bar.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/supermarket/widgets/sm_categories_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_product_card.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_section_header.dart';
import 'package:flutter_sixvalley_ecommerce/features/supermarket/widgets/sm_skeleton_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/supermarket/widgets/sm_header_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/supermarket/widgets/sm_nearby_stores_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/supermarket/widgets/sm_offers_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/supermarket/widgets/sm_search_bar_widget.dart';
import 'package:provider/provider.dart';

/// Alline Supermarket Hub — the dedicated grocery shopping experience.
///
/// Screen hierarchy (top → bottom):
///   1. [SmHeaderWidget]       — back, title, location, cart
///   2. [SmSearchBarWidget]    — "ابحث في السوبر ماركت"
///   3. [SmCategoriesWidget]   — horizontal icon category chips
///   4. [SmNearbyStoresWidget] — nearby supermarket store cards
///   5. [SmOffersWidget]       — discounted products
///   6. Lazy product grid     — complete catalog with pagination
///   7. [FloatingCartBar]      — persistent bottom cart summary
class SupermarketHomeScreen extends StatefulWidget {
  const SupermarketHomeScreen({super.key});

  @override
  State<SupermarketHomeScreen> createState() => _SupermarketHomeScreenState();
}

class _SupermarketHomeScreenState extends State<SupermarketHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadNextPage);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool forceReload = false}) async {
    setState(() {
      _hasError = false;
    });

    final productCtrl = context.read<ProductController>();
    final catCtrl = context.read<CategoryController>();
    try {
      await Future.wait([
        productCtrl.getSupermarketProductList(
          1,
          isUpdate: forceReload,
          latitude: productCtrl.supermarketLatitude,
          longitude: productCtrl.supermarketLongitude,
        ),
        productCtrl.getNearbySupermarkets(
          isUpdate: forceReload,
          latitude: productCtrl.supermarketLatitude,
          longitude: productCtrl.supermarketLongitude,
        ),
        catCtrl.getCategoryList(false),
      ].map((request) => request.then<void>((_) {}, onError: (Object _) {})));
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
      return;
    }

    if (mounted) {
      setState(() {
        _hasError = productCtrl.supermarketProductModel == null;
      });
    }
  }

  void _loadNextPage() {
    if (!mounted || !_scrollController.hasClients) return;
    final controller = context.read<ProductController>();
    final model = controller.supermarketProductModel;
    if (model == null ||
        controller.supermarketLoading ||
        controller.supermarketHasError ||
        (model.products?.length ?? 0) >= (model.totalSize ?? 0)) {
      return;
    }
    if (_scrollController.position.extentAfter < 500) {
      controller.getSupermarketProductList((model.offset ?? 1) + 1,
          latitude: controller.supermarketLatitude,
          longitude: controller.supermarketLongitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AllineThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: colors.background,
        body: Stack(
          children: [
            RefreshIndicator(
              color: Theme.of(context).colorScheme.primary,
              onRefresh: () => _loadData(forceReload: true),
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // 1. Header
                  const SliverToBoxAdapter(child: SmHeaderWidget()),

                  // 2. Search
                  const SliverToBoxAdapter(child: SmSearchBarWidget()),

                  // Categories come from the existing catalog taxonomy.
                  const SliverToBoxAdapter(child: SmCategoriesWidget()),

                  const SliverToBoxAdapter(child: _SectionDivider()),

                  // 5. Nearby Stores
                  const SliverToBoxAdapter(child: SmNearbyStoresWidget()),

                  const SliverToBoxAdapter(child: _SectionDivider()),

                  // 6. Offers
                  const SliverToBoxAdapter(child: SmOffersWidget()),

                  const SliverToBoxAdapter(child: _SectionDivider()),

                  const SliverToBoxAdapter(
                      child: AllineSectionHeader(
                    title: 'جميع المنتجات',
                    subtitle:
                        'تصفح منتجات السوبر ماركت وأضف احتياجاتك إلى السلة',
                  )),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  Consumer<ProductController>(
                      builder: (context, controller, _) {
                    final model = controller.supermarketProductModel;
                    final products = model?.products ?? [];
                    if (model == null) {
                      return SliverToBoxAdapter(
                          child: _hasError || controller.supermarketHasError
                              ? AllineErrorState(
                                  title: 'تعذر تحميل المنتجات',
                                  message:
                                      'تحقق من اتصالك بالإنترنت وحاول مرة أخرى.',
                                  onRetry: () => _loadData(forceReload: true))
                              : const SmProductListSkeleton());
                    }
                    if (products.isEmpty) {
                      return const SliverToBoxAdapter(
                          child: AllineEmptyState(
                        icon: Icons.shopping_basket_outlined,
                        title: 'لا توجد منتجات متاحة حاليًا',
                        message:
                            'جرّب تغيير موقع التوصيل أو أعد المحاولة لاحقًا.',
                      ));
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              MediaQuery.sizeOf(context).width < 340 ? 1 : 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          mainAxisExtent: 300 +
                              (MediaQuery.textScalerOf(context).scale(14) -
                                      14) *
                                  8,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => AllineProductCard(
                              grocery: true,
                              key: ValueKey(products[index].id),
                              product: products[index]),
                          childCount: products.length,
                        ),
                      ),
                    );
                  }),
                  SliverToBoxAdapter(child: Consumer<ProductController>(
                    builder: (context, controller, _) {
                      if (controller.supermarketProductModel == null) {
                        return const SizedBox.shrink();
                      }
                      if (controller.supermarketLoading) {
                        return const Padding(
                            padding: EdgeInsets.all(16),
                            child: SmProductListSkeleton());
                      }
                      if (controller.supermarketHasError) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(children: [
                            const Text('تعذر تحديث المنتجات. حاول مرة أخرى.'),
                            TextButton(
                                onPressed: () => _loadData(forceReload: true),
                                child: const Text('إعادة المحاولة')),
                          ]),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  )),

                  // Keep the last product above the contextual cart bar.
                  SliverToBoxAdapter(
                      child: SizedBox(
                          height: 120 + MediaQuery.paddingOf(context).bottom)),
                ],
              ),
            ),

            // Floating Cart Bar (shows only when cart has items)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FloatingCartBar(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Private helpers ─────────────────────────────────────────────────────────

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) => Container(
        height: AllineSpacing.xs,
        color: AllineThemeColors.of(context).background,
      );
}
