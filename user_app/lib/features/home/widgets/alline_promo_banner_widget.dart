import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/enums/product_type.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/screens/brand_and_category_product_screen.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';

class AllinePromoBannerWidget extends StatefulWidget {
  const AllinePromoBannerWidget({super.key});

  @override
  State<AllinePromoBannerWidget> createState() =>
      _AllinePromoBannerWidgetState();
}

class _AllinePromoBannerWidgetState extends State<AllinePromoBannerWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, dynamic>> _slides = [
    {
      'title': 'عروض مختارة لك',
      'subtitle': 'اكتشف منتجات مميزة بأسعار أفضل',
      'image': Images.banner1,
      'type': 'featured_offers',
    },
    {
      'title': 'جدّد منزلك',
      'subtitle': 'تفاصيل جميلة لمساحة أكثر أناقة',
      'image': Images.banner2,
      'type': 'category',
      'categoryId': 12,
      'categoryName': 'الأثاث والديكور',
    },
    {
      'title': 'وصل حديثًا',
      'subtitle': 'تشكيلة جديدة تستحق الاكتشاف',
      'image': Images.banner3,
      'type': 'new_arrival',
    },
    {
      'title': 'طوّر مطبخك',
      'subtitle': 'اختيارات عملية لكل يوم',
      'image': Images.banner4,
      'type': 'category',
      'categoryId': 4,
      'categoryName': 'اكسسوارات البيت والمطبخ',
    },
    {
      'title': 'تقنية أقرب إليك',
      'subtitle': 'أجهزة وإكسسوارات تلائم احتياجك',
      'image': Images.banner5,
      'type': 'category',
      'categoryId': 7,
      'categoryName': 'الإلكترونيات',
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_pageController.hasClients) return;
      _pageController.animateToPage(
        (_currentPage + 1) % _slides.length,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _openSlide(BuildContext context, Map<String, dynamic> slide) {
    switch (slide['type']) {
      case 'category':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BrandAndCategoryProductScreen(
              isBrand: false,
              id: slide['categoryId'] as int?,
              name: slide['categoryName'] as String?,
            ),
          ),
        );
        return;
      case 'new_arrival':
        RouterHelper.getViewAllProductScreenRoute(
          productType: ProductType.newArrival,
          action: RouteAction.push,
        );
        return;
      default:
        RouterHelper.getViewAllProductScreenRoute(
          productType: ProductType.featuredProduct,
          action: RouteAction.push,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ColoredBox(
      color: isDark ? const Color(0xFF0B1220) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          children: [
            SizedBox(
              height: 176,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Material(
                      color: isDark
                          ? const Color(0xFF17243B)
                          : const Color(0xFFF4F8FE),
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        onTap: () => _openSlide(context, slide),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: isDark
                                ? null
                                : [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: .03),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          slide['title'] as String,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: textBold.copyWith(
                                            fontSize: 18,
                                            height: 1.25,
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF071B49),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          slide['subtitle'] as String,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: textRegular.copyWith(
                                            fontSize: 11.5,
                                            height: 1.35,
                                            color: const Color(0xFF6D85AF),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          height: 36,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF015FC9),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'تسوق الآن',
                                            style: textBold.copyWith(
                                              fontSize: 12.5,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox.expand(
                                    child: Image.asset(
                                      slide['image'] as String,
                                      fit: BoxFit.cover,
                                      alignment: Alignment.centerRight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  width: index == _currentPage ? 22 : 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: index == _currentPage
                        ? const Color(0xFF015FC9)
                        : const Color(0xFFD7E1EF),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
