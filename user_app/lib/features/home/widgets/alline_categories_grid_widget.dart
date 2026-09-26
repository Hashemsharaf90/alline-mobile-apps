import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/screens/category_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/screens/brand_and_category_product_screen.dart';
import 'package:flutter_sixvalley_ecommerce/helper/category_asset_helper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';

class AllineCategoriesGridWidget extends StatelessWidget {
  const AllineCategoriesGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.allineColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLtr =
        Provider.of<LocalizationController>(context, listen: false).isLtr;

    return Consumer<CategoryController>(
      builder: (context, categoryController, _) {
        final categories = categoryController.categoryList;

        if (categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          color: colors.surface,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isLtr ? 'Categories' : 'التصنيفات السريعة',
                      style: textBold.copyWith(
                        fontSize: 17,
                        color: colors.textPrimary,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CategoryScreen(),
                        ),
                      ),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          isLtr ? 'View all' : 'عرض الكل',
                          style: textBold.copyWith(
                            fontSize: 13,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 116,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final category = categories[index];

                    return SizedBox(
                      width: 72,
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BrandAndCategoryProductScreen(
                              isBrand: false,
                              id: category.id,
                              name: category.name,
                            ),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? colors.surfaceElevated
                                    : colors.background,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: isDark ? .16 : .03,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child:
                                  CategoryAssetHelper.buildContainedCategoryArtwork(
                                category: category,
                                size: 54,
                              ),
                            ),
                            const SizedBox(height: 7),
                            SizedBox(
                              height: 34,
                              child: Center(
                                child: Text(
                                  category.name ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: textMedium.copyWith(
                                    fontSize: 11.5,
                                    color: colors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    height: 1.18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
