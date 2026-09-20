import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/enums/product_type.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/screens/brand_and_category_product_screen.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
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
      'title': 'عروض مميزة',
      'image': Images.banner1,
      'type': 'featured_offers',
    },
    {
      'title': 'جدّد منزلك',
      'image': Images.banner2,
      'type': 'category',
      'categoryId': 12,
      'categoryName': 'الأثاث والديكور',
    },
    {
      'title': 'وصل حديثاً',
      'image': Images.banner3,
      'type': 'new_arrival',
    },
    {
      'title': 'طوّر مطبخك',
      'image': Images.banner4,
      'type': 'category',
      'categoryId': 4,
      'categoryName': 'اكسسوارات البيت والمطبخ',
    },
    {
      'title': 'تقنية أقرب إليك',
      'image': Images.banner5,
      'type': 'category',
      'categoryId': 7,
      'categoryName': 'الإلكترونيات',
    },
  ];

  void _onSlideTap(BuildContext context, Map<String, dynamic> slide) {
    final type = slide['type'] as String?;
    if (type == 'category') {
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
    } else if (type == 'new_arrival') {
      RouterHelper.getViewAllProductScreenRoute(
        productType: ProductType.newArrival,
        action: RouteAction.push,
      );
    } else if (type == 'featured_offers') {
      RouterHelper.getViewAllProductScreenRoute(
        productType: ProductType.featuredProduct,
        action: RouteAction.push,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int next = (_currentPage + 1) % _slides.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screenWidth = MediaQuery.of(context).size.width;
    final bannerWidth = screenWidth - 32;
    final bannerHeight = (bannerWidth / (1672 / 941)).clamp(160.0, 220.0);

    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Column(
        children: [
          SizedBox(
            height: bannerHeight,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _slides.length,
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      onTap: () => _onSlideTap(context, slide),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.4)
                                  : const Color(0xFF1455AC)
                                      .withValues(alpha: 0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset(
                            slide['image'] as String,
                            width: bannerWidth,
                            height: bannerHeight,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // Carousel Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _slides.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentPage == index ? 22 : 7,
                height: 7,
                decoration: BoxDecoration(
                  gradient: _currentPage == index
                      ? const LinearGradient(
                          colors: [Color(0xFF1455AC), Color(0xFF2196F3)],
                        )
                      : null,
                  color: _currentPage != index
                      ? (isDark
                          ? const Color(0xFF475569)
                          : const Color(0xFFCBD5E1))
                      : null,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
