import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart' show Variation;
import 'package:flutter_sixvalley_ecommerce/features/product_details/controllers/product_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/domain/models/product_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:provider/provider.dart';

/// Alline Price Section.
///
/// Features:
/// - Prominent active price (24–26px Bold Alline Blue)
/// - Original price with strikethrough
/// - Orange savings badge
/// - Unit/volume tag for supermarket products (e.g., لكل 1.5 لتر)
/// - Reactive price updates based on selected variant
class AllinePriceSection extends StatelessWidget {
  final ProductDetailsModel? product;

  const AllinePriceSection({super.key, required this.product});

  static const _primary = AllineColors.primary;
  static const _secondary = Color(0xFF6D85AF);
  static const _orange = AllineColors.accent;

  @override
  Widget build(BuildContext context) {
    if (product == null) return const SizedBox.shrink();

    return Consumer<ProductDetailsController>(
      builder: (context, details, _) {
        // Resolve active variant unit price
        double? unitPrice = product?.unitPrice;

        if (product?.variation != null && product!.variation!.isNotEmpty) {
          String? variantName = (product?.colors != null &&
                  product!.colors!.isNotEmpty &&
                  (details.variantIndex ?? 0) < product!.colors!.length)
              ? product!.colors![details.variantIndex ?? 0].name
              : null;

          List<String> variationList = [];
          for (int i = 0; i < (product?.choiceOptions?.length ?? 0); i++) {
            int optIndex = (details.variationIndex != null &&
                    i < details.variationIndex!.length)
                ? details.variationIndex![i]
                : 0;
            if (optIndex < (product!.choiceOptions![i].options?.length ?? 0)) {
              variationList.add(product!.choiceOptions![i].options![optIndex].trim());
            }
          }

          String variationType = '';
          if (variantName != null) {
            variationType = variantName;
            for (var v in variationList) {
              variationType = '$variationType-$v';
            }
          } else {
            bool isFirst = true;
            for (var v in variationList) {
              if (isFirst) {
                variationType = v;
                isFirst = false;
              } else {
                variationType = '$variationType-$v';
              }
            }
          }
          variationType = variationType.replaceAll(' ', '');

          for (Variation v in product!.variation!) {
            if (v.type == variationType) {
              unitPrice = v.price;
              break;
            }
          }
        }

        // Discount calculation
        final double? discount = (product?.clearanceSale?.discountAmount ?? 0) > 0
            ? product?.clearanceSale?.discountAmount
            : product?.discount;
        final String? discountType =
            (product?.clearanceSale?.discountAmount ?? 0) > 0
                ? product?.clearanceSale?.discountType
                : product?.discountType;

        final double discountedPrice = PriceConverter.convertWithDiscount(
              context,
              unitPrice,
              discount,
              discountType,
            ) ??
            (unitPrice ?? 0);

        final bool hasDiscount = (discount != null && discount > 0) &&
            discountedPrice < (unitPrice ?? 0);

        final String unit = product?.unit?.trim() ?? '';

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // Active (Discounted) Price
              Text(
                PriceConverter.convertPrice(context, discountedPrice),
                style: const TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: _primary,
                  height: 1.1,
                ),
              ),

              // Unit indicator (if supermarket / grocery)
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  '/ $unit',
                  style: const TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _secondary,
                  ),
                ),
              ],

              // Original strikethrough price
              if (hasDiscount) ...[
                const SizedBox(width: 10),
                Text(
                  PriceConverter.convertPrice(context, unitPrice),
                  style: const TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 15,
                    color: _secondary,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: _secondary,
                  ),
                ),
                const SizedBox(width: 8),

                // Discount % or savings badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: _orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    PriceConverter.percentageCalculation(
                      context,
                      unitPrice,
                      discount,
                      discountType,
                    ),
                    style: const TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _orange,
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
}
