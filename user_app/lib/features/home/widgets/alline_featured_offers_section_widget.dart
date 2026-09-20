import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/enums/product_type.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/screens/brand_and_category_product_screen.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';

class AllineFeaturedOffersSectionWidget extends StatefulWidget {
  const AllineFeaturedOffersSectionWidget({super.key});

  @override
  State<AllineFeaturedOffersSectionWidget> createState() =>
      _AllineFeaturedOffersSectionWidgetState();
}

class _AllineFeaturedOffersSectionWidgetState
    extends State<AllineFeaturedOffersSectionWidget> {
  final PageController _bannerController = PageController();
  int _currentBanner = 0;
  Timer? _bannerTimer;

  final List<Map<String, dynamic>> _bannerSlides = [
    {
      'image': Images.banner1,
      'type': 'featured_offers',
    },
    {
      'image': Images.banner2,
      'type': 'category',
      'categoryId': 12,
      'categoryName': 'الأثاث والديكور',
    },
    {
      'image': Images.banner3,
      'type': 'new_arrival',
    },
    {
      'image': Images.banner4,
      'type': 'category',
      'categoryId': 4,
      'categoryName': 'اكسسوارات البيت والمطبخ',
    },
    {
      'image': Images.banner5,
      'type': 'category',
      'categoryId': 7,
      'categoryName': 'الإلكترونيات',
    },
  ];

  @override
  void initState() {
    super.initState();
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_bannerController.hasClients) {
        final next = (_currentBanner + 1) % _bannerSlides.length;
        _bannerController.animateToPage(
          next,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _onBannerTap(BuildContext context, Map<String, dynamic> slide) {
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<ProductController>(
      builder: (context, productController, _) {
        final products = productController.featuredProductModel?.products ??
            productController.latestProductModel?.products ??
            [];

        if (products.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.only(top: 16, bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF1455AC), Color(0xFF2196F3)],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'عروض مميزة',
                          style: titilliumBold.copyWith(
                            fontSize: 17,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('💥', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFEE2E2), Color(0xFFFEF2F2)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'توفير رائع',
                            style: textBold.copyWith(
                              fontSize: 10,
                              color: const Color(0xFFDC2626),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        RouterHelper.getViewAllProductScreenRoute(
                          productType: ProductType.featuredProduct,
                          action: RouteAction.push,
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'عرض الكل',
                              style: textBold.copyWith(
                                fontSize: 12,
                                color: const Color(0xFF1455AC),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                size: 10, color: Color(0xFF1455AC)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ─── Products Horizontal List ───────────────────
              SizedBox(
                height: 230,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final p = products[index];
                    final imgUrl = p.thumbnailFullUrl?.path;
                    final double price = p.unitPrice ?? 0.0;
                    final double? discount = p.discount;
                    final bool hasDiscount =
                        (discount != null && discount > 0);

                    return InkWell(
                      onTap: () {
                        if (p.id != null) {
                          RouterHelper.getProductDetailsRoute(
                            productId: p.id,
                            slug: p.slug,
                            action: RouteAction.push,
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        width: 152,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                            width: 0.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withOpacity(0.3)
                                  : const Color(0xFF1455AC).withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image with Gradient Overlay
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(17)),
                                  child: Container(
                                    height: 118,
                                    width: 152,
                                    decoration: BoxDecoration(
                                      gradient: isDark
                                          ? const LinearGradient(
                                              colors: [
                                                Color(0xFF1E293B),
                                                Color(0xFF334155),
                                              ],
                                            )
                                          : const LinearGradient(
                                              colors: [
                                                Color(0xFFF8FAFC),
                                                Color(0xFFEFF6FF),
                                              ],
                                            ),
                                    ),
                                    child: (imgUrl != null &&
                                            imgUrl.isNotEmpty)
                                        ? Image.network(
                                            imgUrl,
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, __, ___) =>
                                                Center(
                                              child: Icon(
                                                Icons
                                                    .shopping_bag_outlined,
                                                color: const Color(0xFF1455AC)
                                                    .withOpacity(0.4),
                                                size: 36,
                                              ),
                                            ),
                                          )
                                        : Center(
                                            child: Icon(
                                              Icons.shopping_bag_outlined,
                                              color: const Color(0xFF1455AC)
                                                  .withOpacity(0.4),
                                              size: 36,
                                            ),
                                          ),
                                  ),
                                ),

                                // Discount Badge
                                if (hasDiscount)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFEF4444),
                                            Color(0xFFDC2626),
                                          ],
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFDC2626)
                                                .withOpacity(0.3),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        '-${discount.toInt()}%',
                                        style: textBold.copyWith(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            // Product Info
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    10, 8, 10, 8),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      p.name ?? '',
                                      style: textBold.copyWith(
                                        fontSize: 11.5,
                                        color: isDark
                                            ? const Color(0xFFF1F5F9)
                                            : const Color(0xFF1E293B),
                                        height: 1.25,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            PriceConverter.convertPrice(
                                                context, price),
                                            style:
                                                titilliumBold.copyWith(
                                              fontSize: 13.5,
                                              color: const Color(
                                                  0xFF1455AC),
                                              fontWeight: FontWeight.w900,
                                            ),
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: isDark
                                                  ? [
                                                      const Color(
                                                              0xFF1455AC)
                                                          .withOpacity(
                                                              0.25),
                                                      const Color(
                                                              0xFF1455AC)
                                                          .withOpacity(
                                                              0.15),
                                                    ]
                                                  : [
                                                      const Color(
                                                          0xFFEFF6FF),
                                                      const Color(
                                                          0xFFDBEAFE),
                                                    ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(
                                                    9),
                                          ),
                                          child: const Icon(
                                            Icons.add_rounded,
                                            size: 17,
                                            color: Color(0xFF1455AC),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
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

              const SizedBox(height: 16),

              // ─── Banner Carousel ────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    SizedBox(
                      height: (screenWidth - 32) * 0.48,
                      child: PageView.builder(
                        controller: _bannerController,
                        onPageChanged: (index) {
                          setState(() => _currentBanner = index);
                        },
                        itemCount: _bannerSlides.length,
                        itemBuilder: (context, index) {
                          final slide = _bannerSlides[index];
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(18),
                              child: InkWell(
                                onTap: () =>
                                    _onBannerTap(context, slide),
                                borderRadius: BorderRadius.circular(18),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isDark
                                            ? Colors.black
                                                .withOpacity(0.4)
                                            : const Color(0xFF1455AC)
                                                .withOpacity(0.12),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(18),
                                    child: Image.asset(
                                      slide['image'] as String,
                                      width: double.infinity,
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

                    // Animated Carousel Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _bannerSlides.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 3),
                          width: _currentBanner == index ? 22 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            gradient: _currentBanner == index
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF1455AC),
                                      Color(0xFF2196F3),
                                    ],
                                  )
                                : null,
                            color: _currentBanner != index
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
              ),
            ],
          ),
        );
      },
    );
  }
}
