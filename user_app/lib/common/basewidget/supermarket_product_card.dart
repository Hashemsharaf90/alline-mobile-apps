import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/quick_add_to_cart_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_tokens.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';

/// Dense but calm grocery card for quick supermarket browsing.
class SupermarketProductCard extends StatelessWidget {
  final Product product;
  final double? margin;
  final Future<void> Function()? onAdd;

  const SupermarketProductCard({
    super.key,
    required this.product,
    this.margin,
    this.onAdd,
  });

  bool get hasDiscount =>
      (product.discount ?? 0) > 0 ||
      (product.clearanceSale?.discountAmount ?? 0) > 0;

  double? get discountAmount => (product.clearanceSale?.discountAmount ?? 0) > 0
      ? product.clearanceSale?.discountAmount
      : product.discount;

  String? get discountType => (product.clearanceSale?.discountAmount ?? 0) > 0
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
      margin: EdgeInsets.all(margin ?? 0),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AllineRadius.card),
        border: Border.all(color: colors.border),
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
              height: 104,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: colors.background,
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
                          color: colors.accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          discountType == 'percent' ||
                                  discountType == 'percentage'
                              ? '${discountAmount?.toStringAsFixed(0)}٪ خصم'
                              : 'عرض',
                          style: TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                      ),
                    ),
                  if (soldOut)
                    Positioned.fill(
                      child: Container(
                        color: colors.surface.withValues(alpha: .82),
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
                          child: Text(
                            'غير متوفر',
                            style: TextStyle(
                              fontFamily: 'AllineTajawal',
                              fontSize: 11,
                              color: colors.surface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 9, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textMedium.copyWith(
                        color: colors.textPrimary,
                        fontSize: 14,
                        height: 1.35,
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
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (hasDiscount)
                      Text(
                        oldPrice,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textRegular.copyWith(
                          color: colors.textSecondary,
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    Text(
                      price,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textBold.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: AllineSpacing.xs),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: soldOut
                          ? Text('غير متوفر',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: colors.textSecondary))
                          : QuickAddToCartWidget(
                              product: product,
                              onAdd: onAdd,
                              height: AllineTouchTarget.minimum,
                              iconSize: 20,
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
}
