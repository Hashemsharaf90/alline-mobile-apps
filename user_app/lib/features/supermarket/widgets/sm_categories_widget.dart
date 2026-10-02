import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/domain/models/category_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_section_header.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_tokens.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';
import 'package:provider/provider.dart';

/// Shows real supermarket subcategories from the existing category response.
/// An empty taxonomy stays empty rather than advertising categories with no data.
class SmCategoriesWidget extends StatelessWidget {
  final void Function(String? label)? onCategorySelected;

  const SmCategoriesWidget({super.key, this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryController>(builder: (context, controller, _) {
      CategoryModel? supermarket;
      for (final category in controller.categoryList) {
        final label =
            '${category.name ?? ''} ${category.slug ?? ''}'.toLowerCase();
        if (label.contains('سوبر') || label.contains('supermarket')) {
          supermarket = category;
          break;
        }
      }
      final categories = supermarket?.subCategories ?? <SubCategory>[];
      if (categories.isEmpty) return const SizedBox.shrink();

      final colors = context.allineColors;
      return ColoredBox(
        color: colors.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AllineSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AllineSectionHeader(title: 'التصنيفات'),
              const SizedBox(height: AllineSpacing.sm),
              SizedBox(
                height: 106,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AllineSpacing.md),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AllineSpacing.xs),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final name = category.name?.trim() ?? '';
                    return SizedBox(
                      width: 92,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AllineRadius.card),
                        onTap: category.id == null
                            ? null
                            : () {
                                onCategorySelected?.call(name);
                                RouterHelper.getBrandCategoryRoute(
                                  action: RouteAction.push,
                                  id: category.id,
                                  name: name,
                                  subCategory: category,
                                );
                              },
                        child: Column(
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colors.background,
                                border: Border.all(color: colors.border),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Image.asset(
                                  _assetFor(name),
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.contain,
                                  cacheWidth: 240,
                                  cacheHeight: 240,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.shopping_basket_outlined,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AllineSpacing.xs),
                            Text(
                              name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: colors.textPrimary),
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
        ),
      );
    });
  }

  String _assetFor(String name) {
    final normalized = name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[أإآ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');

    if (_containsAny(normalized, ['منظف', 'عنايه منزليه', 'تنظيف', 'clean'])) {
      return 'assets/images/alline/sm_cat_cleaning_home_3d.webp';
    }
    if (_containsAny(
        normalized, ['البان', 'حليب', 'اجبان', 'جبن', 'بيض', 'dairy', 'milk'])) {
      return 'assets/images/alline/sm_cat_dairy_3d.webp';
    }
    if (_containsAny(
        normalized, ['زيوت', 'سمن', 'ارز', 'سكر', 'oil', 'rice'])) {
      return 'assets/images/alline/sm_cat_oils_rice_sugar_3d.webp';
    }
    if (_containsAny(
        normalized, ['معلبات', 'بقوليات', 'تونه', 'تونة', 'canned', 'legume'])) {
      return 'assets/images/alline/sm_cat_canned_legumes_tuna_3d.webp';
    }
    if (_containsAny(
        normalized, ['مشروبات', 'عصائر', 'مياه', 'مشروب', 'juice', 'drink'])) {
      return 'assets/images/alline/sm_cat_drinks_3d.webp';
    }
    if (_containsAny(normalized, [
      'مخبوزات',
      'حلويات',
      'شوكولاته',
      'شوكولاتة',
      'خبز',
      'bakery',
      'chocolate',
    ])) {
      return 'assets/images/alline/sm_cat_bakery_sweets_chocolate_3d.webp';
    }
    if (_containsAny(normalized, [
      'خضار',
      'فواكه',
      'طازجه',
      'طازجة',
      'خضروات',
      'fruit',
      'vegetable',
    ])) {
      return 'assets/images/alline/sm_cat_fresh_produce_3d.webp';
    }
    if (_containsAny(normalized, [
      'لحوم',
      'لحم',
      'دواجن',
      'دجاج',
      'مجمدات',
      'frozen',
      'meat',
      'poultry',
    ])) {
      return 'assets/images/alline/sm_cat_meat_frozen_3d.webp';
    }
    if (_containsAny(
        normalized, ['بهارات', 'توابل', 'مكسرات', 'spice', 'seasoning', 'nuts'])) {
      return 'assets/images/alline/sm_cat_spices_nuts_3d.webp';
    }

    // General daily groceries is also the safe visual fallback for newly
    // introduced grocery labels; category IDs and navigation remain dynamic.
    return 'assets/images/alline/sm_cat_daily_groceries_3d.webp';
  }

  bool _containsAny(String value, List<String> needles) =>
      needles.any(value.contains);
}
