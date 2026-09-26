import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/domain/models/product_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/controllers/shop_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/shop_helper.dart';
import 'package:provider/provider.dart';

/// Alline Store Card ("يباع بواسطة").
///
/// Features:
/// - Compact store card with rounded border
/// - Store logo & name with verification badge
/// - Real rating & review count
/// - Location / city address
/// - "زيارة المتجر" button leading directly to seller profile
/// - Vacation / Temporary Closed notice if store is currently paused
class AllineStoreCard extends StatelessWidget {
  final ProductDetailsModel? product;

  const AllineStoreCard({super.key, required this.product});

  static const _primary = AllineColors.primary;
  static const _text = Color(0xFF071B49);
  static const _secondary = Color(0xFF6D85AF);
  static const _border = Color(0xFFE1E8F2);
  static const _orange = AllineColors.accent;
  static const _error = AllineColors.error;

  void _navigateToStore(BuildContext context, dynamic sellerInfo, bool isInHouse) {
    final splash = Provider.of<SplashController>(context, listen: false);

    if (isInHouse) {
      final inHouse = splash.configModel?.inHouseShop;
      RouterHelper.getTopSellerRoute(
        slug: inHouse?.slug,
        sellerId: 0,
        temporaryClose: splash.configModel?.inhouseTemporaryClose?.status ?? false,
        vacationStatus: splash.configModel?.inhouseVacationAdd?.status,
        vacationEndDate: splash.configModel?.inhouseVacationAdd?.vacationEndDate,
        vacationStartDate: splash.configModel?.inhouseVacationAdd?.vacationStartDate,
        vacationDurationType: splash.configModel?.inhouseVacationAdd?.vacationDurationType,
        name: inHouse?.name ?? 'متجر ألاين الرسمي',
        banner: inHouse?.bannerFullUrl?.path,
        image: inHouse?.imageFullUrl?.path,
      );
    } else {
      final seller = sellerInfo?.seller;
      final shop = seller?.shop ?? product?.seller?.shop;
      RouterHelper.getTopSellerRoute(
        action: RouteAction.push,
        slug: shop?.slug,
        sellerId: seller?.id ?? product?.seller?.id,
        temporaryClose: shop?.temporaryClose ?? false,
        vacationStatus: shop?.vacationStatus ?? false,
        vacationEndDate: shop?.vacationEndDate,
        vacationStartDate: shop?.vacationStartDate,
        vacationDurationType: shop?.vacationDurationType,
        name: shop?.name ?? product?.seller?.shop?.name,
        banner: shop?.bannerFullUrl?.path,
        image: shop?.imageFullUrl?.path,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (product == null) return const SizedBox.shrink();

    final bool isInHouse = product?.addedBy == 'admin';

    return Consumer2<ShopController, SplashController>(
      builder: (context, shopCtrl, splashCtrl, _) {
        final sellerInfo = shopCtrl.sellerInfoModelProductDetails;

        final String storeName = isInHouse
            ? (splashCtrl.configModel?.inHouseShop?.name ?? 'متجر ألاين الرسمي')
            : (sellerInfo?.seller?.shop?.name ??
                product?.seller?.shop?.name ??
                'المتجر');

        final String storeImage = isInHouse
            ? (splashCtrl.configModel?.inHouseShop?.imageFullUrl?.path ?? '')
            : (sellerInfo?.seller?.shop?.imageFullUrl?.path ??
                product?.seller?.shop?.imageFullUrl?.path ??
                '');

        final String storeAddress = isInHouse
            ? 'صنعاء، اليمن'
            : (sellerInfo?.seller?.shop?.address ??
                product?.seller?.shop?.address ??
                '');

        final double rating = double.tryParse(sellerInfo?.avgRating ?? '0') ?? 0.0;
        final int totalReviews = sellerInfo?.totalReview ?? 0;

        final bool isVacationActive = ShopHelper.isVacationActive(
          context,
          startDate: sellerInfo?.seller?.shop?.vacationStartDate ??
              product?.seller?.shop?.vacationStartDate,
          endDate: sellerInfo?.seller?.shop?.vacationEndDate ??
              product?.seller?.shop?.vacationEndDate,
          vacationDurationType: sellerInfo?.seller?.shop?.vacationDurationType ??
              product?.seller?.shop?.vacationDurationType,
          vacationStatus: sellerInfo?.seller?.shop?.vacationStatus ??
              product?.seller?.shop?.vacationStatus,
          isInHouseSeller: isInHouse,
        );

        final bool isClosed = isVacationActive ||
            (isInHouse
                ? (splashCtrl.configModel?.inhouseTemporaryClose?.status ?? false)
                : (sellerInfo?.seller?.shop?.temporaryClose ??
                    product?.seller?.shop?.temporaryClose ??
                    false));

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'يباع بواسطة',
                style: TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: _secondary,
                ),
              ),
              const SizedBox(height: 8),

              // Store Card Container
              InkWell(
                onTap: () => _navigateToStore(context, sellerInfo, isInHouse),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _border),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      // Store Avatar
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _border),
                        ),
                        child: ClipOval(
                          child: CustomImageWidget(
                            image: storeImage,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Store Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    storeName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'AllineTajawal',
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: _text,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified_rounded,
                                  color: _primary,
                                  size: 16,
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                if (rating > 0) ...[
                                  const Icon(Icons.star_rounded,
                                      size: 15, color: _orange),
                                  const SizedBox(width: 3),
                                  Text(
                                    rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontFamily: 'AllineTajawal',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _text,
                                    ),
                                  ),
                                  if (totalReviews > 0)
                                    Text(
                                      ' ($totalReviews)',
                                      style: const TextStyle(
                                        fontFamily: 'AllineTajawal',
                                        fontSize: 11,
                                        color: _secondary,
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                ],
                                if (storeAddress.isNotEmpty)
                                  Flexible(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          size: 13,
                                          color: _secondary,
                                        ),
                                        const SizedBox(width: 2),
                                        Flexible(
                                          child: Text(
                                            storeAddress,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontFamily: 'AllineTajawal',
                                              fontSize: 11.5,
                                              color: _secondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // "زيارة المتجر" Chevron Action
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'زيارة المتجر',
                            style: TextStyle(
                              fontFamily: 'AllineTajawal',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _primary,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: _primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Store temporarily closed banner
              if (isClosed) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 15, color: _error),
                      SizedBox(width: 6),
                      Text(
                        'المتجر مغلق حاليًا ولا يستقبل طلبات جديدة في الوقت الحالي',
                        style: TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 11.5,
                          color: _error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
