import 'package:flutter/material.dart';

import 'package:flutter_sixvalley_ecommerce/features/global_shopping/controllers/global_shopping_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/domain/models/global_shopping_store_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/domain/models/global_showcase_product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/screens/global_store_webview_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/screens/my_global_orders_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/widgets/add_link_bottom_sheet.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/widgets/global_curated_products_section.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/widgets/global_hero_banner_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/widgets/global_how_it_works_accordion.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/widgets/global_product_details_modal.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/widgets/global_search_and_link_bar.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/widgets/global_shopping_states.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/widgets/global_stores_grid.dart';
import 'package:provider/provider.dart';

class GlobalShoppingScreen extends StatefulWidget {
  const GlobalShoppingScreen({super.key});

  @override
  State<GlobalShoppingScreen> createState() => _GlobalShoppingScreenState();
}

class _GlobalShoppingScreenState extends State<GlobalShoppingScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final ctrl =
            Provider.of<GlobalShoppingController>(context, listen: false);
        ctrl.fetchSupportedStores();
        ctrl.getMyRequests();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<GlobalShowcaseProduct> get _filteredProducts {
    return GlobalShowcaseRepository.curatedProducts.where((product) {
      final matchesFilter = _selectedFilter == 'all' ||
          _selectedFilter == 'الكل' ||
          product.store.toLowerCase() == _selectedFilter.toLowerCase();
      if (!matchesFilter) return false;

      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.trim().toLowerCase();
      return product.name.toLowerCase().contains(q) ||
          product.nameEn.toLowerCase().contains(q) ||
          product.category.toLowerCase().contains(q) ||
          product.store.toLowerCase().contains(q);
    }).toList();
  }

  void _showAddLinkBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddLinkBottomSheet(
        onProductResolved: (product) {
          _openProductDetails(product);
        },
      ),
    );
  }

  void _openProductDetails(GlobalShowcaseProduct product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GlobalProductDetailsModal(product: product),
      ),
    );
  }

  void _openStore(GlobalShoppingStoreModel store) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GlobalStoreWebViewScreen(
          storeName: store.name,
          initialUrl: store.url,
        ),
      ),
    );
  }

  void _scrollToStores() {
    _scrollController.animateTo(
      220,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF015FC9);
    const navyColor = Color(0xFF071B49);
    const borderColor = Color(0xFFE1E8F2);
    const canvasBg = Color(0xFFF4F8FE);

    return Scaffold(
      backgroundColor: canvasBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: canvasBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: navyColor,
                size: 18,
              ),
            ),
          ),
        ),
        title: const Text(
          'التسوق العالمي',
          style: TextStyle(
            fontFamily: 'AllineTajawal',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: navyColor,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const MyGlobalOrdersScreen()),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: primaryBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryBlue.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        color: primaryBlue, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'طلباتي',
                      style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: primaryBlue,
                      ),
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
          // 1. Loading Skeleton State
          if (globalCtrl.isStoresLoading &&
              globalCtrl.supportedStores.isEmpty) {
            return const SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: GlobalShoppingSkeletonWidget(),
            );
          }

          // 2. Error State
          if (globalCtrl.hasStoresError && globalCtrl.supportedStores.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: GlobalShoppingErrorWidget(
                  onRetry: () => globalCtrl.fetchSupportedStores(),
                ),
              ),
            );
          }

          final products = _filteredProducts;

          // 3. Normal Active State (Full Long Scroll)
          return RefreshIndicator(
            color: primaryBlue,
            onRefresh: () async {
              await globalCtrl.fetchSupportedStores();
              await globalCtrl.getMyRequests();
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // A. Compact Hero Section (Registered Hero Banner Image)
                  GlobalHeroBannerWidget(
                    onTap: _showAddLinkBottomSheet,
                  ),
                  const SizedBox(height: 14),

                  // B. Search & Add Link Action Row
                  GlobalSearchAndLinkBar(
                    searchController: _searchController,
                    onSearchChanged: (val) =>
                        setState(() => _searchQuery = val),
                    onAddLinkTap: _showAddLinkBottomSheet,
                    onClearSearch: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  ),
                  const SizedBox(height: 20),

                  // C. Official 4 Global Stores (2x2 Grid)
                  GlobalStoresGrid(
                    stores: globalCtrl.supportedStores,
                    onStoreTap: _openStore,
                  ),
                  const SizedBox(height: 18),

                  // D. How It Works Accordion (Expandable 3 Progressive Steps)
                  const GlobalHowItWorksAccordion(),
                  const SizedBox(height: 18),

                  // E. Curated Global Products Section or Empty Search Result
                  if (products.isNotEmpty)
                    GlobalCuratedProductsSection(
                      products: products,
                      selectedFilter: _selectedFilter,
                      onFilterChanged: (filter) =>
                          setState(() => _selectedFilter = filter),
                      onProductTap: _openProductDetails,
                    )
                  else
                    GlobalShoppingEmptyWidget(
                      onAddLinkTap: _showAddLinkBottomSheet,
                      onBrowseStoresTap: _scrollToStores,
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
