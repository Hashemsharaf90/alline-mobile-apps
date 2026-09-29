import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/domain/models/category_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/screens/category_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/screens/brand_and_category_product_screen.dart';
import 'package:flutter_sixvalley_ecommerce/helper/category_asset_helper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';

class AllineCategoriesGridWidget extends StatelessWidget {
  const AllineCategoriesGridWidget({super.key});

  static List<CategoryModel> get _fallbackCategories => [
        CategoryModel(id: 7, name: 'الالكترونيات'),
        CategoryModel(id: 4, name: 'مستلزمات البيت والمطبخ'),
        CategoryModel(id: 12, name: 'الاثاث والديكور'),
        CategoryModel(id: 9, name: 'الملابس والاكسسوارات'),
        CategoryModel(id: 2, name: 'العطور'),
        CategoryModel(id: 6, name: 'الاجهزة المنزلية'),
        CategoryModel(id: 1, name: 'الصحة والعناية'),
        CategoryModel(id: 11, name: 'اكسسوارات السيارات'),
        CategoryModel(id: 3, name: 'مستحضرات التجميل'),
        CategoryModel(id: 12124, name: 'الرياضة واللياقة'),
      ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLtr =
        Provider.of<LocalizationController>(context, listen: false).isLtr;

    return Consumer<CategoryController>(
      builder: (context, categoryController, _) {
        final categories = categoryController.categoryList.isNotEmpty
            ? categoryController.categoryList
            : _fallbackCategories;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isLtr ? 'Categories' : 'التصنيفات',
                      style: textBold.copyWith(
                        fontSize: 17,
                        color: isDark ? Colors.white : const Color(0xFF071B49),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CategoryScreen()),
                      ),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Row(
                          children: [
                            Text(
                              isLtr ? 'View all' : 'عرض الكل',
                              style: textBold.copyWith(
                                fontSize: 13,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(width: 2),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Horizontal Scrollable Categories
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
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFF4F5F7),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? Colors.black.withValues(alpha: .16)
                                        : Colors.black.withValues(alpha: .03),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CategoryAssetHelper
                                  .buildCircularCategoryAvatar(
                                category: category,
                                size: 63,
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
                                    color: isDark
                                        ? const Color(0xFFE2E8F0)
                                        : const Color(0xFF071B49),
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
