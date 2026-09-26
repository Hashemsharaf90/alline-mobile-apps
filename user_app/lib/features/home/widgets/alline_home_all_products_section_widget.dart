import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_product_card.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_section_header.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';
import 'package:provider/provider.dart';

class AllineHomeAllProductsSectionWidget extends StatelessWidget {
  const AllineHomeAllProductsSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 16, bottom: 12),
            child: AllineSectionHeader(title: 'جميع المنتجات'),
          ),
        ),
        Consumer<ProductController>(
          builder: (context, productController, _) {
            final model = productController.homeAllProductModel;
            final products = model?.products ?? [];
            final isLoading =
                productController.isHomeAllProductLoading && products.isEmpty;

            if (isLoading) {
              return const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: .52,
                  ),
                  delegate: SliverChildListDelegate.fixed([
                    AllineProductCardSkeleton(),
                    AllineProductCardSkeleton(),
                    AllineProductCardSkeleton(),
                    AllineProductCardSkeleton(),
                  ]),
                ),
              );
            }

            if (products.isEmpty) {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'لا توجد منتجات حالياً',
                      style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: .52,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) =>
                    AllineProductCard(product: products[index]),
              ),
            );
          },
        ),
        Consumer<ProductController>(
          builder: (context, productController, _) {
            final model = productController.homeAllProductModel;
            final products = model?.products ?? [];
            final isLoadingMore = productController.isHomeAllProductLoadingMore;
            final totalSize = model?.totalSize;
            final hasMore = totalSize == null || products.length < totalSize;

            if (isLoadingMore) {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
                ),
              );
            }

            if (productController.hasHomeAllProductError) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: TextButton.icon(
                      onPressed: () {
                        productController.getHomeAllProductList(
                          (model?.offset ?? 1) + 1,
                        );
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text(
                        'إعادة المحاولة',
                        style: TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: context.allineColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }

            if (products.isNotEmpty && !hasMore) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Center(
                    child: Text(
                      'تم عرض جميع المنتجات',
                      style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 13,
                        color: context.allineColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }

            return const SliverToBoxAdapter(child: SizedBox.shrink());
          },
        ),
      ],
    );
  }
}
