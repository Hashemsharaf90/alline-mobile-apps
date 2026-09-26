import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/controllers/product_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/domain/models/product_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/screens/product_image_screen.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:provider/provider.dart';

/// Premium Product Image Gallery.
///
/// Features:
/// - Large clean white background presentation
/// - Horizontal swipe PageView
/// - Smooth dot indicators + image counter badge (e.g., 1 / 4)
/// - Alline Orange discount badge (خصم X%)
/// - Global product badge if product is imported/global
/// - Tap to view full-screen zoomable gallery
class AllineProductGallery extends StatefulWidget {
  final ProductDetailsModel? product;

  const AllineProductGallery({super.key, required this.product});

  @override
  State<AllineProductGallery> createState() => _AllineProductGalleryState();
}

class _AllineProductGalleryState extends State<AllineProductGallery> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  static const _primary = AllineColors.primary;
  static const _orange = AllineColors.accent;
  static const _border = Color(0xFFE1E8F2);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    if (product == null) return const SizedBox.shrink();

    final images = product.imagesFullUrl ?? [];
    final imageCount = images.isNotEmpty ? images.length : 1;

    // Discount computation
    final double? discount = (product.clearanceSale?.discountAmount ?? 0) > 0
        ? product.clearanceSale?.discountAmount
        : product.discount;
    final String? discountType = (product.clearanceSale?.discountAmount ?? 0) > 0
        ? product.clearanceSale?.discountType
        : product.discountType;
    final bool hasDiscount = (discount != null && discount > 0);

    // Global shopping check
    final bool isGlobal = product.productType == 'global' ||
        product.slug?.contains('global') == true;

    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        children: [
          // Main Image View
          SizedBox(
            height: MediaQuery.of(context).size.width * 0.88,
            child: Stack(
              children: [
                // Swipeable PageView
                if (images.isNotEmpty)
                  PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                      context
                          .read<ProductDetailsController>()
                          .setImageSliderSelectedIndex(index, isUpdate: false);
                    },
                    itemBuilder: (context, index) {
                      final imgUrl = images[index].path ?? '';
                      return GestureDetector(
                        onTap: () {
                          if (!(product.productImagesNull ?? true)) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProductImageScreen(
                                  title: getTranslated('product_image', context) ?? 'صورة المنتج',
                                  imageList: product.imagesFullUrl,
                                ),
                              ),
                            );
                          }
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            child: CustomImageWidget(
                              image: imgUrl,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: CustomImageWidget(
                        image: product.thumbnailFullUrl?.path ?? '',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                // Top-right badges (Discount & Global)
                Positioned(
                  top: 12,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Discount Badge
                      if (hasDiscount)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _orange,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: _orange.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            PriceConverter.percentageCalculation(
                              context,
                              product.unitPrice,
                              discount,
                              discountType,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'AllineTajawal',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      // Global Shopping badge
                      if (isGlobal) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.public_rounded,
                                  size: 13, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'منتج عالمي',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'AllineTajawal',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Bottom counter pill (e.g., 1 / 4)
                if (imageCount > 1)
                  Positioned(
                    bottom: 12,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentIndex + 1} / $imageCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Indicator Dots
          if (imageCount > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  imageCount,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentIndex == index ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? _primary
                          : _border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
