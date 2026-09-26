import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart' show Variation;
import 'package:flutter_sixvalley_ecommerce/features/product_details/controllers/product_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/domain/models/product_details_model.dart';
import 'package:provider/provider.dart';

/// Alline Quantity Selector Widget.
///
/// Features:
/// - Rounded stepper [ − ] 1 [ + ]
/// - Enforces `minimumOrderQty` and active `stock` bounds
/// - Light disabled state when at minimum or maximum
/// - Haptic feedback on tap
class AllineQuantitySelector extends StatelessWidget {
  final ProductDetailsModel? product;

  const AllineQuantitySelector({super.key, required this.product});

  static const _primary = AllineColors.primary;
  static const _text = Color(0xFF071B49);
  static const _secondary = Color(0xFF6D85AF);
  static const _border = Color(0xFFE1E8F2);
  static const _softBlue = Color(0xFFF4F8FE);

  @override
  Widget build(BuildContext context) {
    if (product == null) return const SizedBox.shrink();

    return Consumer<ProductDetailsController>(
      builder: (context, details, _) {
        final minQty = product?.minimumOrderQty ?? 1;

        // Resolve active stock
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

        final currentQty = details.quantity ?? minQty;
        final bool canDecrease = currentQty > minQty;
        final bool canIncrease = product?.productType == 'digital' || currentQty < stock;

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Label
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الكمية',
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _text,
                    ),
                  ),
                  if (minQty > 1)
                    Text(
                      'أقل كمية للطلب: $minQty',
                      style: const TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 11.5,
                        color: _secondary,
                      ),
                    ),
                ],
              ),

              // Stepper Controls
              Container(
                decoration: BoxDecoration(
                  color: _softBlue,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Minus Button
                    _StepperButton(
                      icon: Icons.remove_rounded,
                      isEnabled: canDecrease,
                      onTap: () {
                        if (canDecrease) {
                          HapticFeedback.lightImpact();
                          details.setQuantity(currentQty - 1);
                        }
                      },
                    ),

                    // Number display
                    Container(
                      constraints: const BoxConstraints(minWidth: 42),
                      alignment: Alignment.center,
                      child: Text(
                        '$currentQty',
                        style: const TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _primary,
                        ),
                      ),
                    ),

                    // Plus Button
                    _StepperButton(
                      icon: Icons.add_rounded,
                      isEnabled: canIncrease,
                      onTap: () {
                        if (canIncrease) {
                          HapticFeedback.lightImpact();
                          details.setQuantity(currentQty + 1);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final bool isEnabled;
  final VoidCallback onTap;

  const _StepperButton({
    required this.icon,
    required this.isEnabled,
    required this.onTap,
  });

  static const _primary = AllineColors.primary;
  static const _secondary = Color(0xFF6D85AF);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 18,
            color: isEnabled ? _primary : _secondary.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
