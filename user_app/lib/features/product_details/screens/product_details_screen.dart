import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/title_row_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/controllers/flash_deal_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/controllers/product_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/alline_availability_badge.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/alline_delivery_card.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/alline_description_section.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/alline_price_section.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/alline_product_app_bar.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/alline_product_details_skeleton.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/alline_product_gallery.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/alline_product_summary.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/alline_quantity_selector.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/alline_related_products.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/alline_reviews_preview.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/alline_specifications_section.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/alline_sticky_purchase_bar.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/alline_store_card.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/alline_variant_selector.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/youtube_video_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/review/controllers/review_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/controllers/shop_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:provider/provider.dart';

/// Alline Product Details Screen.
///
/// Complete premium mobile e-commerce product experience for the Yemeni market:
/// - RTL first
/// - Large clean gallery
/// - Instant on-screen variant & quantity selection
/// - Store credentials & verification
/// - Delivery estimation
/// - Transparent reviews & real ratings
/// - Sticky purchase bar with direct add-to-cart & buy-now
class ProductDetails extends StatefulWidget {
  final int? productId;
  final String? slug;
  final bool isFromWishList;
  final bool isNotification;
  final bool fromFlashDeals;

  const ProductDetails({
    super.key,
    required this.productId,
    required this.slug,
    this.isFromWishList = false,
    this.isNotification = false,
    this.fromFlashDeals = false,
  });

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  static const _primary = AllineColors.primary;
  static const _text = Color(0xFF071B49);
  static const _secondary = Color(0xFF6D85AF);
  static const _softBlue = Color(0xFFF4F8FE);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final slug = widget.slug.toString();
    final detailsCtrl =
        Provider.of<ProductDetailsController>(context, listen: false);
    final reviewCtrl = Provider.of<ReviewController>(context, listen: false);
    final productCtrl = Provider.of<ProductController>(context, listen: false);
    final shopCtrl = Provider.of<ShopController>(context, listen: false);
    final splashCtrl = Provider.of<SplashController>(context, listen: false);

    await detailsCtrl.getProductDetails(context, slug, slug);
    if (!mounted) return;

    reviewCtrl.removePrevReview();
    detailsCtrl.removePrevLink();
    reviewCtrl.getReviewList(1, productSlug: widget.slug);
    productCtrl.removePrevRelatedProduct();
    productCtrl.initRelatedProductList(slug, context);
    detailsCtrl.getCount(slug, context);
    detailsCtrl.getSharableLink(slug, context);
    detailsCtrl.setImageSliderSelectedIndex(0, isUpdate: false);
    shopCtrl.emptyProductDetailsSeller();

