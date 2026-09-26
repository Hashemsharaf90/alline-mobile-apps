import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_product_card.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:provider/provider.dart';

/// Alline Related Products Section ("قد يعجبك أيضًا").
///
/// Features:
/// - Section title
/// - Horizontal product carousel
/// - Strictly reuses the standard AllineProductCard for 100% visual consistency
class AllineRelatedProducts extends StatelessWidget {
  const AllineRelatedProducts({super.key});

  static const _text = Color(0xFF071B49);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, productCtrl, _) {
        final products = productCtrl.relatedProductList;

        if (products == null || products.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'قد يعجبك أيضًا',
                  style: TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _text,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 275,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = products[index];
                    return SizedBox(
                      width: 170,
                      child: AllineProductCard(product: item),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
