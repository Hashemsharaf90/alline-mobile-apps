import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/controllers/global_shopping_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/domain/models/global_shopping_request_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/domain/models/global_shopping_store_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/domain/models/global_showcase_product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/screens/global_store_webview_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/screens/my_global_orders_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/widgets/global_product_preview_card.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/widgets/global_store_brand_tile.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/widgets/global_store_logo_widget.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class GlobalShoppingScreen extends StatefulWidget {
  const GlobalShoppingScreen({super.key});

  @override
  State<GlobalShoppingScreen> createState() => _GlobalShoppingScreenState();
}

class _GlobalShoppingScreenState extends State<GlobalShoppingScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();
  bool _showAllStores = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<GlobalShoppingController>(context, listen: false).fetchSupportedStores();
        Provider.of<GlobalShoppingController>(context, listen: false).getMyRequests();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showAddLinkBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _AddLinkBottomSheet(),
    );
  }

  void _showProductDetailSheet(BuildContext context, GlobalShowcaseProduct product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ProductDetailSheet(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildProductionScreen(context);
    /* Legacy screen retained temporarily for its reusable private widgets.
    final isLtr = context.watch<LocalizationController>().isLtr;
    final isDark = context.watch<ThemeController>().darkTheme;

    const primaryColor = Color(0xFF015FC9);
    const navyColor = Color(0xFF032C75);
    const accentColor = Color(0xFFEC970D);
    final bgColor = isDark ? Theme.of(context).scaffoldBackgroundColor : const Color(0xFFF4F8FE);
    final cardColor = isDark ? Theme.of(context).cardColor : Colors.white;
    final borderColor = isDark ? Theme.of(context).dividerColor : const Color(0xFFE1E8F2);

    final displayProducts = _filteredProducts;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : navyColor, size: 18),
            ),
          ),
        ),
        title: Text(
          isLtr ? 'Global Shopping' : 'التسوق العالمي',
          style: textBold.copyWith(color: navyColor, fontSize: Dimensions.fontSizeLarge),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyGlobalOrdersScreen())),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined, color: primaryColor, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      isLtr ? 'Orders' : 'طلباتي',
                      style: textBold.copyWith(color: primaryColor, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<GlobalShoppingController>(
        builder: (context, globalCtrl, _) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HERO BANNER
                      _buildHeroBanner(context, isLtr, primaryColor, navyColor, accentColor, cardColor, borderColor),
                      const SizedBox(height: 16),

                      // SEARCH & ADD LINK ACTION ROW
                      _buildSearchAndActionRow(context, isLtr, cardColor, borderColor, primaryColor, navyColor),
                      const SizedBox(height: 24),

                      // STORES SECTION
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isLtr ? 'Supported Global Stores' : 'المتاجر العالمية المدعومة',
                                style: textBold.copyWith(color: navyColor, fontSize: 16),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isLtr ? 'Browse and import any product directly' : 'تصفح واستورد أي منتج مباشرة بضغطة زر',
                                style: textRegular.copyWith(color: const Color(0xFF6D85AF), fontSize: 11.5),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      if (globalCtrl.isStoresLoading && globalCtrl.supportedStores.isEmpty)
                        const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                      else if (globalCtrl.hasStoresError || globalCtrl.supportedStores.isEmpty)
                        _buildEmptyStoresState(context, globalCtrl, isLtr, cardColor, borderColor)
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            mainAxisExtent: 128,
                          ),
                          itemCount: globalCtrl.supportedStores.take(4).length,
                          itemBuilder: (context, index) {
                            final store = globalCtrl.supportedStores[index];
                            return _buildStoreCard(context, store, isLtr, cardColor, borderColor, primaryColor);
                          },
                        ),

                      const SizedBox(height: 24),
                      Divider(color: borderColor, thickness: 1),
                      const SizedBox(height: 20),

                      // CURATED PRODUCTS SECTION HEADER
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      isLtr ? 'Curated Global Products' : 'منتجات عالمية مختارة',
                                      style: textBold.copyWith(color: navyColor, fontSize: 16),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF18A957).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: const Color(0xFF18A957).withValues(alpha: 0.3)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.verified, color: Color(0xFF18A957), size: 12),
                                          const SizedBox(width: 4),
                                          Text(
                                            isLtr ? 'Live Pricing' : 'أسعار حقيقية',
                                            style: textBold.copyWith(color: const Color(0xFF18A957), fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isLtr
                                      ? 'Top-rated picks from Amazon, SHEIN & AliExpress'
                                      : 'مختارات أصلية موثوقة جاهزة للطلب إلى باب منزلك',
                                  style: textRegular.copyWith(color: const Color(0xFF6D85AF), fontSize: 11.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // STORE FILTER PILLS
                      SizedBox(
                        height: 38,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _filters.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final filter = _filters[index];
                            final isActive = filter == _selectedFilter;

                            final count = filter == 'all'
                                ? GlobalShowcaseRepository.curatedProducts.length
                                : GlobalShowcaseRepository.curatedProducts
                                    .where((p) => p.store.toLowerCase() == filter.toLowerCase())
                                    .length;

                            final label = filter == 'all'
                                ? (isLtr ? 'All ($count)' : 'الكل ($count)')
                                : '$filter ($count)';

                            return InkWell(
                              onTap: () => setState(() => _selectedFilter = filter),
                              borderRadius: BorderRadius.circular(20),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isActive ? primaryColor : cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isActive ? primaryColor : borderColor,
                                    width: 1.5,
                                  ),
                                  boxShadow: isActive
                                      ? [
                                          BoxShadow(
                                            color: primaryColor.withValues(alpha: 0.28),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          )
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  label,
                                  style: textBold.copyWith(
                                    color: isActive ? Colors.white : const Color(0xFF4A5F7E),
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // PRODUCTS GRID
                      if (displayProducts.isNotEmpty)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 14,
                            mainAxisExtent: 340,
                          ),
                          itemCount: displayProducts.length,
                          itemBuilder: (context, index) {
                            final product = displayProducts[index];
                            return _buildProductCard(
                              context,
                              product,
                              isLtr,
                              cardColor,
                              borderColor,
                              primaryColor,
                              navyColor,
                              accentColor,
                            );
                          },
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.search_off_rounded, color: primaryColor, size: 36),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isLtr ? 'No products match your search' : 'لم نجد منتجات مطابقة لبحثك',
                                style: textBold.copyWith(color: navyColor, fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isLtr
                                    ? 'Try another search keyword, or paste the direct product link directly.'
                                    : 'جرب كلمة بحث أخرى، أو الصق رابط المنتج مباشرة وسنقوم باستيراده لك فوراً.',
                                textAlign: TextAlign.center,
                                style: textRegular.copyWith(color: const Color(0xFF6D85AF), fontSize: 13, height: 1.5),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                    _selectedFilter = 'all';
                                  });
                                },
                                icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 16),
                                label: Text(
                                  isLtr ? 'Reset Search' : 'إعادة ضبط البحث',
                                  style: textBold.copyWith(color: Colors.white, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 28),
                      Divider(color: borderColor, thickness: 1),
                      const SizedBox(height: 24),

                      // ORDERS TRACKING PREVIEW
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isLtr ? 'Your Global Orders' : 'طلباتك العالمية',
                                style: textBold.copyWith(color: navyColor, fontSize: 16),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isLtr ? 'Track status and approvals in real-time' : 'متابعة حالة التسعير والشحن أولاً بأول',
                                style: textRegular.copyWith(color: const Color(0xFF6D85AF), fontSize: 11.5),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyGlobalOrdersScreen())),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              child: Row(
                                children: [
                                  Text(
                                    isLtr ? 'View All' : 'عرض الكل',
                                    style: textBold.copyWith(color: primaryColor, fontSize: 13),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_forward_ios, color: primaryColor, size: 12),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      if (globalCtrl.isRequestsLoading && globalCtrl.requestsList.isEmpty)
                        const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                      else if (globalCtrl.requestsList.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderColor),
                            boxShadow: [BoxShadow(color: primaryColor.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.inbox_outlined, color: primaryColor, size: 26),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                isLtr ? 'No orders yet' : 'لا توجد طلبات عالمية حتى الآن',
                                style: textBold.copyWith(color: navyColor, fontSize: 15),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isLtr
                                    ? 'Start your first global order by browsing stores above or pasting any product link.'
                                    : 'ابدأ طلبك الأول بتصفح المتاجر أعلاه أو لصق رابط أي منتج عالمي تحبه.',
                                textAlign: TextAlign.center,
                                style: textRegular.copyWith(color: const Color(0xFF6D85AF), fontSize: 12.5, height: 1.5),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: globalCtrl.requestsList.length > 2 ? 2 : globalCtrl.requestsList.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final order = globalCtrl.requestsList[index];
                            return _buildOrderCard(context, order, isLtr, cardColor, borderColor, primaryColor);
                          },
                        ),

                      const SizedBox(height: 28),
                      Divider(color: borderColor, thickness: 1),
                      const SizedBox(height: 24),

                      // HOW IT WORKS - ELEVATED DESIGN
                      _buildHowItWorksCard(isLtr, cardColor, borderColor, primaryColor, navyColor),
                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
    */
  }

  Widget _buildProductionScreen(BuildContext context) {
    final isLtr = context.watch<LocalizationController>().isLtr;
    final colors = context.allineColors;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        title: Text(isLtr ? 'Global shopping' : 'التسوق العالمي'),
        leading: IconButton(
          tooltip: isLtr ? 'Back' : 'رجوع',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const BackButtonIcon(),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const MyGlobalOrdersScreen(),
            )),
            icon: const Icon(Icons.receipt_long_outlined, size: 18),
            label: Text(isLtr ? 'My orders' : 'طلباتي'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<GlobalShoppingController>(
        builder: (context, controller, _) {
          final query = _searchQuery.trim().toLowerCase();
          final stores = controller.supportedStores.where((store) {
            if (query.isEmpty) return true;
            return store.name.toLowerCase().contains(query) ||
                store.nameAr.toLowerCase().contains(query) ||
                store.domain.toLowerCase().contains(query);
          }).toList(growable: false);
          final visibleStores = _showAllStores ? stores : stores.take(6).toList();

          return CustomScrollView(
            controller: _scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: _buildCompactHero(context, isLtr, colors, primary),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: _buildProductionActions(context, isLtr, colors, primary),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 26, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: _buildSectionHeading(
                    context,
                    isLtr ? 'Supported stores' : 'المتاجر العالمية',
                    isLtr ? 'Choose a store to browse through Alline' : 'اختر متجراً لتصفحه عبر Alline',
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: _buildStoreSearch(context, isLtr, colors),
                ),
              ),
              if (controller.isStoresLoading && controller.supportedStores.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: _buildStoreLoading(context, colors),
                  ),
                )
              else if (controller.hasStoresError)
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: _buildStoreLoadError(context, isLtr, colors, controller),
                  ),
                )
              else if (stores.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: _buildNoStores(context, isLtr, colors, query.isNotEmpty),
                  ),
                )
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 188,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final store = visibleStores[index];
                        return GlobalStoreBrandTile(
                          store: store,
                          onTap: store.requestSupported && store.url.isNotEmpty
                              ? () => Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => GlobalStoreWebViewScreen(
                                      storeName: store.name,
                                      initialUrl: store.url,
                                    ),
                                  ))
                              : null,
                          isLtr: isLtr,
                        );
                      },
                      childCount: visibleStores.length,
                    ),
                  ),
                ),
                if (stores.length > 6 && query.isEmpty)
                  SliverToBoxAdapter(
                    child: Center(
                      child: TextButton.icon(
                        onPressed: () => setState(() => _showAllStores = !_showAllStores),
                        icon: Icon(_showAllStores ? Icons.expand_less : Icons.expand_more),
                        label: Text(_showAllStores ? 'عرض المتاجر الأقل' : 'عرض جميع المتاجر'),
                      ),
                    ),
                  ),
              ],
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSectionHeading(
                          context,
                          isLtr ? 'Your global orders' : 'طلباتك العالمية',
                          isLtr ? 'Follow your submitted product requests' : 'تابع طلبات المنتجات التي أرسلتها',
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const MyGlobalOrdersScreen(),
                        )),
                        child: Text(isLtr ? 'View all' : 'عرض الكل'),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: _buildOrdersPreview(context, controller, isLtr, colors, primary),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
                sliver: SliverToBoxAdapter(
                  child: _buildCompactHowItWorks(context, isLtr, colors, primary),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCompactHero(
    BuildContext context,
    bool isLtr,
    AllineThemeColors colors,
    Color primary,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLtr ? 'The world within reach' : 'العالم بين يديك',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isLtr
                      ? 'Shop your favorite global stores and submit product links through Alline.'
                      : 'تسوّق من متاجرك العالمية المفضلة، وأرسل روابط المنتجات عبر Alline.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: .09),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.public_rounded, color: primary, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildProductionActions(
    BuildContext context,
    bool isLtr,
    AllineThemeColors colors,
    Color primary,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () => _showAddLinkBottomSheet(context),
          icon: const Icon(Icons.add_link_rounded),
          label: Text(isLtr ? 'Add product link' : 'أضف رابط منتج'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () {
            if (!_scrollController.hasClients) return;
            final target = 400.0.clamp(
              0.0,
              _scrollController.position.maxScrollExtent,
            ).toDouble();
            _scrollController.animateTo(
              target,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          },
          icon: const Icon(Icons.storefront_outlined),
          label: Text(isLtr ? 'Browse stores' : 'تصفح المتاجر'),
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
        ),
        const SizedBox(height: 7),
        Text(
          isLtr ? 'Send a product link or choose a supported store.' : 'أرسل رابط المنتج أو اختر متجراً مدعوماً.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSectionHeading(BuildContext context, String title, String subtitle) {
    final theme = Theme.of(context);
    final colors = context.allineColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleLarge?.copyWith(color: colors.textPrimary)),
        const SizedBox(height: 2),
        Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: colors.textSecondary)),
      ],
    );
  }

  Widget _buildStoreSearch(BuildContext context, bool isLtr, AllineThemeColors colors) {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() {
        _searchQuery = value;
        _showAllStores = true;
      }),
      textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
      decoration: InputDecoration(
        hintText: isLtr ? 'Search global stores' : 'ابحث عن متجر عالمي',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _searchQuery.isEmpty
            ? null
            : IconButton(
                tooltip: isLtr ? 'Clear search' : 'مسح البحث',
                onPressed: () => setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _showAllStores = false;
                }),
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: colors.surface,
      ),
    );
  }

  Widget _buildStoreLoading(BuildContext context, AllineThemeColors colors) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 188,
      ),
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.border),
        ),
        alignment: Alignment.center,
        child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }

  Widget _buildStoreLoadError(
    BuildContext context,
    bool isLtr,
    AllineThemeColors colors,
    GlobalShoppingController controller,
  ) {
    return _messagePanel(
      context,
      colors,
      Icons.cloud_off_outlined,
      isLtr ? 'Stores could not be loaded' : 'تعذر تحميل المتاجر',
      isLtr ? 'Check your connection and try again.' : 'تحقق من اتصالك ثم حاول مرة أخرى.',
      action: TextButton.icon(
        onPressed: controller.fetchSupportedStores,
        icon: const Icon(Icons.refresh_rounded),
        label: Text(isLtr ? 'Try again' : 'إعادة المحاولة'),
      ),
    );
  }

  Widget _buildNoStores(BuildContext context, bool isLtr, AllineThemeColors colors, bool searched) {
    return _messagePanel(
      context,
      colors,
      Icons.storefront_outlined,
      searched
          ? (isLtr ? 'No matching stores' : 'لا توجد متاجر مطابقة')
          : (isLtr ? 'No stores are available yet' : 'لا توجد متاجر متاحة حالياً'),
      searched
          ? (isLtr ? 'Try another store name.' : 'جرّب البحث باسم متجر آخر.')
          : (isLtr ? 'Please check again later.' : 'يمكنك المحاولة مجدداً لاحقاً.'),
    );
  }

  Widget _messagePanel(
    BuildContext context,
    AllineThemeColors colors,
    IconData icon,
    String title,
    String subtitle, {
    Widget? action,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 30),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: theme.textTheme.titleMedium?.copyWith(color: colors.textPrimary)),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center, style: theme.textTheme.bodySmall?.copyWith(color: colors.textSecondary)),
          if (action != null) ...[const SizedBox(height: 8), action],
        ],
      ),
    );
  }

  Widget _buildOrdersPreview(
    BuildContext context,
    GlobalShoppingController controller,
    bool isLtr,
    AllineThemeColors colors,
    Color primary,
  ) {
    if (controller.isRequestsLoading && controller.requestsList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (controller.requestsList.isEmpty) {
      return _messagePanel(
        context,
        colors,
        Icons.shopping_bag_outlined,
        isLtr ? 'No global orders yet' : 'لم تبدأ طلبك العالمي بعد',
        isLtr
            ? 'Choose a store or send a product link to get started.'
            : 'اختر متجراً أو أرسل رابط منتج للبدء.',
        action: TextButton.icon(
          onPressed: () => _showAddLinkBottomSheet(context),
          icon: const Icon(Icons.add_link_rounded),
          label: Text(isLtr ? 'Start shopping' : 'ابدأ التسوق'),
        ),
      );
    }
    return Column(
      children: [
        for (final order in controller.requestsList.take(2)) ...[
          _buildOrderCard(context, order, isLtr, colors.surface, colors.border, primary),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildCompactHowItWorks(
    BuildContext context,
    bool isLtr,
    AllineThemeColors colors,
    Color primary,
  ) {
    final theme = Theme.of(context);
    final steps = isLtr
        ? ['Choose a store or share a product link', 'Review the quote and delivery details', 'Follow your order in My orders']
        : ['اختر متجراً أو أرسل رابط المنتج', 'راجع السعر وتفاصيل التوصيل', 'تابع طلبك من صفحة طلباتي'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isLtr ? 'How it works' : 'كيف يعمل التسوق العالمي؟',
              style: theme.textTheme.titleMedium?.copyWith(color: colors.textPrimary)),
          const SizedBox(height: 12),
          for (var i = 0; i < steps.length; i++) ...[
            if (i > 0) const SizedBox(height: 9),
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: primary.withValues(alpha: .1), shape: BoxShape.circle),
                  child: Text('${i + 1}', style: theme.textTheme.labelMedium?.copyWith(color: primary, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(steps[i], style: theme.textTheme.bodyMedium?.copyWith(color: colors.textPrimary))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeroBanner(
    BuildContext context,
    bool isLtr,
    Color primaryColor,
    Color navyColor,
    Color accentColor,
    Color cardColor,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            cardColor,
            cardColor,
            primaryColor.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.public, color: primaryColor, size: 13),
                          const SizedBox(width: 5),
                          Text(
                            isLtr ? 'Global Shopping via Alline' : 'تسوق عالمي مباشر مع Alline',
                            style: textBold.copyWith(color: primaryColor, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isLtr ? 'Shop the World\nfrom Your Home' : 'العالم بين يديك\nبأفضل الأسعار والشحن',
                      style: textBold.copyWith(color: navyColor, fontSize: 19, height: 1.35),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isLtr
                          ? 'Browse top stores (Amazon, SHEIN, AliExpress) or paste any product link for instant ordering.'
                          : 'تصفح كبرى المتاجر العالمية أو الصق رابط أي منتج، وسنتكفل بشرائه وشحنه إلى باب بيتك في اليمن.',
                      style: textRegular.copyWith(color: const Color(0xFF6D85AF), fontSize: 12.5, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 95,
                height: 105,
                child: CustomPaint(
                  painter: _HeroIllustrationPainter(primaryColor, navyColor, accentColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // TRUST PILLS
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTrustBadge(Icons.verified_user_outlined, isLtr ? 'Guaranteed Shipping' : 'شحن موثوق ومضمون', const Color(0xFF18A957)),
              _buildTrustBadge(Icons.price_check_outlined, isLtr ? 'Transparent Costs' : 'أسعار شفافة بدون مفاجآت', primaryColor),
              _buildTrustBadge(Icons.account_balance_wallet_outlined, isLtr ? 'Local Yemen Pay' : 'دفع محلي بالريال', accentColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadge(IconData icon, String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            title,
            style: textBold.copyWith(color: color, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndActionRow(
    BuildContext context,
    bool isLtr,
    Color cardColor,
    Color borderColor,
    Color primaryColor,
    Color navyColor,
  ) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: textMedium.copyWith(color: navyColor, fontSize: 13.5),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: InputBorder.none,
                hintText: isLtr ? 'Search products, brands, or stores...' : 'ابحث في المنتجات، الماركات، أو المتاجر...',
                hintStyle: textRegular.copyWith(color: const Color(0xFF8B9FB8), fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6D85AF), size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF6D85AF)),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: () => _showAddLinkBottomSheet(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, const Color(0xFF034EA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_link_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 6),
                Text(
                  isLtr ? 'Add Link' : 'أضف رابط',
                  style: textBold.copyWith(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoreCard(
    BuildContext context,
    GlobalShoppingStoreModel store,
    bool isLtr,
    Color cardColor,
    Color borderColor,
    Color primaryColor,
  ) {
    return InkWell(
      onTap: store.requestSupported && store.url.isNotEmpty
          ? () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GlobalStoreWebViewScreen(
                    storeName: store.name,
                    initialUrl: store.url,
                  ),
                ),
              )
          : null,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: GlobalStoreLogoWidget(
                  store: store,
                  height: 46,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLtr ? 'Browse Store' : 'تصفّح واطلب',
                    style: textBold.copyWith(color: primaryColor, fontSize: 11),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, color: primaryColor, size: 9),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    GlobalShowcaseProduct product,
    bool isLtr,
    Color cardColor,
    Color borderColor,
    Color primaryColor,
    Color navyColor,
    Color accentColor,
  ) {
    return InkWell(
      onTap: () => _showProductDetailSheet(context, product),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE CONTAINER WITH STORE & BADGE OVERLAYS
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.15,
                  child: Container(
                    color: const Color(0xFFF9FBFE),
                    child: CustomImageWidget(
                      image: product.imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // Store logo badge
                PositionedDirectional(
                  top: 8,
                  end: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: GlobalStoreLogoWidget(
                      storeName: product.store,
                      height: 14,
                      width: 40,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // Discount or custom badge
                if (product.badge != null)
                  PositionedDirectional(
                    top: 8,
                    start: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (product.badgeColor ?? accentColor),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: (product.badgeColor ?? accentColor).withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        product.badge!,
                        style: textBold.copyWith(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                // Discount tag if original price present
                if (product.discountPercent != null)
                  PositionedDirectional(
                    bottom: 6,
                    start: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9363E),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '-${product.discountPercent}%',
                        style: textBold.copyWith(color: Colors.white, fontSize: 9.5),
                      ),
                    ),
                  ),
              ],
            ),

            // CONTENT
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating row
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 14),
                        const SizedBox(width: 3),
                        Text(
                          '${product.rating}',
                          style: textBold.copyWith(color: navyColor, fontSize: 11),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${product.reviewsCount > 999 ? '${(product.reviewsCount / 1000).toStringAsFixed(1)}k' : product.reviewsCount})',
                          style: textRegular.copyWith(color: const Color(0xFF8B9FB8), fontSize: 10),
                        ),
                        const Spacer(),
                        Text(
                          product.category,
                          style: textMedium.copyWith(color: const Color(0xFF6D85AF), fontSize: 10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    // Product title
                    Expanded(
                      child: Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textBold.copyWith(color: navyColor, fontSize: 12, height: 1.35),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Dual pricing row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '\$${product.priceUsd.toStringAsFixed(2)}',
                          style: textBold.copyWith(color: navyColor, fontSize: 15),
                        ),
                        if (product.originalPriceUsd != null) ...[
                          const SizedBox(width: 5),
                          Text(
                            '\$${product.originalPriceUsd!.toStringAsFixed(2)}',
                            style: textRegular.copyWith(
                              color: const Color(0xFF8B9FB8),
                              fontSize: 10.5,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '≈ ${product.approxYerPrice} ر.ي',
                      style: textBold.copyWith(color: const Color(0xFF18A957), fontSize: 10.5),
                    ),
                    const SizedBox(height: 8),

                    // Active Action button
                    Container(
                      width: double.infinity,
                      height: 32,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.08),
                        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_shopping_cart_rounded, color: primaryColor, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            isLtr ? 'Add to Cart' : 'أضف للسلة',
                            style: textBold.copyWith(color: primaryColor, fontSize: 11.5),
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

  Widget _buildOrderCard(
    BuildContext context,
    GlobalShoppingRequestModel order,
    bool isLtr,
    Color cardColor,
    Color borderColor,
    Color primaryColor,
  ) {
    final semantic = context.allineColors;
    Color statusColor = primaryColor;
    Color statusBg = primaryColor.withValues(alpha: 0.1);

    if (order.status == 'processing') {
      statusColor = primaryColor;
      statusBg = primaryColor.withValues(alpha: 0.1);
    } else if (order.status == 'approved' || order.status == 'paid') {
      statusColor = semantic.warning;
      statusBg = semantic.warning.withValues(alpha: 0.12);
    } else if (order.status == 'completed' || order.status == 'delivered') {
      statusColor = semantic.success;
      statusBg = semantic.success.withValues(alpha: 0.12);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#REQ-${order.id}',
                style: textBold.copyWith(color: semantic.textPrimary, fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
                child: Text(
                  isLtr ? (order.status ?? 'pending') : _translateStatus(order.status ?? 'pending'),
                  style: textBold.copyWith(color: statusColor, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: semantic.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                alignment: Alignment.center,
                child: GlobalStoreLogoWidget(
                  storeName: order.storeName,
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLtr ? 'Global Shopping Request' : 'طلب منتج عالمي',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textBold.copyWith(color: semantic.textPrimary, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${order.storeName ?? 'Store'} · ${order.approvedPrice != null ? '${order.approvedPrice} ${order.quotedCurrency ?? ''}' : (isLtr ? 'Pricing Pending' : 'في انتظار التسعير')}',
                      style: textRegular.copyWith(color: semantic.textSecondary, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyGlobalOrdersScreen())),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: semantic.surfaceElevated,
                border: Border.all(color: borderColor, width: 1.2),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on_outlined, color: primaryColor, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    isLtr ? 'Track Request & Details' : 'متابعة الطلب وتفاصيل الشحن',
                    style: textBold.copyWith(color: primaryColor, fontSize: 12.5),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHowItWorksCard(
    bool isLtr,
    Color cardColor,
    Color borderColor,
    Color primaryColor,
    Color navyColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.help_outline_rounded, color: primaryColor, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                isLtr ? 'How Global Shopping Works?' : 'كيف تتسوق عالمياً عبر Alline؟',
                style: textBold.copyWith(color: navyColor, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildHowStep(
            '١',
            Icons.storefront_rounded,
            isLtr ? 'Browse or add any link' : 'اختر متجراً أو الصق رابطاً',
            isLtr
                ? 'Choose from Amazon, SHEIN or AliExpress above, or paste the link of any product you want.'
                : 'تصفح المتاجر المدعومة مباشرة، أو انسخ رابط أي منتج والصقه في خانة الرابط.',
            primaryColor,
            navyColor,
          ),
          const SizedBox(height: 14),
          _buildHowStep(
            '٢',
            Icons.receipt_long_rounded,
            isLtr ? 'Instant quote & cart review' : 'مراجعة السعر والإضافة للسلة',
            isLtr
                ? 'Review product details, shipping cost and local payment options before finalizing.'
                : 'نراجع لك السعر وتكلفة الشحن ونضيف المنتج لسلة Alline لتأكيد طلبك بسهولة.',
            primaryColor,
            navyColor,
          ),
          const SizedBox(height: 14),
          _buildHowStep(
            '٣',
            Icons.local_shipping_rounded,
            isLtr ? 'Doorstep delivery in Yemen' : 'استلم طلبك حتى باب منزلك',
            isLtr
                ? 'Follow your package journey step-by-step with real-time tracking until safe delivery.'
                : 'تتبع خط سير شحنتك لحظة بلحظة حتى وصولها واستلامها في مدينتك بأمان تام.',
            primaryColor,
            navyColor,
          ),
        ],
      ),
    );
  }

  Widget _buildHowStep(
    String num,
    IconData icon,
    String title,
    String subtitle,
    Color primaryColor,
    Color navyColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            num,
            style: textBold.copyWith(color: primaryColor, fontSize: 13),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textBold.copyWith(color: navyColor, fontSize: 13.5)),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: textRegular.copyWith(color: const Color(0xFF6D85AF), fontSize: 12, height: 1.45),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStoresState(
    BuildContext context,
    GlobalShoppingController ctrl,
    bool isLtr,
    Color cardColor,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 32),
          const SizedBox(height: 12),
          Text(
            isLtr ? 'Could not load stores' : 'تعذّر تحميل المتاجر',
            style: textBold.copyWith(color: const Color(0xFF071B49), fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ctrl.fetchSupportedStores(),
            child: Text(isLtr ? 'Retry' : 'إعادة المحاولة', style: textBold),
          )
        ],
      ),
    );
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'pending':
        return 'قيد المراجعة';
      case 'processing':
        return 'جاري المعالجة';
      case 'approved':
        return 'تم التسعير';
      case 'paid':
        return 'تم الدفع';
      case 'shipped':
        return 'قيد الشحن';
      case 'delivered':
        return 'تم التسليم';
      case 'rejected':
        return 'مرفوض';
      case 'canceled':
        return 'ملغي';
      default:
        return status;
    }
  }
}

// ---------------------------------------------------------------------------
// ADD LINK BOTTOM SHEET (PREVIEW & SUBMIT)
// ---------------------------------------------------------------------------
class _AddLinkBottomSheet extends StatefulWidget {
  const _AddLinkBottomSheet();

  @override
  State<_AddLinkBottomSheet> createState() => _AddLinkBottomSheetState();
}

class _AddLinkBottomSheetState extends State<_AddLinkBottomSheet> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLtr = context.watch<LocalizationController>().isLtr;
    final semantic = context.allineColors;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardColor = semantic.surface;
    final bgColor = semantic.background;
    final borderColor = semantic.border;

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: Consumer<GlobalShoppingController>(
          builder: (context, globalCtrl, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: borderColor, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.link_rounded, color: primaryColor, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isLtr ? 'Add Product Link' : 'أضف رابط المنتج',
                      style: textBold.copyWith(color: semantic.textPrimary, fontSize: 17),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: primaryColor, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isLtr
                              ? 'Enter a product link to preview the details available for your request.'
                              : 'أدخل رابط المنتج لمعاينة التفاصيل المتاحة قبل إرسال طلبك.',
                          style: textRegular.copyWith(color: semantic.textSecondary, fontSize: 12, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _urlController,
                        keyboardType: TextInputType.url,
                        textDirection: TextDirection.ltr,
                        autocorrect: false,
                        style: textRegular.copyWith(fontSize: 13.5),
                        decoration: InputDecoration(
                          hintText: 'https://www.amazon.com/dp/...',
                          hintStyle: textRegular.copyWith(color: Theme.of(context).hintColor),
                          filled: true,
                          fillColor: bgColor,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: borderColor, width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: borderColor, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: primaryColor, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () async {
                        final data = await Clipboard.getData(Clipboard.kTextPlain);
                        if (data != null && data.text != null) {
                          _urlController.text = data.text!;
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: primaryColor, width: 1.5),
                        ),
                        child: Text(
                          isLtr ? 'Paste' : 'لصق',
                          style: textBold.copyWith(color: primaryColor, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (globalCtrl.productPreview != null) ...[
                  GlobalProductPreviewCard(
                    preview: globalCtrl.productPreview!,
                    onSubmit: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const MyGlobalOrdersScreen(),
                      ));
                    },
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        globalCtrl.clearPreview();
                        _urlController.clear();
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: Text(
                        isLtr ? 'Check another link' : 'فحص رابط آخر',
                        style: textBold.copyWith(fontSize: 12),
                      ),
                    ),
                  ),
                ] else ...[
                  if (globalCtrl.previewErrorMessage != null && _urlController.text.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              globalCtrl.previewErrorMessage!,
                              style: textMedium.copyWith(color: Theme.of(context).colorScheme.error, fontSize: 12.5),
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: globalCtrl.isPreviewLoading
                          ? null
                          : () async {
                              if (_urlController.text.trim().isEmpty) {
                                showCustomSnackBarWidget(
                                  isLtr ? 'Please enter a valid link' : 'يرجى إدخال رابط صحيح',
                                  context,
                                  snackBarType: SnackBarType.warning,
                                );
                                return;
                              }
                              await globalCtrl.previewProduct(_urlController.text, context);
                            },
                      icon: globalCtrl.isPreviewLoading
                          ? const SizedBox.shrink()
                          : const Icon(Icons.search_rounded, color: Colors.white, size: 20),
                      label: globalCtrl.isPreviewLoading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                          : Text(
                              isLtr ? 'Preview & Add to Cart 🛒' : 'فحص وعرض المنتج 🛒',
                              style: textBold.copyWith(color: Colors.white, fontSize: 15),
                            ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// INTERACTIVE SHOWCASE PRODUCT DETAIL SHEET
// ---------------------------------------------------------------------------
class _ProductDetailSheet extends StatefulWidget {
  final GlobalShowcaseProduct product;
  const _ProductDetailSheet({required this.product});

  @override
  State<_ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<_ProductDetailSheet> {
  int _quantity = 1;
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleAddToCart(BuildContext context) async {
    final nav = Navigator.of(context);
    final isLtr = Provider.of<LocalizationController>(context, listen: false).isLtr;
    final globalCtrl = Provider.of<GlobalShoppingController>(context, listen: false);

    setState(() => _isSubmitting = true);

    final success = await globalCtrl.submitRequest(
      productUrl: widget.product.productUrl,
      storeName: widget.product.store,
      quantity: _quantity,
      customerNotes: _notesController.text.trim().isNotEmpty
          ? '${widget.product.name} | ${_notesController.text.trim()}'
          : widget.product.name,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    nav.pop(); // close sheet

    if (success) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF18A957), size: 26),
              const SizedBox(width: 8),
              Text(isLtr ? 'Added to Cart' : 'تمت الإضافة بنجاح', style: textBold.copyWith(fontSize: 16)),
            ],
          ),
          content: Text(
            isLtr
                ? 'Your request for "${widget.product.name}" has been recorded. Our team will verify live availability and shipping.'
                : 'تم تسجيل طلب "${widget.product.name}" بنجاح! سيتم التحقق من توفر المنتج وتأكيد تفاصيل الشحن والتكلفة في طلباتك.',
            style: textRegular.copyWith(fontSize: 13, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isLtr ? 'Continue Shopping' : 'متابعة التسوق', style: textMedium),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF015FC9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                nav.push(MaterialPageRoute(builder: (_) => const MyGlobalOrdersScreen()));
              },
              child: Text(isLtr ? 'View My Orders' : 'عرض طلباتي', style: textBold.copyWith(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      if (!context.mounted) return;
      showCustomSnackBarWidget(
        isLtr ? 'Could not submit request. Please try again.' : 'تعذر إرسال الطلب، يرجى المحاولة مرة أخرى.',
        context,
        snackBarType: SnackBarType.error,
      );
    }
  }

  void _openStoreWebView(BuildContext context) {
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GlobalStoreWebViewScreen(
          storeName: widget.product.store,
          initialUrl: widget.product.productUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLtr = context.watch<LocalizationController>().isLtr;
    final isDark = context.watch<ThemeController>().darkTheme;
    final cardColor = isDark ? Theme.of(context).cardColor : Colors.white;
    const primaryColor = Color(0xFF015FC9);
    const navyColor = Color(0xFF032C75);
    final borderColor = isDark ? Theme.of(context).dividerColor : const Color(0xFFE1E8F2);

    final product = widget.product;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // HEADER IMAGE WITH CLOSE BUTTON
          Stack(
            children: [
              Container(
                height: 220,
                width: double.infinity,
                color: const Color(0xFFF8FAFD),
                padding: const EdgeInsets.all(16),
                child: CustomImageWidget(
                  image: product.imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
              // Close button
              PositionedDirectional(
                top: 14,
                end: 14,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.black87, size: 20),
                  ),
                ),
              ),
              // Store badge
              PositionedDirectional(
                bottom: 12,
                start: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: GlobalStoreLogoWidget(
                    storeName: product.store,
                    height: 18,
                    width: 48,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),

          // SCROLLABLE DETAILS
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CATEGORY & RATING
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.category,
                          style: textBold.copyWith(color: primaryColor, fontSize: 11),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 16),
                      const SizedBox(width: 3),
                      Text(
                        '${product.rating}',
                        style: textBold.copyWith(color: navyColor, fontSize: 13),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.reviewsCount} ${isLtr ? 'reviews' : 'تقييم'})',
                        style: textRegular.copyWith(color: const Color(0xFF6D85AF), fontSize: 11.5),
                      ),
                      const Spacer(),
                      if (product.badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEC970D).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.badge!,
                            style: textBold.copyWith(color: const Color(0xFFEC970D), fontSize: 11),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // TITLE
                  Text(
                    product.name,
                    style: textBold.copyWith(color: navyColor, fontSize: 16, height: 1.45),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.nameEn,
                    style: textRegular.copyWith(color: const Color(0xFF8B9FB8), fontSize: 12),
                  ),
                  const SizedBox(height: 14),

                  // DUAL PRICE CARD
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F8FE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isLtr ? 'Store Price (USD)' : 'سعر المنتج الأصلي',
                              style: textRegular.copyWith(color: const Color(0xFF6D85AF), fontSize: 11.5),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '\$${product.priceUsd.toStringAsFixed(2)}',
                                  style: textBold.copyWith(color: navyColor, fontSize: 22),
                                ),
                                if (product.originalPriceUsd != null) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    '\$${product.originalPriceUsd!.toStringAsFixed(2)}',
                                    style: textRegular.copyWith(
                                      color: const Color(0xFF8B9FB8),
                                      fontSize: 13,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF18A957).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF18A957).withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                isLtr ? 'Approx. in YER' : 'القيمة التقريبية بالريال',
                                style: textRegular.copyWith(color: const Color(0xFF18A957), fontSize: 10),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${product.approxYerPrice} ر.ي',
                                style: textBold.copyWith(color: const Color(0xFF18A957), fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // DESCRIPTION
                  Text(
                    isLtr ? 'Product Overview' : 'نبذة عن المنتج',
                    style: textBold.copyWith(color: navyColor, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.description,
                    style: textRegular.copyWith(color: const Color(0xFF4A5F7E), fontSize: 13, height: 1.55),
                  ),
                  const SizedBox(height: 12),

                  // KEY HIGHLIGHTS / SPECS
                  if (product.features.isNotEmpty) ...[
                    ...product.features.map(
                      (feat) => Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF18A957), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                feat,
                                style: textRegular.copyWith(color: navyColor, fontSize: 12.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  Divider(color: borderColor),
                  const SizedBox(height: 12),

                  // QUANTITY SELECTOR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isLtr ? 'Quantity' : 'الكمية المطلوبة',
                        style: textBold.copyWith(color: navyColor, fontSize: 13.5),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: _quantity > 1 ? () => setState(() => _quantity--) : null,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: Text('−', style: TextStyle(color: primaryColor, fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.symmetric(vertical: BorderSide(color: borderColor)),
                              ),
                              child: Text('$_quantity', style: textBold.copyWith(color: navyColor, fontSize: 14)),
                            ),
                            InkWell(
                              onTap: () => setState(() => _quantity++),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: Text('+', style: TextStyle(color: primaryColor, fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // CUSTOMER NOTES FIELD
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    style: textRegular.copyWith(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: isLtr
                          ? 'Add optional notes (e.g. Size, Color, Version)...'
                          : 'ملاحظات اختيارية (مثال: المقاس، اللون المطلوب، أو المواصفات)...',
                      hintStyle: textRegular.copyWith(color: Theme.of(context).hintColor, fontSize: 12),
                      filled: true,
                      fillColor: const Color(0xFFF9FBFE),
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // VIEW IN ORIGINAL STORE BUTTON (ACTIVE & WORKING)
                  InkWell(
                    onTap: () => _openStoreWebView(context),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: primaryColor, width: 1.5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.open_in_browser_rounded, color: primaryColor, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            isLtr ? 'Browse in Original Store ↗' : 'معاينة وتصفح بالمتجر الأصلي ↗',
                            style: textBold.copyWith(color: primaryColor, fontSize: 13.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // PRIMARY ADD TO ALLINE CART BUTTON (FULLY ACTIVE)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: _isSubmitting ? null : () => _handleAddToCart(context),
                      icon: _isSubmitting
                          ? const SizedBox.shrink()
                          : const Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 20),
                      label: _isSubmitting
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                          : Text(
                              isLtr ? 'Add to Alline Cart 🛒' : 'أضف إلى سلة Alline 🛒',
                              style: textBold.copyWith(color: Colors.white, fontSize: 15),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HERO ILLUSTRATION PAINTER
// ---------------------------------------------------------------------------
class _HeroIllustrationPainter extends CustomPainter {
  final Color primaryColor;
  final Color navyColor;
  final Color accentColor;

  _HeroIllustrationPainter(this.primaryColor, this.navyColor, this.accentColor);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2.2);
    final globeRadius = size.width * 0.38;

    final globePaint = Paint()
      ..color = const Color(0xFFEEF4FD)
      ..style = PaintingStyle.fill;

    final globeBorderPaint = Paint()
      ..color = const Color(0xFFC5D6F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw globe base
    canvas.drawCircle(center, globeRadius, globePaint);

    // Draw globe longitude
    final ovalRect = Rect.fromCenter(center: center, width: globeRadius * 1.1, height: globeRadius * 2);
    canvas.drawOval(ovalRect, globeBorderPaint);

    // Draw equator
    canvas.drawLine(
      Offset(center.dx - globeRadius, center.dy),
      Offset(center.dx + globeRadius, center.dy),
      globeBorderPaint,
    );

    // Draw package on globe
    final packageRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy - 10),
      width: 32,
      height: 26,
    );
    final packagePaint = Paint()..color = navyColor;
    canvas.drawRRect(RRect.fromRectAndRadius(packageRect, const Radius.circular(5)), packagePaint);

    final packageTopPaint = Paint()..color = primaryColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(packageRect.left, packageRect.top, packageRect.width, 10),
        const Radius.circular(5),
      ),
      packageTopPaint,
    );

    // Draw shipping arc
    final arcPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(center.dx - globeRadius - 10, center.dy + globeRadius + 5)
      ..quadraticBezierTo(
        center.dx,
        center.dy + 10,
        center.dx + globeRadius + 10,
        center.dy + globeRadius + 5,
      );

    canvas.drawPath(path, arcPaint);
    canvas.drawCircle(Offset(center.dx + globeRadius + 10, center.dy + globeRadius + 5), 4, Paint()..color = accentColor);
  }

  @override
  bool shouldRepaint(covariant _HeroIllustrationPainter oldDelegate) =>
      primaryColor != oldDelegate.primaryColor ||
      navyColor != oldDelegate.navyColor ||
      accentColor != oldDelegate.accentColor;
}
