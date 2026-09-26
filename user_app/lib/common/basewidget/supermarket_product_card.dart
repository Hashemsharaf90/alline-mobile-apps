import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/quick_add_to_cart_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:provider/provider.dart';

/// Dense but calm grocery card for quick supermarket browsing.
class SupermarketProductCard extends StatelessWidget {
  final Product product;
  final double? margin;

  const SupermarketProductCard({
    super.key,
    required this.product,
    this.margin,
  });

  bool get hasDiscount =>
      (product.discount ?? 0) > 0 ||
      (product.clearanceSale?.discountAmount ?? 0) > 0;

  double? get discountAmount =>
      (product.clearanceSale?.discountAmount ?? 0) > 0
          ? product.clearanceSale?.discountAmount
          : product.discount;

  String? get discountType =>
      (product.clearanceSale?.discountAmount ?? 0) > 0
          ? product.clearanceSale?.discountType
          : product.discountType;

  @override
  Widget build(BuildContext context) {
    final colors = context.allineColors;
    final soldOut =
        product.productType == 'physical' && product.currentStock == 0;
    final price = PriceConverter.convertPrice(
      context,
      product.unitPrice,
      discountType: discountType,
      discount: discountAmount,
    );
    final oldPrice = PriceConverter.convertPrice(context, product.unitPrice);
    final unit = product.unit?.trim();

    return Container(
      margin: EdgeInsets.all(margin ?? 4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDCE7F4)),
        boxShadow: [
          BoxShadow(
            color: AllineColors.primaryDark.withValues(alpha: .045),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: product.id == null
            ? null
            : () => RouterHelper.getProductDetailsRoute(
                  action: RouteAction.push,
                  productId: product.id,
                  slug: product.slug,
                ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 112,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: const Color(0xFFF7FAFE),
                      padding: const EdgeInsets.all(8),
                      child: product.thumbnailFullUrl?.path?.isNotEmpty == true
                          ? CustomImageWidget(
                              image: product.thumbnailFullUrl!.path!,
                              fit: BoxFit.contain,
                            )
                          : Icon(
                              Icons.local_grocery_store_outlined,
                              color: colors.textSecondary,
                              size: 40,
                            ),
                    ),
                  ),
                  if (hasDiscount)
                    PositionedDirectional(
                      top: 8,
                      start: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AllineColors.accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          discountType == 'percent' ||
                                  discountType == 'percentage'
                              ? '${discountAmount?.toStringAsFixed(0)}٪ خصم'
                              : 'عرض',
                          style: const TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  PositionedDirectional(
                    top: 8,
                    end: 8,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .92),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        product.wishList == 1
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 17,
                        color: product.wishList == 1
                            ? AllineColors.error
                            : colors.textSecondary,
                      ),
                    ),
                  ),
                  if (soldOut)
                    Positioned.fill(
                      child: Container(
                        color: Colors.white.withValues(alpha: .72),
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: colors.textSecondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'غير متوفر',
                            style: TextStyle(
                              fontFamily: 'AllineTajawal',
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textMedium.copyWith(
                      color: colors.textPrimary,
                      fontSize: 13,
                      height: 1.25,
                    ),
                  ),
                  if (unit?.isNotEmpty == true) ...[
                    const SizedBox(height: 3),
                    Text(
                      'لكل $unit',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textRegular.copyWith(
                        color: colors.textSecondary,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hasDiscount)
                              Text(
                                oldPrice,
                                style: textRegular.copyWith(
                                  color: colors.textSecondary,
                                  fontSize: 10,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            Text(
                              price,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textBold.copyWith(
                                color: AllineColors.primary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      QuickAddToCartWidget(
                        product: product,
                        height: 32,
                        iconSize: 17,
                      ),
                    ],
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
