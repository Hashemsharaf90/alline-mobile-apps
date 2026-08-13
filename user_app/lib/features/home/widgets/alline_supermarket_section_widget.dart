import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
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
import 'package:latlong2/latlong.dart' as osm;
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
        final userLocation = _latLngFromStrings(
          productController.supermarketLatitude,
          productController.supermarketLongitude,
        );
        final storeLocations = stores
            .map(_storeLatLng)
            .whereType<_StoreMapPoint>()
            .toList(growable: false);
        final hasKnownLocation = userLocation != null ||
            (addressController.addressList ?? []).any(
              (address) =>
                  (address.latitude?.trim().isNotEmpty ?? false) &&
                  (address.longitude?.trim().isNotEmpty ?? false),
            );

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
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
                          _locationSubtitle(
                            isLtr: isLtr,
                            hasLocation: hasKnownLocation,
                            usingCurrentLocation: productController
                                .supermarketUsingCurrentLocation,
                          ),
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
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              if (productController.nearbySupermarketLoading)
                const LinearProgressIndicator(minHeight: 2),
              if (stores.isNotEmpty) ...[
                if (userLocation != null && storeLocations.isNotEmpty) ...[
                  _NearbyStoresMap(
                    userLocation: userLocation,
                    stores: storeLocations,
                    isLtr: isLtr,
                    onStoreTap: (store) =>
                        _openStore(context, store.data, category, isLtr),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                ],
                SizedBox(
                  height: 102,
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
                        deliveryFee: _storeDouble(store, 'delivery_fee'),
                        estimatedDeliveryMinutes:
                            _storeInt(store, 'estimated_delivery_minutes'),
                        productsCount: _storeInt(store, 'products_count'),
                        isLtr: isLtr,
                        onTap: () =>
                            _openStore(context, store, category, isLtr),
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
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusDefault),
                    image: const DecorationImage(
                      image: AssetImage(Images.allineSupermarketBanner),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: ThemeShadow.getShadow(context),
                  ),
                  child: Container(
                    padding:
                        const EdgeInsets.all(Dimensions.paddingSizeDefault),
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
            ],
          ),
        );
      },
    );
  }

  String _locationSubtitle({
    required bool isLtr,
    required bool hasLocation,
    required bool usingCurrentLocation,
  }) {
    if (!hasLocation) {
      return isLtr
          ? 'Allow location or add an address to show nearby supermarkets'
          : 'فعّل الموقع أو أضف عنوانًا لعرض السوبرماركت الأقرب إليك';
    }

    if (usingCurrentLocation) {
      return isLtr
          ? 'Nearby supermarkets from your current location'
          : 'سوبرماركت قريبة من موقعك الحالي';
    }

    return isLtr
        ? 'Nearby supermarkets from your saved address'
        : 'سوبرماركت قريبة من عنوانك المحفوظ';
  }

  CategoryModel? _findSupermarketCategory(List<CategoryModel> categories) {
    const keywords = [
      'السوبر ماركت',
      'سوبر ماركت',
      'سوبرماركت',
      'بقالة',
      'مواد غذائية',
      'أغذية',
      'تموينات',
      'ط³ظˆط¨ط±ظ…ط§ط±ظƒطھ',
      'ط³ظˆط¨ط± ظ…ط§ط±ظƒطھ',
      'ط§ظ„ط³ظˆط¨ط± ظ…ط§ط±ظƒطھ',
      'ط¨ظ‚ط§ظ„ط©',
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
            : 'أنشئ فئة السوبر ماركت أولًا ثم أضف منتجات البقالة إليها.',
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

  osm.LatLng? _latLngFromStrings(String? latitude, String? longitude) {
    final lat = double.tryParse(latitude?.trim() ?? '');
    final lng = double.tryParse(longitude?.trim() ?? '');
    if (lat == null || lng == null) {
      return null;
    }
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      return null;
    }
    return osm.LatLng(lat, lng);
  }

  _StoreMapPoint? _storeLatLng(Map store) {
    final point = _latLngFromStrings(
      _storeString(store, 'latitude'),
      _storeString(store, 'longitude'),
    );
    if (point == null) {
      return null;
    }

    return _StoreMapPoint(
      point: point,
      name: _storeString(store, 'name'),
      distanceKm: _storeDouble(store, 'distance_km'),
      data: store,
    );
  }
}

