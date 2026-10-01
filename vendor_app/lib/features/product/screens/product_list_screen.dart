import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/filter_icon_widget.dart';
import 'package:sixvalley_vendor_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/features/product/widgets/product_filter_bottomsheet_widget.dart';
import 'package:sixvalley_vendor_app/features/product/widgets/status_filter_widget.dart';
import 'package:sixvalley_vendor_app/features/product/screens/stock_out_product_screen.dart';
import 'package:sixvalley_vendor_app/helper/debounce_helper.dart';
import 'package:sixvalley_vendor_app/localization/controllers/localization_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/product_controller.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_search_field_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/screens/add_product_tab_view_screen.dart';
import 'package:sixvalley_vendor_app/features/product/widgets/product_widget.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

class ProductListMenuScreen extends StatefulWidget {
  final bool fromNotification;
  final bool isBackButtonExist;
  const ProductListMenuScreen({super.key, this.fromNotification = false, this.isBackButtonExist = true});
  @override
  State<ProductListMenuScreen> createState() => _ProductListMenuScreenState();
}

class _ProductListMenuScreenState extends State<ProductListMenuScreen> {
  final DebounceHelper _debounce = DebounceHelper(milliseconds: 500);
  final TextEditingController searchController = TextEditingController();
  int? userId;




  void _getBrandList() {
    String languageCode = Provider.of<LocalizationController>(context, listen: false).locale.countryCode == 'US' ?
    'en' : Provider.of<LocalizationController>(context, listen: false).locale.countryCode!.toLowerCase();
    Provider.of<ProductController>(Get.context!,listen: false).getBrandList(Get.context!, languageCode);
  }


  @override
  void initState() {
    userId = Provider.of<ProfileController>(context, listen: false).userId;
    Provider.of<ProductController>(context, listen: false).clearFilterData();
    _getBrandList();
    super.initState();
  }

  @override
  void dispose() {
    _debounce.dispose();
    searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if(widget.fromNotification) {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
            builder: (BuildContext context) => const DashboardScreen(),
          ), (route) => false);
        } else {
          if(!didPop) {
            Navigator.of(context).pop();
          }
        }
      },

      child: Scaffold(
        appBar: CustomAppBarWidget(
          title: getTranslated('product_list', context),
          isBackButtonExist: widget.isBackButtonExist,
          onBackPressed: () {
            if(widget.fromNotification) {
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const DashboardScreen()), (route) => false);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إدارة منتجات متجرك',
                    style: TextStyle(
                      color: ColorResources.getTextSubTitle(context),
                      fontSize: 14,
                      fontFamily: 'AllineTajawal',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddProductTabView(fromHome: false),
                          ),
                        );
                        if (!context.mounted) return;
                        _searchProducts(
                          Provider.of<ProductController>(context, listen: false),
                          searchController.text,
                        );
                      },
                      icon: const Icon(Icons.add_rounded, size: 22),
                      label: const Text(
                        'إضافة منتج',
                        style: TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AllineColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Consumer<ProductController>(
                    builder: (context, controller, _) => _ProductSummary(
                      total: controller.sellerProductModel?.totalSize,
                      onLowStockTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StockOutProductScreen(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  StatusFilterWidget(
                    onFilterChanged: (_) {},
                    searchController: searchController,
                  ),
                  const SizedBox(height: 12),
                  Consumer<ProductController>(
                    builder: (context, productController, _) => Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: CustomSearchFieldWidget(
                              controller: searchController,
                              hint: 'ابحث عن منتج...',
                              prefix: Images.iconsSearch,
                              iconPressed: () => _searchProducts(
                                productController,
                                searchController.text,
                              ),
                              onSubmit: (text) => _searchProducts(
                                productController,
                                text,
                              ),
                              onChanged: (value) => _debounce.run(
                                () => _searchProducts(productController, value),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FilterIconWidget(
                          filterCount: _getFilterCount(
                            productController.sellerProductModel,
                          ),
                          onTap: productController.sellerProductModel == null
                              ? null
                              : () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => ProductFilterBottomSheet(
                                searchController: searchController,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ProductViewWidget(
                sellerId: userId,
                fromNotification: widget.fromNotification,
                searchController: searchController,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _searchProducts(ProductController controller, String value) {
    final localization = Provider.of<LocalizationController>(context, listen: false);
    final languageCode = localization.locale.languageCode == 'en'
        ? 'en'
        : localization.locale.languageCode;
    controller.getSellerProductList(
      userId.toString(),
      1,
      languageCode,
      value,
      filterSearchModel: controller.filterModel.copyWith(reload: true),
    );
  }

  int _getFilterCount(ProductModel? sellerProductModel) {
    if (sellerProductModel == null) return 0;
    final int nonNullFilterCount = [
      sellerProductModel.productType,
      sellerProductModel.maxPrice,
      sellerProductModel.endDate,
      sellerProductModel.status,
      sellerProductModel.isApproved,
      sellerProductModel.sorting,
      sellerProductModel.offerType,
    ].whereType<Object>().length;


    final int categoryCount = sellerProductModel.categoryIds?.length ?? 0;
    final int subCategoryCount = sellerProductModel.filterSubCategoryIds?.length ?? 0;
    final int subSubCategoryCount = sellerProductModel.filterSubSubCategoryIds?.length ?? 0;
    final int brandCount = sellerProductModel.brandIds?.length ?? 0;
    final int publisherCount = sellerProductModel.publishHouseIds?.length ?? 0;
    final int authorCount = sellerProductModel.authorIds?.length ?? 0;

    return nonNullFilterCount +
        categoryCount +
        subCategoryCount +
        subSubCategoryCount +
        brandCount +
        publisherCount +
        authorCount;
  }

}

class _ProductSummary extends StatelessWidget {
  const _ProductSummary({this.total, required this.onLowStockTap});

  final int? total;
  final VoidCallback onLowStockTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = ColorResources.getBorder(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AllineColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AllineColors.primary,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إجمالي المنتجات',
                  style: TextStyle(
                    color: ColorResources.getTextSubTitle(context),
                    fontSize: 12,
                    fontFamily: 'AllineTajawal',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  total == null ? '—' : '$total',
                  style: TextStyle(
                    color: ColorResources.getTextTitle(context),
                    fontSize: 20,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'AllineTajawal',
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onLowStockTap,
            style: TextButton.styleFrom(
              foregroundColor: AllineColors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(44, 44),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.warning_amber_rounded, size: 17),
            label: const Text(
              'مخزون محدود',
              style: TextStyle(fontSize: 11, fontFamily: 'AllineTajawal'),
            ),
          ),
        ],
      ),
    );
  }
}
