import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/alline_state_widget.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/floating_cart_bar.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/supermarket/widgets/sm_categories_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/supermarket/widgets/sm_essentials_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/supermarket/widgets/sm_header_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/supermarket/widgets/sm_nearby_stores_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/supermarket/widgets/sm_offers_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/supermarket/widgets/sm_popular_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/supermarket/widgets/sm_search_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:provider/provider.dart';

/// Alline Supermarket Hub — the dedicated grocery shopping experience.
///
/// Screen hierarchy (top → bottom):
///   1. [SmHeaderWidget]       — back, title, location, cart
///   2. [SmSearchBarWidget]    — "ابحث في السوبر ماركت"
///   3. [SmCategoriesWidget]   — horizontal icon category chips
///   4. [SmNearbyStoresWidget] — nearby supermarket store cards
///   5. [SmOffersWidget]       — discounted products
///   6. [SmPopularWidget]      — most demanded products
///   7. [SmEssentialsWidget]   — daily essentials 2-col grid
///   8. [FloatingCartBar]      — persistent bottom cart summary
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
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

    try {
      final productCtrl =
          Provider.of<ProductController>(Get.context!, listen: false);
      final catCtrl =
          Provider.of<CategoryController>(Get.context!, listen: false);

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
      ]);
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
      return;
    }

    if (mounted) setState(() {});
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
            if (_hasError)
              AllineErrorState(
                title: 'تعذّر تحميل المتاجر',
                message: 'تحقّق من اتصالك بالإنترنت وحاول مرة أخرى.',
                onRetry: () => _loadData(forceReload: true),
              )
            else
              CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // 1. Header
                  const SliverToBoxAdapter(child: SmHeaderWidget()),

                  // 2. Search
                  const SliverToBoxAdapter(child: SmSearchBarWidget()),

                  // Divider between white header zone and rest
                  const SliverToBoxAdapter(child: _SectionDivider()),

                  // 3. Categories
                  const SliverToBoxAdapter(child: SmCategoriesWidget()),

                  const SliverToBoxAdapter(child: _SectionDivider()),

                  // 4. Nearby Stores
                  const SliverToBoxAdapter(child: SmNearbyStoresWidget()),

                  const SliverToBoxAdapter(child: _SectionDivider()),

                  // 5. Offers
                  const SliverToBoxAdapter(child: SmOffersWidget()),

                  const SliverToBoxAdapter(child: _SectionDivider()),

                  // 6. Popular
                  const SliverToBoxAdapter(child: SmPopularWidget()),

                  const SliverToBoxAdapter(child: _SectionDivider()),

                  // 7. Daily Essentials (non-scrollable grid inside SliverToBoxAdapter)
                  const SliverToBoxAdapter(child: SmEssentialsWidget()),

                  // Bottom padding — room for FloatingCartBar
                  const SliverToBoxAdapter(child: SizedBox(height: 90)),
                ],
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

/// 8px visual gap + very subtle line between content sections.
class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) => Container(
        height: 8,
        color: AllineThemeColors.of(context).background,
      );
}
