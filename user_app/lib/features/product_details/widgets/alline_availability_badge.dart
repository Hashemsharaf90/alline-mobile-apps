import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart' show Variation;
import 'package:flutter_sixvalley_ecommerce/features/product_details/controllers/product_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/domain/models/product_details_model.dart';
import 'package:provider/provider.dart';

/// Alline Product Availability Status Badge.
///
/// States:
/// - In stock: ● متوفر الآن
/// - Limited stock: ● متبقي X فقط
/// - Out of stock: ● غير متوفر حاليًا
/// - Digital download: ● متوفر للتحميل الفوري
class AllineAvailabilityBadge extends StatelessWidget {
  final ProductDetailsModel? product;

  const AllineAvailabilityBadge({super.key, required this.product});

  static const _success = AllineColors.success;
  static const _orange = AllineColors.accent;
  static const _error = AllineColors.error;
  static const _primary = AllineColors.primary;

  @override
  Widget build(BuildContext context) {
    if (product == null) return const SizedBox.shrink();

    return Consumer<ProductDetailsController>(
      builder: (context, details, _) {
        if (product?.productType == 'digital') {
          return _buildStatusRow(
            dotColor: _primary,
            bgColor: _primary.withValues(alpha: 0.08),
            label: 'متوفر للتحميل الفوري',
            textColor: _primary,
          );
        }

        // Calculate variant-specific stock if applicable
        int stock = product?.currentStock ?? 0;

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
              stock = v.qty ?? 0;
              break;
            }
          }
        }

        if (stock <= 0) {
          return _buildStatusRow(
            dotColor: _error,
            bgColor: _error.withValues(alpha: 0.08),
            label: 'غير متوفر حاليًا',
            textColor: _error,
          );
        } else if (stock <= 5) {
          return _buildStatusRow(
            dotColor: _orange,
            bgColor: _orange.withValues(alpha: 0.1),
            label: 'متبقي $stock فقط في المخزون',
            textColor: _orange,
          );
        } else {
          return _buildStatusRow(
            dotColor: _success,
            bgColor: _success.withValues(alpha: 0.08),
            label: 'متوفر الآن في المخزون',
            textColor: _success,
          );
        }
      },
    );
  }

  Widget _buildStatusRow({
    required Color dotColor,
    required Color bgColor,
    required String label,
    required Color textColor,
  }) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
