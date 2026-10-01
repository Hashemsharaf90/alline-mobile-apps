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
      final primary = Theme.of(context).colorScheme.primary;
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
                      width: 88,
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
                              width: 64,
                              height: 64,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colors.background,
                                borderRadius:
                                    BorderRadius.circular(AllineRadius.control),
                                border: Border.all(color: colors.border),
                              ),
                              child: Icon(_iconFor(name),
                                  color: primary, size: 28),
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

  IconData _iconFor(String name) {
    if (name.contains('خض') || name.contains('فواك')) {
      return Icons.eco_outlined;
    }
    if (name.contains('ألبان') || name.contains('حليب')) {
      return Icons.egg_outlined;
    }
    if (name.contains('مشروب') || name.contains('مياه')) {
      return Icons.local_drink_outlined;
    }
    if (name.contains('مخبوز') || name.contains('خبز')) {
      return Icons.bakery_dining_outlined;
    }
    if (name.contains('منظف')) return Icons.cleaning_services_outlined;
    if (name.contains('عناية')) return Icons.spa_outlined;
    return Icons.shopping_basket_outlined;
  }
}
