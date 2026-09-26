import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/controllers/product_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/domain/models/product_details_model.dart';
import 'package:provider/provider.dart';

/// Alline Variant Selector Widget.
///
/// Handles on-screen selection of:
/// - Colors (with visual color swatches & checkmarks)
/// - Choice Options (Sizes, Capacities, Weights)
///
/// Highlights selected options with Alline Blue tokens (#015FC9 & #F4F8FE).
class AllineVariantSelector extends StatelessWidget {
  final ProductDetailsModel? product;

  const AllineVariantSelector({super.key, required this.product});

  static const _primary = AllineColors.primary;
  static const _text = Color(0xFF071B49);
  static const _border = Color(0xFFE1E8F2);
  static const _softBlue = Color(0xFFF4F8FE);

  Color _parseHexColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return Colors.grey;
    try {
      String hex = hexString.replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (product == null) return const SizedBox.shrink();

    final colors = product?.colors ?? [];
    final choiceOptions = product?.choiceOptions ?? [];

    if (colors.isEmpty && choiceOptions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Consumer<ProductDetailsController>(
      builder: (context, details, _) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Color Selector
              if (colors.isNotEmpty) ...[
                Row(
                  children: [
                    const Text(
                      'اللون: ',
                      style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _text,
                      ),
                    ),
                    Text(
                      (details.variantIndex != null &&
                              details.variantIndex! < colors.length)
                          ? colors[details.variantIndex!].name ?? ''
                          : '',
                      style: const TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: List.generate(colors.length, (index) {
                    final colorModel = colors[index];
                    final isSelected = (details.variantIndex ?? 0) == index;
                    final color = _parseHexColor(colorModel.code);
                    final isWhite = colorModel.code?.toLowerCase().contains('fff') == true;

                    return GestureDetector(
                      onTap: () {
                        details.setCartVariantIndex(
                          details.quantity ?? product?.minimumOrderQty ?? 1,
                          index,
                          context,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? _primary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isWhite ? _border : Colors.transparent,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: isWhite ? _primary : Colors.white,
                                )
                              : null,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
              ],

              // 2. Choice Options (Size, Capacity, Weight, etc.)
              if (choiceOptions.isNotEmpty)
                ...List.generate(choiceOptions.length, (optIndex) {
                  final option = choiceOptions[optIndex];
                  final title = option.title ?? '';
                  final options = option.options ?? [];

                  final selectedIndex = (details.variationIndex != null &&
                          optIndex < details.variationIndex!.length)
                      ? details.variationIndex![optIndex]
                      : 0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '$title: ',
                            style: const TextStyle(
                              fontFamily: 'AllineTajawal',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _text,
                            ),
                          ),
                          if (selectedIndex < options.length)
                            Text(
                              options[selectedIndex],
                              style: const TextStyle(
                                fontFamily: 'AllineTajawal',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _primary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: List.generate(options.length, (subIndex) {
                          final isSelected = selectedIndex == subIndex;
                          final label = options[subIndex];

                          return GestureDetector(
                            onTap: () {
                              details.setCartVariationIndex(
                                details.quantity ?? product?.minimumOrderQty ?? 1,
                                optIndex,
                                subIndex,
                                context,
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? _softBlue : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? _primary : _border,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontFamily: 'AllineTajawal',
                                  fontSize: 13.5,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected ? _primary : _text,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 14),
                    ],
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}
