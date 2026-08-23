import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
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

        final displayCats = categories.take(8).toList();

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.only(top: 14, bottom: 8, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'التصنيفات الرئيسية 🗂️',
                    style: titilliumBold.copyWith(
                      fontSize: 16,
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CategoryScreen()),
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

              // Categories Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayCats.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.74,
                ),
                itemBuilder: (context, index) {
                  final cat = displayCats[index];
                  final imgUrl = cat.imageFullUrl?.path;

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
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon Container
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: (imgUrl != null && imgUrl.isNotEmpty)
                                ? Image.network(
                                    imgUrl,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.category_rounded,
                                      color: Color(0xFF2563EB),
                                      size: 26,
                                    ),
                                  )
                                : const Icon(
                                    Icons.category_rounded,
                                    color: Color(0xFF2563EB),
                                    size: 26,
                                  ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Category Name (Clean 2 lines max, no ugly cut)
                        Flexible(
                          child: Text(
                            cat.name ?? '',
                            style: textMedium.copyWith(
                              fontSize: 10.5,
                              color: const Color(0xFF1E293B),
                              fontWeight: FontWeight.w600,
                              height: 1.15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
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
}
