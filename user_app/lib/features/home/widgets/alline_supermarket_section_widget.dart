import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/product_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/controllers/address_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/domain/models/category_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';

class AllineSupermarketSectionWidget extends StatelessWidget {
  const AllineSupermarketSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isLtr =
        Provider.of<LocalizationController>(context, listen: false).isLtr;

    return Consumer3<CategoryController, ProductController, AddressController>(
      builder: (context, categoryController, productController,
          addressController, _) {
        final category =
            _findSupermarketCategory(categoryController.categoryList);
        final products =
            productController.supermarketProductModel?.products ?? [];
        final stores =
            productController.nearbySupermarkets.whereType<Map>().toList();
        final hasLocation = (addressController.addressList ?? []).any(
            (address) =>
                (address.latitude?.isNotEmpty ?? false) &&
                (address.longitude?.isNotEmpty ?? false));

        if (products.isEmpty && category == null && stores.isEmpty) {
          return const SizedBox();
        }

        return Container(
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.fromLTRB(
            Dimensions.homePagePadding,
            Dimensions.paddingSizeSmall,
            Dimensions.homePagePadding,
            Dimensions.paddingSizeDefault,
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLtr ? 'Supermarket' : 'السوبر ماركت',
                      textAlign: TextAlign.start,
                      style: textBold.copyWith(
                        fontSize: 22,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasLocation
                          ? (isLtr
                              ? 'Available around your saved location'
                              : 'متاجر ومنتجات قريبة حسب موقعك المحفوظ')
                          : (isLtr
                              ? 'Add an address for better local results'
                              : 'أضف عنوانك لعرض المتاجر الأقرب إليك'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _openSupermarket(context, category, isLtr),
                child: Text(isLtr ? 'View all' : 'عرض الكل'),
              ),
            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            if (productController.nearbySupermarketLoading)
              const LinearProgressIndicator(minHeight: 2),
            if (stores.isNotEmpty) ...[
              SizedBox(
                height: 92,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: stores.length > 8 ? 8 : stores.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                  itemBuilder: (context, index) {
                    final store = stores[index];
                    return _NearbyStoreCard(
                      name: _storeString(store, 'name'),
                      distanceKm: _storeDouble(store, 'distance_km'),
                      productsCount: _storeInt(store, 'products_count'),
                      isLtr: isLtr,
                      onTap: () => _openStore(context, store, category, isLtr),
                    );
                  },
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
            ],
            InkWell(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              onTap: () => _openSupermarket(context, category, isLtr),
              child: Ink(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  image: const DecorationImage(
                    image: AssetImage(Images.allineSupermarketBanner),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: ThemeShadow.getShadow(context),
                ),
                child: Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusDefault),
                    gradient: LinearGradient(
                      begin: AlignmentDirectional.centerStart,
                      end: AlignmentDirectional.centerEnd,
                      colors: [
                        Colors.white.withValues(alpha: .94),
                        Colors.white.withValues(alpha: .55),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 260),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isLtr
                                ? 'Fresh essentials near you'
                                : 'احتياجاتك اليومية بالقرب منك',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textBold.copyWith(
                              fontSize: 19,
                              color: const Color(0xFF103A52),
                            ),
                          ),
                          const SizedBox(
                              height: Dimensions.paddingSizeExtraSmall),
                          Text(
                            isLtr
                                ? 'Groceries, cleaning, food, and home basics in one place.'
                                : 'مواد غذائية، منظفات، وخيارات منزلية أساسية في مكان واحد.',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: const Color(0xFF516A78),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (products.isNotEmpty) ...[
              const SizedBox(height: Dimensions.paddingSizeDefault),
              SizedBox(
                height: 255,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length > 6 ? 6 : products.length,
                  itemBuilder: (context, index) => SizedBox(
                    width: 170,
                    child: ProductWidget(
                      productModel: products[index],
                      productNameLine: 2,
                      margin: Dimensions.paddingSizeExtraSmall,
                    ),
                  ),
                ),
              ),
            ],
          ]),
        );
      },
    );
  }

  CategoryModel? _findSupermarketCategory(List<CategoryModel> categories) {
    const keywords = [
      'سوبرماركت',
      'سوبر ماركت',
      'السوبر ماركت',
      'بقالة',
      'مواد غذائية',
      'مواد غذائيه',
      'اغذية',
      'أغذية',
      'تموينات',
      'خضار',
      'فواكه',
      'منظفات',
      'supermarket',
      'super market',
      'grocery',
      'food',
      'shopping',
      'market',
    ];

    for (final category in categories) {
      final name = (category.name ?? '').toLowerCase();
      final slug = (category.slug ?? '').toLowerCase();
      if (keywords
          .any((keyword) => name.contains(keyword) || slug.contains(keyword))) {
        return category;
      }
    }

    return null;
  }

  void _openSupermarket(
      BuildContext context, CategoryModel? category, bool isLtr) {
    if (category?.id == null) {
      showCustomSnackBarWidget(
        isLtr
            ? 'Create a supermarket category first, then add grocery products to it.'
            : 'أنشئ فئة السوبر ماركت أولاً ثم أضف منتجات البقالة إليها.',
        context,
        snackBarType: SnackBarType.warning,
      );
      return;
    }

    RouterHelper.getBrandCategoryRoute(
      action: RouteAction.push,
      isBrand: false,
      id: category!.id,
      name: category.name,
    );
  }

  void _openStore(
      BuildContext context, Map store, CategoryModel? category, bool isLtr) {
    final slug = _storeString(store, 'slug');
    if (slug.isEmpty) {
      _openSupermarket(context, category, isLtr);
      return;
    }

    RouterHelper.getTopSellerRoute(
      action: RouteAction.push,
      slug: slug,
      sellerId: _storeInt(store, 'seller_id'),
      name: _storeString(store, 'name'),
      totalProduct: _storeInt(store, 'products_count'),
    );
  }

  String _storeString(Map store, String key) {
    return store[key]?.toString().trim() ?? '';
  }

  int _storeInt(Map store, String key) {
    final value = store[key];
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double? _storeDouble(Map store, String key) {
    final value = store[key];
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }
}

class _NearbyStoreCard extends StatelessWidget {
  final String name;
  final double? distanceKm;
  final int productsCount;
  final bool isLtr;
  final VoidCallback onTap;

  const _NearbyStoreCard({
    required this.name,
    required this.distanceKm,
    required this.productsCount,
    required this.isLtr,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final distanceText = distanceKm == null
        ? (isLtr ? 'Nearby' : 'قريب')
        : (isLtr
            ? '${distanceKm!.toStringAsFixed(1)} km'
            : '${distanceKm!.toStringAsFixed(1)} كم');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        width: 190,
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            child: Icon(Icons.storefront_outlined,
                color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? (isLtr ? 'Supermarket' : 'سوبر ماركت') : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$distanceText - $productsCount ${isLtr ? 'items' : 'منتج'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
