import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/domain/models/global_showcase_product_model.dart';

class GlobalCuratedProductsSection extends StatefulWidget {
  final List<GlobalShowcaseProduct> products;
  final ValueChanged<GlobalShowcaseProduct> onProductTap;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const GlobalCuratedProductsSection({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  State<GlobalCuratedProductsSection> createState() => _GlobalCuratedProductsSectionState();
}

class _GlobalCuratedProductsSectionState extends State<GlobalCuratedProductsSection> {
  final Set<String> _favoriteProductIds = {};
  static const List<String> _filters = ['الكل', 'Amazon', 'SHEIN', 'AliExpress', 'Alibaba'];

  @override
  Widget build(BuildContext context) {
    const navyColor = Color(0xFF071B49);
    const primaryBlue = Color(0xFF015FC9);
    const borderColor = Color(0xFFE1E8F2);
    const secondaryTextColor = Color(0xFF6D85AF);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Title & Sample Data Notice
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'اكتشف منتجات عالمية',
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: navyColor,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FC),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFD0E1F7)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline_rounded, size: 12, color: secondaryTextColor),
                  SizedBox(width: 4),
                  Text(
                    'بيانات نموذجية',
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Horizontal Filter Chips
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final filter = _filters[index];
              final isSelected = (filter == 'الكل' && (widget.selectedFilter == 'all' || widget.selectedFilter == 'الكل')) ||
                  (widget.selectedFilter.toLowerCase() == filter.toLowerCase());

              return InkWell(
                onTap: () {
                  final mapped = filter == 'الكل' ? 'all' : filter;
                  widget.onFilterChanged(mapped);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryBlue : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? primaryBlue : borderColor,
                      width: 1.1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: primaryBlue.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      filter,
                      style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? Colors.white : secondaryTextColor,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // Products Grid (2 columns)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.68,
          ),
          itemCount: widget.products.length,
          itemBuilder: (context, index) {
            final product = widget.products[index];
            final isFav = _favoriteProductIds.contains(product.id);

            return _CuratedProductCard(
              product: product,
              isFavorite: isFav,
              onFavoriteToggle: () {
                setState(() {
                  if (isFav) {
                    _favoriteProductIds.remove(product.id);
                  } else {
                    _favoriteProductIds.add(product.id);
                  }
                });
              },
              onTap: () => widget.onProductTap(product),
            );
          },
        ),
      ],
    );
  }
}

class _CuratedProductCard extends StatelessWidget {
  final GlobalShowcaseProduct product;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;

  const _CuratedProductCard({
    required this.product,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF015FC9);
    const borderColor = Color(0xFFE1E8F2);
    const navyColor = Color(0xFF071B49);
    const secondaryTextColor = Color(0xFF6D85AF);
    const orangeAccent = Color(0xFFEC970D);

    final isAlibaba = product.store.toLowerCase().contains('alibaba') || product.isRfq;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image with Overlays
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: const Color(0xFFF8FAFC),
                    padding: const EdgeInsets.all(8),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => Container(
                        color: const Color(0xFFF1F5F9),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: primaryBlue),
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => const Center(
                        child: Icon(Icons.image_not_supported_outlined, color: secondaryTextColor, size: 28),
                      ),
                    ),
                  ),

                  // Favorite Button
                  Positioned(
                    top: 6,
                    left: 6,
                    child: InkWell(
                      onTap: onFavoriteToggle,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 16,
                          color: isFavorite ? Colors.red : secondaryTextColor,
                        ),
                      ),
                    ),
                  ),

                  // Store Source Tag
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isAlibaba ? const Color(0xFFFFF7ED) : Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: isAlibaba ? const Color(0xFFFFEDD5) : borderColor,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: Text(
                        isAlibaba ? 'Alibaba جملة' : product.store,
                        style: TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: isAlibaba
                              ? const Color(0xFFFF5200)
                              : (product.store.toLowerCase().contains('aliexpress')
                                  ? const Color(0xFFE4271A)
                                  : navyColor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Area
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title (2 lines)
                  SizedBox(
                    height: 34,
                    child: Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: navyColor,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Divider(color: Color(0xFFF0F4FA), height: 1, thickness: 1),
                  const SizedBox(height: 5),

                  // Price
                  if (isAlibaba) ...[
                    const Text(
                      'يتطلب عرض سعر (RFQ)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: orangeAccent,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'الحد الأدنى: ${product.moq ?? 20} قطعة',
                      style: const TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 9.5,
                        color: secondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ] else ...[
                    Text(
                      'USD ${product.priceUsd.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 1),
                    const Text(
                      'قبل الشحن والرسوم',
                      style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 9.5,
                        color: secondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