    final model = detailsCtrl.productDetailsModel;
    if (model != null) {
      detailsCtrl.initData(model, model.minimumOrderQty ?? 1, context);
      detailsCtrl.initDigitalVariationIndex();

      final String sellerSlug = model.addedBy == 'admin'
          ? splashCtrl.configModel?.inHouseShop?.slug ?? ''
          : model.seller?.shop?.slug ?? '';

      if (sellerSlug.isNotEmpty) {
        shopCtrl.getSellerInfoProductDetails(
          model.addedBy == 'admin' ? '0' : (model.seller?.id?.toString() ?? '0'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: PopScope(
        canPop: Navigator.canPop(context),
        onPopInvokedWithResult: (didPop, result) async {
          if (widget.isNotification) {
            RouterHelper.getDashboardRoute(
                action: RouteAction.pushNamedAndRemoveUntil);
          }
        },
        child: Consumer<ProductDetailsController>(
          builder: (context, details, _) {
            final product = details.productDetailsModel;
            final bool isLoading = details.isDetails;
            final bool hasError = !isLoading && product == null;

            return Scaffold(
              backgroundColor: _softBlue,
              appBar: AllineProductAppBar(
                product: product,
                isNotification: widget.isNotification,
              ),
              body: RefreshIndicator(
                color: _primary,
                onRefresh: () => _loadData(),
                child: isLoading
                    ? const AllineProductDetailsSkeleton()
                    : hasError
                        ? _buildErrorState(context)
                        : SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Flash Deal Countdown Banner
                                if (widget.fromFlashDeals)
                                  _buildFlashDealBanner(context),

                                // 1. Gallery
                                AllineProductGallery(product: product),
                                const _SectionDivider(),

                                // 2. Summary (Title, Rating, Orders/Wishlist)
                                AllineProductSummary(product: product),

                                // 3. Price & Discount
                                AllinePriceSection(product: product),

                                // 4. Availability
                                AllineAvailabilityBadge(product: product),

                                // 5. Variants (Colors & Options)
                                AllineVariantSelector(product: product),

                                // 6. Quantity Stepper
                                AllineQuantitySelector(product: product),
                                const _SectionDivider(),

                                // 7. Store Information
                                AllineStoreCard(product: product),
                                const _SectionDivider(),

                                // 8. Delivery Information
                                AllineDeliveryCard(product: product),
                                const _SectionDivider(),

                                // 9. Video Preview (if available)
                                if (product?.videoUrl != null &&
                                    details.isValidYouTubeUrl(product!.videoUrl!))
                                  Container(
                                    color: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    child: YoutubeVideoWidget(
                                        url: product.videoUrl),
                                  ),

                                // 10. Product Description
                                AllineDescriptionSection(product: product),
                                const _SectionDivider(),

                                // 11. Specifications Table
                                AllineSpecificationsSection(product: product),
                                const _SectionDivider(),

                                // 12. Reviews Preview
                                AllineReviewsPreview(product: product),
                                const _SectionDivider(),

                                // 13. Related Products Carousel
                                const AllineRelatedProducts(),

                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
              ),

              // Sticky Bottom Purchase Bar
              bottomNavigationBar: (!isLoading && product != null)
                  ? AllineStickyPurchaseBar(product: product)
                  : null,
            );
          },
        ),
      ),
    );
  }

  Widget _buildFlashDealBanner(BuildContext context) {
    return Consumer<FlashDealController>(
      builder: (context, flashDealController, _) {
        final Duration? eventDuration = flashDealController.duration;
        int? days, hours, minutes, seconds;
        if (eventDuration != null) {
          days = eventDuration.inDays;
          hours = eventDuration.inHours - days * 24;
          minutes = eventDuration.inMinutes - (24 * days * 60) - (hours * 60);
          seconds = eventDuration.inSeconds -
              (24 * days * 60 * 60) -
              (hours * 60 * 60) -
              (minutes * 60);
        }

        return Container(
          color: const Color(0xFFFFF7ED),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                getTranslated('this_product_is_now_on_a_flash_deal', context) ??
                    'عرض خاص لفترة محدودة',
                style: const TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC2410C),
                ),
              ),
              if (eventDuration != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TimerBox(
                      time: days,
                      day: getTranslated('day', context),
                      isDetailsPage: true,
                    ),
                    const SizedBox(width: 4),
                    TimerBox(
                      time: hours,
                      day: getTranslated('hour', context),
                      isDetailsPage: true,
                    ),
                    const SizedBox(width: 4),
                    TimerBox(
                      time: minutes,
                      day: getTranslated('min', context),
                      isDetailsPage: true,
                    ),
                    const SizedBox(width: 4),
                    TimerBox(
                      time: seconds,
                      day: getTranslated('sec', context),
                      isDetailsPage: true,
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: _secondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'المنتج غير متاح حالياً',
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _text,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'قد يكون المنتج قد تم حذفه أو أن هناك مشكلة في الاتصال بالإنترنت.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 13.5,
                color: _secondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      RouterHelper.getDashboardRoute(
                          action: RouteAction.pushNamedAndRemoveUntil);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'العودة للمنتجات',
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _text,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _loadData(),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text(
                    'إعادة المحاولة',
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 8px visual gap between white card sections on soft blue canvas.
class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      color: const Color(0xFFF4F8FE),
    );
  }
}
