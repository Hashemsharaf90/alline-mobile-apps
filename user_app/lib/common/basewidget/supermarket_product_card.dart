import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/discount_tag_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/quick_add_to_cart_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

/// A compact, high-density product card designed specifically for fast grocery/supermarket browsing.
/// Fits 2 or 3 cards per row, displaying item image, discount badge, name, price, and a quick +/- cart stepper.
class SupermarketProductCard extends StatelessWidget {
  final Product product;
  final double? margin;

  const SupermarketProductCard({
    super.key,
    required this.product,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.allineColors;
    final isDark =
        Provider.of<ThemeController>(context, listen: false).darkTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      onTap: () {
        RouterHelper.getProductDetailsRoute(
          action: RouteAction.push,
          productId: product.id,
          slug: product.slug,
        );
      },
      child: Container(
        margin: EdgeInsets.all(margin ?? Dimensions.paddingSizeExtraSmall),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(
            color: colors.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.18)
                  : AllineColors.primaryDark.withValues(alpha: 0.04),
              spreadRadius: 0,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      padding: const EdgeInsets.all(
                          Dimensions.paddingSizeExtraSmall),
                      color: isDark
                          ? Theme.of(context).highlightColor
                          : colors.background,
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusSmall),
                        child: CustomImageWidget(
                          image: '${product.thumbnailFullUrl?.path}',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  // Details
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall,
                        vertical: Dimensions.paddingSizeExtraSmall,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Title
                          Text(
                            product.name ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              height: 1.2,
                              color: colors.textPrimary,
                            ),
                          ),

                          const SizedBox(height: 2),

                          // Price & Quick-Add Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Prices
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (hasDiscount())
                                      Text(
                                        PriceConverter.convertPrice(
                                          context,
                                          product.unitPrice,
                                        ),
                                        style: textRegular.copyWith(
                                          color: colors.textSecondary,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          fontSize:
                                              Dimensions.fontSizeExtraSmall,
                                        ),
                                      ),
                                    Text(
                                      PriceConverter.convertPrice(
                                        context,
                                        product.unitPrice,
                                        discountType: (product.clearanceSale
                                                        ?.discountAmount ??
                                                    0) >
                                                0
                                            ? product
                                                .clearanceSale?.discountType
                                            : product.discountType,
                                        discount: (product.clearanceSale
                                                        ?.discountAmount ??
                                                    0) >
                                                0
                                            ? product
                                                .clearanceSale?.discountAmount
                                            : product.discount,
                                      ),
                                      style: textBold.copyWith(
                                        color: isDark
                                            ? colors.textPrimary
                                            : AllineColors.primary,
                                        fontSize: Dimensions.fontSizeDefault,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Quick Add-to-cart button
                              QuickAddToCartWidget(
                                product: product,
                                height: 30,
                                iconSize: 16,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Out of Stock Overlay
              if (product.currentStock == 0 &&
                  product.productType == 'physical')
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                      child: Text(
                        'Out of Stock',
                        style: textBold.copyWith(
                          color: Colors.white,
                          fontSize: Dimensions.fontSizeExtraSmall,
                        ),
                      ),
                    ),
                  ),
                ),

              // Discount Tag
              if (hasDiscount())
                DiscountTagWidget(
                  productModel: product,
                  positionedTop: 0,
                  topLeftBorderRadius: Dimensions.radiusDefault,
                  bottomRightBorderRadius: Dimensions.radiusDefault,
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool hasDiscount() =>
      (product.discount != null && product.discount! > 0) ||
      (product.clearanceSale?.discountAmount ?? 0) > 0;
}
