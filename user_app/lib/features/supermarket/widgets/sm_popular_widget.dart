import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/supermarket_product_card.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_section_header.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/supermarket/widgets/sm_skeleton_widget.dart';
import 'package:provider/provider.dart';

/// "الأكثر طلبًا" section.
///
/// Shows the first [_max] products from [ProductController.supermarketProductModel]
/// as a horizontal scroll (acts as "popular / featured" since backend does not
/// have a separate popularity sort for the supermarket module yet).
class SmPopularWidget extends StatelessWidget {
  const SmPopularWidget({super.key});

  static const _max = 8;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, ctrl, _) {
        final model = ctrl.supermarketProductModel;

        if (model == null) {
          return Container(
            color: const Color(0xFFF4F8FE),
            padding: const EdgeInsets.only(top: 4, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                AllineSectionHeader(
                  title: '\u0627\u0644\u0623\u0643\u062b\u0631 \u0637\u0644\u0628\u064b\u0627',
                  subtitle: '\u0645\u0646\u062a\u062c\u0627\u062a \u064a\u0637\u0644\u0628\u0647\u0627 \u0627\u0644\u0639\u0645\u0644\u0627\u0621 \u0643\u062b\u064a\u0631\u064b\u0627',
                ),
                SizedBox(height: 14),
                SmProductListSkeleton(),
              ],
            ),
          );
        }

        final products = (model.products ?? <Product>[]).take(_max).toList();
        if (products.isEmpty) return const SizedBox.shrink();

        return Container(
          color: const Color(0xFFF4F8FE),
          padding: const EdgeInsets.only(top: 4, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AllineSectionHeader(
                title: '\u0627\u0644\u0623\u0643\u062b\u0631 \u0637\u0644\u0628\u064b\u0627',
                subtitle: '\u0645\u0646\u062a\u062c\u0627\u062a \u064a\u0637\u0644\u0628\u0647\u0627 \u0627\u0644\u0639\u0645\u0644\u0627\u0621 \u0643\u062b\u064a\u0631\u064b\u0627',
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 252,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => SizedBox(
                    width: 150,
                    child: SupermarketProductCard(
                      product: products[index],
                      margin: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
