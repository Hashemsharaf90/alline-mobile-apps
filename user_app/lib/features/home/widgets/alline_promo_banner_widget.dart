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
    {'image': Images.banner1, 'type': 'featured_offers'},
    {
      'image': Images.banner2,
      'type': 'category',
      'categoryId': 12,
      'categoryName': 'الأثاث والديكور'
    },
    {'image': Images.banner3, 'type': 'new_arrival'},
    {
      'image': Images.banner4,
      'type': 'category',
      'categoryId': 4,
      'categoryName': 'اكسسوارات البيت والمطبخ'
    },
    {
      'image': Images.banner5,
      'type': 'category',
      'categoryId': 7,
      'categoryName': 'الإلكترونيات'
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_pageController.hasClients) {
        _pageController.animateToPage((_currentPage + 1) % _slides.length,
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _openSlide(BuildContext context, Map<String, dynamic> slide) {
    if (slide['type'] == 'category') {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => BrandAndCategoryProductScreen(
                    isBrand: false,
                    id: slide['categoryId'] as int?,
                    name: slide['categoryName'] as String?,
                  )));
    } else {
      RouterHelper.getViewAllProductScreenRoute(
        productType: slide['type'] == 'new_arrival'
            ? ProductType.newArrival
            : ProductType.featuredProduct,
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
            AspectRatio(
              aspectRatio: 1672 / 941,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _openSlide(context, _slides[index]),
                      child: DecoratedBox(
                        decoration: const BoxDecoration(boxShadow: [
                          BoxShadow(
                              color: Color(0x08000000),
                              blurRadius: 12,
                              offset: Offset(0, 4)),
                        ]),
                        child: Image.asset(_slides[index]['image'] as String,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  _slides.length,
                  (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: index == _currentPage ? 22 : 7,
                        height: 7,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: index == _currentPage
                              ? const Color(0xFF015FC9)
                              : const Color(0xFFD7E1EF),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      )),
            ),
          ],
        ),
      ),
    );
  }
}
