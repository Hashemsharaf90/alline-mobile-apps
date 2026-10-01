import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/supermarket_product_card.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/alline_state_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_section_header.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/supermarket/widgets/sm_skeleton_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';

/// A first-page discovery rail, with no unsupported sales-ranking claim.
///
/// Shows the first [_max] products from [ProductController.supermarketProductModel]
/// as a horizontal scroll. The backend does not provide supermarket ranking.
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
            color: context.allineColors.background,
            padding: const EdgeInsets.only(top: 4, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                AllineSectionHeader(
                  title: 'تسوق من السوبر ماركت',
                  subtitle: 'منتجات متاحة للتصفح',
                ),
                SizedBox(height: 14),
                SmProductListSkeleton(),
              ],
            ),
          );
        }

        final products = (model.products ?? <Product>[]).take(_max).toList();
        if (products.isEmpty) {
          return Container(
            color: context.allineColors.background,
            padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 20),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AllineSectionHeader(
                  title: 'تسوق من السوبر ماركت',
                  subtitle: 'منتجات متاحة للتصفح',
                ),
                SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: AllineEmptyState(
                    icon: Icons.shopping_basket_outlined,
                    title: 'لا توجد منتجات حالياً',
                    message: 'لم تتوفر منتجات من السوبر ماركت لعرضها الآن.',
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          color: context.allineColors.background,
          padding: const EdgeInsets.only(top: 4, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AllineSectionHeader(
                title: 'تسوق من السوبر ماركت',
                subtitle: 'منتجات متاحة للتصفح',
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 268,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => SizedBox(
                    width: 156,
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