class _StoreMapPoint {
  final osm.LatLng point;
  final String name;
  final double? distanceKm;
  final Map data;

  const _StoreMapPoint({
    required this.point,
    required this.name,
    required this.distanceKm,
    required this.data,
  });
}

class _NearbyStoresMap extends StatelessWidget {
  final osm.LatLng userLocation;
  final List<_StoreMapPoint> stores;
  final bool isLtr;
  final ValueChanged<_StoreMapPoint> onStoreTap;

  const _NearbyStoresMap({
    required this.userLocation,
    required this.stores,
    required this.isLtr,
    required this.onStoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstStore = stores.first;
    final center = osm.LatLng(
      (userLocation.latitude + firstStore.point.latitude) / 2,
      (userLocation.longitude + firstStore.point.longitude) / 2,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: SizedBox(
        height: 178,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: _initialZoom(firstStore.distanceKm),
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.drag |
                      InteractiveFlag.pinchZoom |
                      InteractiveFlag.doubleTapZoom,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.sixamtech.sixvalley',
                  maxZoom: 19,
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: userLocation,
                      width: 42,
                      height: 42,
                      child: _MapMarker(
                        color: Theme.of(context).primaryColor,
                        icon: Icons.my_location,
                        tooltip: isLtr ? 'Your location' : 'موقعك',
                      ),
                    ),
                    ...stores.map(
                      (store) => Marker(
                        point: store.point,
                        width: 46,
                        height: 46,
                        child: GestureDetector(
                          onTap: () => onStoreTap(store),
                          child: _MapMarker(
                            color: const Color(0xFF168B4A),
                            icon: Icons.storefront,
                            tooltip: store.name.isEmpty
                                ? (isLtr ? 'Supermarket' : 'سوبرماركت')
                                : store.name,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('OpenStreetMap contributors'),
                  ],
                ),
              ],
            ),
            PositionedDirectional(
              start: Dimensions.paddingSizeSmall,
              top: Dimensions.paddingSizeSmall,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeSmall,
                  vertical: Dimensions.paddingSizeExtraSmall,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withValues(alpha: .92),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  boxShadow: ThemeShadow.getShadow(context),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.near_me,
                        size: 16, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      isLtr ? 'Nearest supermarkets' : 'أقرب سوبرماركت',
                      style: textMedium.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
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

  double _initialZoom(double? distanceKm) {
    if (distanceKm == null || distanceKm <= .6) {
      return 15;
    }
    if (distanceKm <= 2) {
      return 14;
    }
    if (distanceKm <= 6) {
      return 12;
    }
    return 11;
  }
}

class _MapMarker extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String tooltip;

  const _MapMarker({
    required this.color,
    required this.icon,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: ThemeShadow.getShadow(context),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _NearbyStoreCard extends StatelessWidget {
  final String name;
  final double? distanceKm;
  final double? deliveryFee;
  final int estimatedDeliveryMinutes;
  final int productsCount;
  final bool isLtr;
  final VoidCallback onTap;

  const _NearbyStoreCard({
    required this.name,
    required this.distanceKm,
    required this.deliveryFee,
    required this.estimatedDeliveryMinutes,
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
    final deliveryText = deliveryFee == null
        ? ''
        : (isLtr
            ? ' - delivery ${deliveryFee!.toStringAsFixed(0)}'
            : ' - توصيل ${deliveryFee!.toStringAsFixed(0)}');
    final etaText = estimatedDeliveryMinutes > 0
        ? (isLtr
            ? ' - $estimatedDeliveryMinutes min'
            : ' - $estimatedDeliveryMinutes د')
        : '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        width: 210,
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
              child: Icon(
                Icons.storefront_outlined,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty ? (isLtr ? 'Supermarket' : 'سوبرماركت') : name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$distanceText$deliveryText$etaText',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$productsCount ${isLtr ? 'items' : 'منتج'}',
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
          ],
        ),
      ),
    );
  }
}
