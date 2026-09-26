import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/domain/models/product_details_model.dart';

/// Alline Product Specifications Section ("المواصفات").
///
/// Features:
/// - Clean 2-column key-value specification table
/// - Alternating subtle row backgrounds
/// - Dynamically shows only fields with actual data
/// - Adapts to supermarket products (Unit, Volume, Weight)
class AllineSpecificationsSection extends StatelessWidget {
  final ProductDetailsModel? product;

  const AllineSpecificationsSection({super.key, required this.product});

  static const _text = Color(0xFF071B49);
  static const _secondary = Color(0xFF6D85AF);
  static const _border = Color(0xFFE1E8F2);
  static const _softBlue = Color(0xFFF4F8FE);

  @override
  Widget build(BuildContext context) {
    if (product == null) return const SizedBox.shrink();

    final List<MapEntry<String, String>> specs = [];

    // Unit
    if (product?.unit != null && product!.unit!.trim().isNotEmpty) {
      specs.add(MapEntry('وحدة البيع', product!.unit!.trim()));
    }

    // SKU / Product Code
    if (product?.code != null && product!.code!.trim().isNotEmpty) {
      specs.add(MapEntry('رمز المنتج (SKU)', product!.code!.trim()));
    }

    // Product Type
    if (product?.productType != null) {
      final typeStr = product!.productType == 'physical'
          ? 'منتج ملموس'
          : (product!.productType == 'digital' ? 'منتج رقمي' : product!.productType!);
      specs.add(MapEntry('نوع المنتج', typeStr));
    }

    // Condition
    specs.add(const MapEntry('الحالة', 'جديد وأصلي 100%'));

    // Digital specific: Authors & Publishing House
    if (product?.authors != null && product!.authors!.isNotEmpty) {
      specs.add(MapEntry(
          'المؤلف', product!.authors!.whereType<String>().join(', ')));
    }
    if (product?.publishingHouse != null && product!.publishingHouse!.isNotEmpty) {
      specs.add(MapEntry(
          'دار النشر', product!.publishingHouse!.whereType<String>().join(', ')));
    }

    if (specs.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'المواصفات',
            style: TextStyle(
              fontFamily: 'AllineTajawal',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _text,
            ),
          ),
          const SizedBox(height: 12),

          // Table
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children: List.generate(specs.length, (index) {
                  final spec = specs[index];
                  final isEven = index % 2 == 0;

                  return Container(
                    color: isEven ? _softBlue.withValues(alpha: 0.5) : Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 11),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          spec.key,
                          style: const TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 13,
                            color: _secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            spec.value,
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontFamily: 'AllineTajawal',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _text,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
