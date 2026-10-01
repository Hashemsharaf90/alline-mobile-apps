import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/product_controller.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/filter_model.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/features/product/widgets/seller_product_management_card.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/localization/controllers/localization_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

class ProductViewWidget extends StatefulWidget {
  final int? sellerId;
  final bool fromNotification;
  final TextEditingController searchController;

  const ProductViewWidget({
    super.key,
    required this.sellerId,
    this.fromNotification = false,
    required this.searchController,
  });

  @override
  State<ProductViewWidget> createState() => _ProductViewWidgetState();
}

class _ProductViewWidgetState extends State<ProductViewWidget> {
  late final ScrollController _scrollController;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFirstPage());
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  String _languageCode(BuildContext context) {
    final code = Provider.of<LocalizationController>(context, listen: false)
        .locale
        .languageCode;
    return code == 'en' ? 'en' : code;
  }

  Future<void> _loadFirstPage() async {
    if (!mounted) return;
    final profile = Provider.of<ProfileController>(context, listen: false);
    final productController = Provider.of<ProductController>(context, listen: false);
    final sellerId = profile.userId?.toString() ?? widget.sellerId?.toString();
    if (sellerId == null) return;

    if (widget.fromNotification) {
      final response = await profile.getSellerInfo();
      if (!mounted) return;
      if (!response.isSuccess) {
        // Continue with the authenticated seller ID already available locally.
      }
    }

    await productController.getSellerProductList(
      sellerId,
      1,
      _languageCode(context),
      widget.searchController.text.trim(),
      filterSearchModel: productController.filterModel.copyWith(reload: true),
    );
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 360) {
      _loadNextPage();
    }
  }

  Future<void> _loadNextPage() async {
    if (_loadingMore || !mounted) return;
    final controller = Provider.of<ProductController>(context, listen: false);
    final model = controller.sellerProductModel;
    final products = model?.products ?? <Product>[];
    final totalSize = model?.totalSize ?? 0;
    if (model == null || products.isEmpty || products.length >= totalSize) return;

    final sellerId = Provider.of<ProfileController>(context, listen: false)
            .userId
            ?.toString() ??
        widget.sellerId?.toString();
    if (sellerId == null) return;

    setState(() => _loadingMore = true);
    try {
      await controller.getSellerProductList(
        sellerId,
        (model.offset ?? 1) + 1,
        _languageCode(context),
        widget.searchController.text.trim(),
        filterSearchModel: controller.filterModel.copyWith(reload: false),
      );
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _refresh() async => _loadFirstPage();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, controller, _) {
        final model = controller.sellerProductModel;
        final products = model?.products ?? const <Product>[];

        if (model == null && controller.sellerProductsError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off_outlined,
                      size: 42, color: ColorResources.getTextSubTitle(context)),
                  const SizedBox(height: 12),
                  Text(
                    'تعذر تحميل المنتجات',
                    style: TextStyle(
                      color: ColorResources.getTextTitle(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'AllineTajawal',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'حدث خطأ أثناء تحميل منتجات متجرك.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ColorResources.getTextSubTitle(context),
                      fontSize: 13,
                      fontFamily: 'AllineTajawal',
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _loadFirstPage,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          );
        }

        if (model == null) {
          return ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, __) => const _ProductCardSkeleton(),
          );
        }

        if (products.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.24,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.searchController.text.trim().isEmpty
                            ? Icons.inventory_2_outlined
                            : Icons.search_off_rounded,
                        size: 48,
                        color: ColorResources.getTextSubTitle(context),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.searchController.text.trim().isEmpty
                            ? 'لم تضف أي منتجات بعد'
                            : 'لم نجد منتجات مطابقة',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ColorResources.getTextTitle(context),
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'AllineTajawal',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.searchController.text.trim().isEmpty
                            ? 'أضف منتجات متجرك لتبدأ بعرضها على Alline.'
                            : 'جرّب اسمًا مختلفًا أو غيّر الفلاتر.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ColorResources.getTextSubTitle(context),
                          fontSize: 13,
                          fontFamily: 'AllineTajawal',
                        ),
                      ),
                      if (widget.searchController.text.trim().isNotEmpty)
                        TextButton(
                          onPressed: () {
                            widget.searchController.clear();
                            _loadFirstPage();
                          },
                          child: const Text('مسح البحث'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: products.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'قائمة المنتجات',
                          style: TextStyle(
                            color: ColorResources.getTextTitle(context),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'AllineTajawal',
                          ),
                        ),
                      ),
                      Text(
                        '${products.length} من ${model.totalSize ?? products.length}',
                        style: TextStyle(
                          color: ColorResources.getTextSubTitle(context),
                          fontSize: 12,
                          fontFamily: 'AllineTajawal',
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (index > products.length - 1) {
                final hasMore = products.length < (model.totalSize ?? 0);
                if (!hasMore) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Text(
                      'تم عرض جميع المنتجات',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ColorResources.getTextSubTitle(context),
                        fontSize: 12,
                        fontFamily: 'AllineTajawal',
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Center(
                    child: _loadingMore
                        ? const _ProductCardSkeleton()
                        : const SizedBox.shrink(),
                  ),
                );
              }

              return SellerProductManagementCard(
                key: ValueKey(products[index].id ?? index),
                product: products[index],
                onChanged: _loadFirstPage,
              );
            },
          ),
        );
      },
    );
  }
}

class _ProductCardSkeleton extends StatelessWidget {
  const _ProductCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF26344A) : const Color(0xFFE8EEF6),
      highlightColor: isDark ? const Color(0xFF34445D) : Colors.white,
      child: Container(
        height: 112,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(height: 12, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 10),
                  Container(height: 12, width: 116, color: Colors.white),
                  const SizedBox(height: 10),
                  Container(height: 9, width: 148, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
