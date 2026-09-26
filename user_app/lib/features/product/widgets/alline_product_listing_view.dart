import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_product_card.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';

/// Shared, Arabic-first product grid used by category and brand listings.
/// Server pagination remains owned by the host screen; sorting and refinement
/// intentionally operate on the products that are already loaded.
class AllineProductListingView extends StatefulWidget {
  final List<Product> products;
  final int? totalSize;
  final bool isLoading;
  final String searchQuery;
  final Future<void> Function()? onLoadMore;
  final Future<void> Function()? onReload;

  const AllineProductListingView({
    super.key,
    required this.products,
    required this.searchQuery,
    this.totalSize,
    this.isLoading = false,
    this.onLoadMore,
    this.onReload,
  });

  @override
  State<AllineProductListingView> createState() =>
      _AllineProductListingViewState();
}

class _AllineProductListingViewState extends State<AllineProductListingView> {
  final ScrollController _scrollController = ScrollController();
  String _sort = 'الأحدث';
  String? _brand;
  double? _minimumRating;
  double? _minimumPrice;
  double? _maximumPrice;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_listenForPagination);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_listenForPagination)
      ..dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AllineProductListingView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.products.length != oldWidget.products.length ||
        (!widget.isLoading && oldWidget.isLoading)) {
      _loadingMore = false;
    }
  }

  Future<void> _listenForPagination() async {
    if (_loadingMore ||
        widget.onLoadMore == null ||
        !_hasMore ||
        !_scrollController.hasClients ||
        _scrollController.position.extentAfter > 360) {
      return;
    }
    setState(() => _loadingMore = true);
    try {
      await widget.onLoadMore!();
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  bool get _hasMore =>
      widget.onLoadMore != null &&
      (widget.totalSize == null || widget.products.length < widget.totalSize!);

  Future<void> _changeRefinement(VoidCallback change) async {
    setState(change);
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    await widget.onReload?.call();
  }

  double _rating(Product product) {
    final ratings = product.rating;
    return double.tryParse(product.reviewsAvgRating ?? '') ??
        ((ratings?.isNotEmpty ?? false)
            ? double.tryParse(ratings!.first.average ?? '') ?? 0
            : 0);
  }

  List<Product> get _visibleProducts {
    final query = widget.searchQuery.trim().toLowerCase();
    final unique = <String>{};
    final products = widget.products.where((product) {
      final key = product.id != null
          ? 'id:${product.id}'
          : product.slug?.trim().isNotEmpty == true
              ? 'slug:${product.slug}'
              : 'name:${product.name?.trim()}';
      if (!unique.add(key)) return false;
      final matchesQuery =
          query.isEmpty || (product.name ?? '').toLowerCase().contains(query);
      final price = product.unitPrice ?? 0;
      return matchesQuery &&
          (_brand == null || product.brand?.name == _brand) &&
          (_minimumRating == null || _rating(product) >= _minimumRating!) &&
          (_minimumPrice == null || price >= _minimumPrice!) &&
          (_maximumPrice == null || price <= _maximumPrice!);
    }).toList();
    switch (_sort) {
      case 'السعر: الأقل أولاً':
        products.sort((a, b) => (a.unitPrice ?? 0).compareTo(b.unitPrice ?? 0));
      case 'السعر: الأعلى أولاً':
        products.sort((a, b) => (b.unitPrice ?? 0).compareTo(a.unitPrice ?? 0));
      case 'الأعلى تقييماً':
        products.sort((a, b) => _rating(b).compareTo(_rating(a)));
    }
    return products;
  }

  bool get _hasRefinement =>
      _brand != null ||
      _minimumRating != null ||
      _minimumPrice != null ||
      _maximumPrice != null ||
      _sort != 'الأحدث';

  Future<void> _showChoices(
      {required String title,
      required List<String> choices,
      required String? selected,
      required ValueChanged<String> onSelect}) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ListingSheet(
        title: title,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: choices.length,
          separatorBuilder: (_, __) =>
              Divider(height: 1, color: context.allineColors.border),
          itemBuilder: (context, index) => ListTile(
            title: Text(choices[index],
                style: TextStyle(
                    fontFamily: 'AllineTajawal',
                    color: context.allineColors.textPrimary,
                    fontWeight: FontWeight.w600)),
            trailing: choices[index] == selected
                ? const Icon(Icons.check_circle_rounded,
                    color: AllineColors.primary)
                : null,
            onTap: () {
              onSelect(choices[index]);
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showPriceSheet() async {
    final minController =
        TextEditingController(text: _minimumPrice?.toStringAsFixed(0) ?? '');
    final maxController =
        TextEditingController(text: _maximumPrice?.toStringAsFixed(0) ?? '');
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
        child: _ListingSheet(
            title: 'نطاق السعر',
            child: Column(children: [
              Row(children: [
                Expanded(child: _priceField(minController, 'من')),
                const SizedBox(width: 12),
                Expanded(child: _priceField(maxController, 'إلى')),
              ]),
              const SizedBox(height: 16),
              SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: AllineColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))),
                    onPressed: () {
                      _changeRefinement(() {
                        _minimumPrice = double.tryParse(minController.text);
                        _maximumPrice = double.tryParse(maxController.text);
                      });
                      Navigator.pop(sheetContext);
                    },
                    child: const Text('تطبيق',
                        style: TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontWeight: FontWeight.w700)),
                  )),
            ])),
      ),
    );
    minController.dispose();
    maxController.dispose();
  }

  Widget _priceField(TextEditingController controller, String hint) =>
      TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textDirection: TextDirection.ltr,
        decoration: InputDecoration(
            hintText: hint,
            hintTextDirection: TextDirection.rtl,
            filled: true,
            fillColor: context.allineColors.background,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: context.allineColors.border))),
      );

  @override
  Widget build(BuildContext context) {
    final brands = widget.products
        .map((product) => product.brand?.name)
        .whereType<String>()
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    final products = _visibleProducts;
    final displayedTotal =
        _hasRefinement || widget.searchQuery.trim().isNotEmpty
            ? products.length
            : (widget.totalSize ?? products.length);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
        child: Text('$displayedTotal منتج',
            style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 14,
                color: context.allineColors.textSecondary)),
      ),
      SizedBox(
          height: 46,
          child: ListView(
            padding: const EdgeInsetsDirectional.only(start: 20, end: 20),
            scrollDirection: Axis.horizontal,
            children: [
              _FilterChip(
                  label: 'فلترة',
                  icon: Icons.tune_rounded,
                  active: _hasRefinement,
                  onTap: () => _changeRefinement(() {
                        _brand = null;
                        _minimumRating = null;
                        _minimumPrice = null;
                        _maximumPrice = null;
                        _sort = 'الأحدث';
                      })),
              _FilterChip(
                  label: 'الترتيب',
                  active: _sort != 'الأحدث',
                  onTap: () => _showChoices(
                      title: 'ترتيب المنتجات',
                      choices: const [
                        'الأحدث',
                        'السعر: الأقل أولاً',
                        'السعر: الأعلى أولاً',
                        'الأعلى تقييماً'
                      ],
                      selected: _sort,
                      onSelect: (value) =>
                          _changeRefinement(() => _sort = value))),
              _FilterChip(
                  label: 'السعر',
                  active: _minimumPrice != null || _maximumPrice != null,
                  onTap: _showPriceSheet),
              if (brands.isNotEmpty)
                _FilterChip(
                    label: 'العلامة التجارية',
                    active: _brand != null,
                    onTap: () => _showChoices(
                        title: 'العلامة التجارية',
                        choices: brands,
                        selected: _brand,
                        onSelect: (value) =>
                            _changeRefinement(() => _brand = value))),
              _FilterChip(
                  label: 'التقييم',
                  active: _minimumRating != null,
                  onTap: () => _showChoices(
                      title: 'التقييم',
                      choices: const ['4+ نجوم', '3+ نجوم'],
                      selected: _minimumRating == null
                          ? null
                          : '${_minimumRating!.toInt()}+ نجوم',
                      onSelect: (value) => _changeRefinement(() =>
                          _minimumRating = value.startsWith('4') ? 4 : 3))),
            ],
          )),
      const SizedBox(height: 12),
      Expanded(
          child: widget.isLoading
              ? const _ListingSkeleton()
              : products.isEmpty
                  ? const _EmptyProducts()
                  : CustomScrollView(
                      key: const PageStorageKey<String>(
                          'alline-product-listing-scroll'),
                      controller: _scrollController,
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          sliver: SliverGrid.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: .52,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) =>
                                AllineProductCard(product: products[index]),
                          ),
                        ),
                        if (_loadingMore)
                          const SliverPadding(
                            padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
                            sliver: SliverGrid(
                              delegate: SliverChildListDelegate.fixed([
                                _ListingCardSkeleton(),
                                _ListingCardSkeleton(),
                              ]),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: .52,
                              ),
                            ),
                          )
                        else if (!_hasMore)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                              child: Center(
                                child: Text(
                                  'تم عرض جميع المنتجات',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color:
                                            context.allineColors.textSecondary,
                                      ),
                                ),
                              ),
                            ),
                          )
                        else
                          const SliverToBoxAdapter(child: SizedBox(height: 16)),
                      ],
                    )),
    ]);
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool active;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label,
      required this.active,
      required this.onTap,
      this.icon});

  @override
  Widget build(BuildContext context) {
    final colors = context.allineColors;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Material(
        color: active
            ? Theme.of(context).colorScheme.primaryContainer
            : colors.surface,
        shape: StadiumBorder(
            side: BorderSide(
                color: active ? AllineColors.primary : colors.border)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AllineColors.primary),
                const SizedBox(width: 5)
              ],
              Text(label,
                  style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 13,
                      color: active ? AllineColors.primary : colors.textPrimary,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _ListingSheet extends StatelessWidget {
  final String title;
  final Widget child;
  const _ListingSheet({required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      decoration: BoxDecoration(
          color: context.allineColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: SafeArea(
          top: false,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: context.allineColors.textPrimary)),
                const SizedBox(height: 14),
                child
              ])));
}

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts();
  @override
  Widget build(BuildContext context) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.inventory_2_outlined,
            size: 42, color: context.allineColors.textSecondary),
        const SizedBox(height: 12),
        Text('لا توجد منتجات مطابقة',
            style: TextStyle(
                fontFamily: 'AllineTajawal',
                color: context.allineColors.textPrimary,
                fontWeight: FontWeight.w600))
      ]));
}

class _ListingSkeleton extends StatelessWidget {
  const _ListingSkeleton();
  @override
  Widget build(BuildContext context) => GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: .52),
      itemBuilder: (_, __) => const _ListingCardSkeleton());
}

class _ListingCardSkeleton extends StatelessWidget {
  const _ListingCardSkeleton();

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: context.allineColors.skeletonBase,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.allineColors.border),
        ),
      );
}
