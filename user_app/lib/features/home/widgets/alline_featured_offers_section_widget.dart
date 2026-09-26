import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/enums/product_type.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';
import 'alline_product_card.dart';
import 'alline_section_header.dart';

/// Builds the curated Home feed and avoids showing the same product in
/// adjacent shelves when the backend provides enough alternatives.
class AllineHomeProductDiscovery extends StatelessWidget {
  const AllineHomeProductDiscovery({super.key});

  @override
  Widget build(BuildContext context) => Consumer<ProductController>(
        builder: (context, controller, _) {
          final used = <String>{};
          final pickedSource = controller.featuredProductModel?.products ??
              controller.selectedProductModel?.products;
          final picked = _unique(pickedSource, used);
          final bestSelling =
              _unique(controller.homeBestSellingModel?.products, used);
          final arrivals =
              _unique(controller.latestProductModel?.products, used);
          final offers =
              _unique(controller.discountedProductModel?.products, used);

          return Column(
            children: [
              AllineProductShelf(
                title: 'مختارات لك',
                products: picked,
                type: controller.featuredProductModel?.products != null
                    ? ProductType.featuredProduct
                    : controller.productType,
              ),
              AllineProductShelf(
                title: 'الأكثر مبيعًا',
                products: bestSelling,
                type: ProductType.bestSelling,
              ),
              AllineProductShelf(
                title: 'وصل حديثًا',
                products: arrivals,
                type: ProductType.newArrival,
              ),
              AllineProductShelf(
                title: 'عروض مميزة',
                products: offers,
                type: ProductType.discountedProduct,
              ),
            ],
          );
        },
      );

  static List<Product>? _unique(List<Product>? source, Set<String> used) {
    if (source == null) return null;
    final result = <Product>[];
    for (final product in source) {
      final key = product.id != null
          ? 'id:${product.id}'
          : product.slug?.trim().isNotEmpty == true
              ? 'slug:${product.slug}'
              : 'name:${product.name?.trim()}';
      if (used.add(key)) result.add(product);
      if (result.length == 8) break;
    }
    return result;
  }
}

class AllineProductShelf extends StatelessWidget {
  final String title;
  final List<Product>? products;
  final ProductType type;

  const AllineProductShelf({
    super.key,
    required this.title,
    required this.products,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    if (products?.isEmpty == true) return const SizedBox.shrink();
    final items = products?.take(8).toList();
    final height =
        224.0 + (MediaQuery.textScalerOf(context).scale(13) - 13) * 4;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          AllineSectionHeader(
            title: title,
            onViewAll: () => RouterHelper.getViewAllProductScreenRoute(
              productType: type,
              action: RouteAction.push,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: height,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: items?.length ?? 3,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => SizedBox(
                width: 148,
                child: items == null
                    ? const _ProductSkeletonCompact()
                    : AllineProductCardCompact(product: items[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductSkeletonCompact extends StatelessWidget {
  const _ProductSkeletonCompact();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: context.allineColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.allineColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 112,
              decoration: BoxDecoration(
                color: context.allineColors.skeletonBase,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 112,
              height: 12,
              color: context.allineColors.skeletonBase,
            ),
            const SizedBox(height: 8),
            Container(
              width: 82,
              height: 12,
              color: context.allineColors.skeletonBase,
            ),
          ],
        ),
      );
}
