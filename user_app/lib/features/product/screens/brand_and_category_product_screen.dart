import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/domain/models/category_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/widgets/alline_product_listing_view.dart';
import 'package:flutter_sixvalley_ecommerce/helper/debounce_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:provider/provider.dart';

/// Alline's reusable category/brand product-listing entry point.
/// It preserves the current API, category selection and pagination behaviour.
class BrandAndCategoryProductScreen extends StatefulWidget {
  final bool isBrand;
  final int? id;
  final String? name;
  final String? image;
  final CategoryModel? categoryModel;
  final SubCategory? subCategory;
  final bool isInsideSubSubCategory;
  final bool isAllProduct;

  const BrandAndCategoryProductScreen({
    super.key,
    required this.isBrand,
    required this.id,
    required this.name,
    this.image,
    this.subCategory,
    this.isInsideSubSubCategory = false,
    this.categoryModel,
    this.isAllProduct = false,
  });

  @override
  State<BrandAndCategoryProductScreen> createState() =>
      _BrandAndCategoryProductScreenState();
}

class _BrandAndCategoryProductScreenState
    extends State<BrandAndCategoryProductScreen> {
  final _searchController = TextEditingController();
  final _debounce = DebounceHelper(milliseconds: 500);
  final _categoryController = ScrollController();
  List<_ListingCategory> _categories = const [];

  @override
  void initState() {
    super.initState();
    final products = context.read<ProductController>();
    products.setCategorySearchProductText('', isUpdate: false);
    if (widget.id != null) {
      products.updateSelectedCategoryId(id: widget.id!, isUpdate: false);
    }
    _setCategories();
    _loadProducts(widget.id);
  }

  void _setCategories() {
    final allName =
        widget.isBrand ? (widget.name ?? 'كل المنتجات') : 'كل المنتجات';
    final items = <_ListingCategory>[];
    if (widget.subCategory?.subSubCategories?.isNotEmpty ?? false) {
      items.add(_ListingCategory(widget.subCategory?.id, allName,
          widget.subCategory?.totalProductCount));
      items.addAll(widget.subCategory!.subSubCategories!.map((item) =>
          _ListingCategory(item.id, item.name ?? '', item.totalProductCount)));
    } else if (widget.categoryModel?.subCategories?.isNotEmpty ?? false) {
      items.add(_ListingCategory(widget.categoryModel?.id, allName,
          widget.categoryModel?.totalProductCount));
      items.addAll(widget.categoryModel!.subCategories!.map((item) =>
          _ListingCategory(item.id, item.name ?? '', item.totalProductCount)));
    }
    _categories = items;
  }

  Future<void> _loadProducts(int? id, {int offset = 1, bool update = false}) =>
      context.read<ProductController>().initBrandOrCategoryProductList(
            isBrand: widget.isBrand,
            id: id,
            searchProduct: _searchController.text.trim(),
            offset: offset,
            isUpdate: update,
          );

  void _submitSearch() {
    _debounce.run(() => _loadProducts(
        context.read<ProductController>().selectedCategoryId,
        update: true));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          tooltip: 'رجوع',
          icon:
              const Icon(Icons.arrow_forward_rounded, color: Color(0xFF071B49)),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(widget.name ?? 'المنتجات',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF071B49))),
        actions: [
          IconButton(
            tooltip: 'السلة',
            icon: const Icon(Icons.shopping_cart_outlined,
                color: Color(0xFF071B49)),
            onPressed: () => RouterHelper.getCartScreenRoute(
                action: RouteAction.push, showBackButton: true),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Consumer<ProductController>(builder: (context, controller, _) {
        final model = controller.brandOrCategoryProductList;
        return Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              textDirection: TextDirection.rtl,
              onChanged: (value) {
                controller.setCategorySearchProductText(value);
                setState(() {});
              },
              onSubmitted: (_) => _submitSearch(),
              decoration: InputDecoration(
                hintText: 'ابحث في ${widget.name ?? 'المنتجات'}',
                hintStyle: const TextStyle(
                    fontFamily: 'AllineTajawal', color: Color(0xFF6D85AF)),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AllineColors.primary),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Color(0xFF6D85AF)),
                        onPressed: () {
                          _searchController.clear();
                          controller.setCategorySearchProductText('');
                          _loadProducts(controller.selectedCategoryId,
                              update: true);
                          setState(() {});
                        },
                      ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: _searchBorder(const Color(0xFFE1E8F2)),
                enabledBorder: _searchBorder(const Color(0xFFE1E8F2)),
                focusedBorder: _searchBorder(AllineColors.primary, 1.4),
              ),
            ),
          ),
          if (_categories.isNotEmpty)
            SizedBox(
              height: 44,
              child: ListView.separated(
                controller: _categoryController,
                padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final selected = category.id == controller.selectedCategoryId;
                  return ChoiceChip(
                    label: Text(category.count == null
                        ? category.name
                        : '${category.name} (${category.count})'),
                    selected: selected,
                    selectedColor: const Color(0xFFE7F0FC),
                    side: BorderSide(
                        color: selected
                            ? AllineColors.primary
                            : const Color(0xFFE1E8F2)),
                    labelStyle: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 13,
                        color: selected
                            ? AllineColors.primary
                            : const Color(0xFF071B49),
                        fontWeight: FontWeight.w600),
                    onSelected: (_) {
                      if (category.id == null ||
                          category.id == controller.selectedCategoryId) {
                        return;
                      }
                      _searchController.clear();
                      controller.updateSelectedCategoryId(id: category.id!);
                      _loadProducts(category.id, update: true);
                      setState(() {});
                    },
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(widget.name ?? 'المنتجات',
                  style: const TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF071B49))),
            ),
          ),
          Expanded(
              child: AllineProductListingView(
            key: PageStorageKey<String>(
                'category-${controller.selectedCategoryId}-${widget.isBrand}'),
            products: model?.products ?? const [],
            totalSize: model?.totalSize,
            isLoading: model == null,
            searchQuery: _searchController.text,
            onReload: () => _loadProducts(controller.selectedCategoryId,
                offset: 1, update: true),
            onLoadMore: () async {
              if (model?.totalSize != null &&
                  (model?.products?.length ?? 0) >= model!.totalSize!) {
                return;
              }
              await _loadProducts(controller.selectedCategoryId,
                  offset: (model?.offset ?? 0) + 1);
            },
          )),
        ]);
      }),
    );
  }

  OutlineInputBorder _searchBorder(Color color, [double width = 1]) =>
      OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: width));
}

class _ListingCategory {
  final int? id;
  final String name;
  final int? count;
  const _ListingCategory(this.id, this.name, this.count);
}
