import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/supermarket_product_card.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_section_header.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:provider/provider.dart';

/// "احتياجاتك اليومية" section — 2-column product grid.
///
/// Displays all [ProductController.supermarketProductModel] products (skips the
/// first [_skip] that appear in the Popular section so there is no repetition).
class SmEssentialsWidget extends StatelessWidget {
  const SmEssentialsWidget({super.key});

  /// Number of products already shown in the "الأكثر طلبًا" section.
  static const _skip = 8;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, ctrl, _) {
        final model = ctrl.supermarketProductModel;
        if (model == null) return const SizedBox.shrink();

        final all = model.products ?? <Product>[];
        final products =
            all.length > _skip ? all.sublist(_skip) : <Product>[];

        if (products.isEmpty) return const SizedBox.shrink();

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.only(top: 4, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AllineSectionHeader(
                title: '\u0627\u062d\u062a\u064a\u0627\u062c\u0627\u062a\u0643 \u0627\u0644\u064a\u0648\u0645\u064a\u0629',
                subtitle: '\u0643\u0644 \u0645\u0627 \u062a\u062d\u062a\u0627\u062c\u0647 \u064a\u0648\u0645\u064a\u064b\u0627 \u0641\u064a \u0645\u0643\u0627\u0646 \u0648\u0627\u062d\u062f',
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.68,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) =>
                      SupermarketProductCard(product: products[index]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}