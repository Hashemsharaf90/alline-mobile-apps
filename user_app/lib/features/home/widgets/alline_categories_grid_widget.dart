import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/domain/models/category_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/screens/category_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/screens/brand_and_category_product_screen.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';

class AllineCategoriesGridWidget extends StatelessWidget {
  const AllineCategoriesGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryController>(
      builder: (context, categoryController, _) {
        final categories = categoryController.categoryList;
        if (categories.isEmpty) {
          return const SizedBox.shrink();
        }

        final displayCats = _prioritizedCategories(categories).take(8).toList();

        return Container(
          color: Colors.white,
          padding:
              const EdgeInsets.only(top: 14, bottom: 10, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.dashboard_customize_rounded,
                          color: Color(0xFF2563EB),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'التصنيفات الرئيسية',
                        style: titilliumBold.copyWith(
                          fontSize: 16,
                          color: const Color(0xFF0F172A),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CategoryScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'عرض الكل',
                      style: textBold.copyWith(
                        fontSize: 12,
                        color: const Color(0xFF2563EB),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayCats.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 10,
                  childAspectRatio: .7,
                ),
                itemBuilder: (context, index) {
                  final cat = displayCats[index];
                  final visual = _visualFor(cat, index);

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BrandAndCategoryProductScreen(
                            isBrand: false,
                            id: cat.id,
                            name: cat.name,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(7, 7, 7, 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: visual.colors.first.withValues(alpha: .08),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: visual.colors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Stack(
                                children: [
                                  PositionedDirectional(
                                    end: -10,
                                    bottom: -12,
                                    child: Icon(
                                      visual.icon,
                                      size: 54,
                                      color:
                                          Colors.white.withValues(alpha: .12),
                                    ),
                                  ),
                                  Center(
                                    child: Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: .92),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        visual.icon,
                                        color: visual.accent,
                                        size: 27,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 7),
                          SizedBox(
                            height: 30,
                            child: Text(
                              cat.name ?? '',
                              style: textMedium.copyWith(
                                fontSize: 10,
                                color: const Color(0xFF1E293B),
                                fontWeight: FontWeight.w700,
                                height: 1.15,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<CategoryModel> _prioritizedCategories(List<CategoryModel> categories) {
    final indexed = categories.asMap().entries.toList();
    indexed.sort((first, second) {
      final firstScore = _priorityFor(first.value);
      final secondScore = _priorityFor(second.value);
      if (firstScore != secondScore) {
        return firstScore.compareTo(secondScore);
      }
      return first.key.compareTo(second.key);
    });
    return indexed.map((entry) => entry.value).toList();
  }

  int _priorityFor(CategoryModel category) {
    final text = _categoryText(category);
    final groups = [
      ['supermarket', 'grocery', 'سوبر', 'بقال', 'غذائ'],
      ['restaurant', 'مطعم', 'وجبات'],
      ['home', 'appliance', 'منزل', 'الصيانة', 'كهربائ'],
      ['kitchen', 'plastic', 'السفري', 'مطبخ'],
      ['baby', 'kids', 'أطفال'],
      ['electronics', 'إلكترون', 'إضاءة'],
      ['furniture', 'decor', 'أثاث', 'ديكور'],
      ['sports', 'رياضة', 'لياقة'],
      ['school', 'office', 'دراسية', 'مكتبية'],
      ['car', 'سيارات'],
    ];

    for (var i = 0; i < groups.length; i++) {
      if (groups[i].any(text.contains)) {
        return i;
      }
    }
    return groups.length;
  }

  _CategoryVisual _visualFor(CategoryModel category, int index) {
    final text = _categoryText(category);

    if (_matches(text, ['supermarket', 'grocery', 'سوبر', 'بقال', 'غذائ'])) {
      return const _CategoryVisual(
        icon: Icons.local_grocery_store_rounded,
        colors: [Color(0xFF16A34A), Color(0xFF065F46)],
        accent: Color(0xFF15803D),
      );
    }
    if (_matches(text, ['restaurant', 'مطعم', 'وجبات'])) {
      return const _CategoryVisual(
        icon: Icons.restaurant_rounded,
        colors: [Color(0xFFF97316), Color(0xFF9A3412)],
        accent: Color(0xFFEA580C),
      );
    }
    if (_matches(text, ['home', 'appliance', 'منزل', 'الصيانة', 'كهربائ'])) {
      return const _CategoryVisual(
        icon: Icons.home_repair_service_rounded,
        colors: [Color(0xFF2563EB), Color(0xFF1E3A8A)],
        accent: Color(0xFF2563EB),
      );
    }
    if (_matches(text, ['kitchen', 'plastic', 'السفري', 'مطبخ'])) {
      return const _CategoryVisual(
        icon: Icons.soup_kitchen_rounded,
        colors: [Color(0xFF0891B2), Color(0xFF155E75)],
        accent: Color(0xFF0891B2),
      );
    }
    if (_matches(text, ['baby', 'kids', 'أطفال'])) {
      return const _CategoryVisual(
        icon: Icons.child_friendly_rounded,
        colors: [Color(0xFFEC4899), Color(0xFF9D174D)],
        accent: Color(0xFFDB2777),
      );
    }
    if (_matches(text, ['electronics', 'إلكترون', 'إضاءة'])) {
      return const _CategoryVisual(
        icon: Icons.electrical_services_rounded,
        colors: [Color(0xFFFACC15), Color(0xFFCA8A04)],
        accent: Color(0xFFCA8A04),
      );
    }
    if (_matches(text, ['furniture', 'decor', 'أثاث', 'ديكور'])) {
      return const _CategoryVisual(
        icon: Icons.weekend_rounded,
        colors: [Color(0xFF14B8A6), Color(0xFF0F766E)],
        accent: Color(0xFF0D9488),
      );
    }
    if (_matches(text, ['sports', 'رياضة', 'لياقة'])) {
      return const _CategoryVisual(
        icon: Icons.fitness_center_rounded,
        colors: [Color(0xFF6366F1), Color(0xFF3730A3)],
        accent: Color(0xFF4F46E5),
      );
    }
    if (_matches(text, ['school', 'office', 'دراسية', 'مكتبية'])) {
      return const _CategoryVisual(
        icon: Icons.school_rounded,
        colors: [Color(0xFF8B5CF6), Color(0xFF5B21B6)],
        accent: Color(0xFF7C3AED),
      );
    }
    if (_matches(text, ['car', 'سيارات'])) {
      return const _CategoryVisual(
        icon: Icons.directions_car_filled_rounded,
        colors: [Color(0xFF64748B), Color(0xFF334155)],
        accent: Color(0xFF475569),
      );
    }

    final fallbacks = const [
      _CategoryVisual(
        icon: Icons.category_rounded,
        colors: [Color(0xFF0EA5E9), Color(0xFF0369A1)],
        accent: Color(0xFF0284C7),
      ),
      _CategoryVisual(
        icon: Icons.shopping_bag_rounded,
        colors: [Color(0xFF22C55E), Color(0xFF15803D)],
        accent: Color(0xFF16A34A),
      ),
      _CategoryVisual(
        icon: Icons.inventory_2_rounded,
        colors: [Color(0xFFF59E0B), Color(0xFFB45309)],
        accent: Color(0xFFD97706),
      ),
    ];
    return fallbacks[index % fallbacks.length];
  }

  String _categoryText(CategoryModel category) {
    return '${category.name ?? ''} ${category.slug ?? ''}'.toLowerCase();
  }

  bool _matches(String text, List<String> keywords) {
    return keywords.any(text.contains);
  }
}

class _CategoryVisual {
  final IconData icon;
  final List<Color> colors;
  final Color accent;

  const _CategoryVisual({
    required this.icon,
    required this.colors,
    required this.accent,
  });
}
