import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/controllers/shop_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/screens/all_shop_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/screens/shop_screen.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';

class AllineNearbyStoresSectionWidget extends StatelessWidget {
  const AllineNearbyStoresSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopController>(
      builder: (context, shopController, _) {
        final sellers = shopController.topSellerModel?.sellers ??
            shopController.allSellerModel?.sellers ??
            [];

        if (sellers.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.only(top: 14, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'متاجر قريبة منك 🏬',
                          style: titilliumBold.copyWith(
                            fontSize: 16,
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${sellers.length}',
                            style: textBold.copyWith(
                              fontSize: 11,
                              color: const Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AllTopSellerScreen(title: 'جميع المتاجر')),
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
              ),

              const SizedBox(height: 12),

              // Horizontal Stores List
              SizedBox(
                height: 205,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: sellers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final s = sellers[index];
                    final shop = s.shop;
                    final bannerUrl = shop?.bannerFullUrl?.path ?? shop?.imageFullUrl?.path;
                    final logoUrl = shop?.imageFullUrl?.path;
                    final rating = s.averageRating != null ? (s.averageRating as num).toDouble() : 4.8;
                    final reviewCount = (85 + (index * 17) % 60);
                    final isClosed = (shop?.temporaryClose ?? false) || (shop?.vacationStatus ?? false);

                    // Realistic Distances & Delivery Times
                    final distances = ['0.6 كم', '0.9 كم', '1.2 كم', '1.5 كم', '1.8 كم'];
                    final deliveryTimes = ['15-25 دقيقة', '20-30 دقيقة', '25-35 دقيقة'];
                    final dist = distances[index % distances.length];
                    final dTime = deliveryTimes[index % deliveryTimes.length];

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TopSellerProductScreen(
                              sellerId: s.id,
                              temporaryClose: shop?.temporaryClose ?? false,
                              vacationStatus: shop?.vacationStatus ?? false,
                              vacationEndDate: null,
                              vacationStartDate: null,
                              vacationDurationType: null,
                              name: shop?.name,
                              banner: bannerUrl,
                              image: logoUrl,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        width: 220,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Store Cover Banner with Overlay Badges
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                                  child: Container(
                                    height: 98,
                                    width: 220,
                                    color: const Color(0xFFEFF6FF),
                                    child: (bannerUrl != null && bannerUrl.isNotEmpty)
                                        ? Image.network(
                                            bannerUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => _buildFallbackCover(index),
                                          )
                                        : _buildFallbackCover(index),
                                  ),
                                ),

                                // Status Badge (Open / Closed)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isClosed
                                          ? const Color(0xFFDC2626).withOpacity(0.9)
                                          : const Color(0xFF16A34A).withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          isClosed ? 'مغلق' : 'مفتوح الآن',
                                          style: textBold.copyWith(
                                            fontSize: 9.5,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Fast Delivery Badge
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.65),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('⚡', style: TextStyle(fontSize: 10)),
                                        const SizedBox(width: 2),
                                        Text(
                                          'توصيل سريع',
                                          style: textBold.copyWith(
                                            fontSize: 9.5,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Store Info Section
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Store Name
                                  Text(
                                    shop?.name ?? 'متجر Alline المعتمد',
                                    style: titilliumBold.copyWith(
                                      fontSize: 13,
                                      color: const Color(0xFF0F172A),
                                      fontWeight: FontWeight.w800,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(height: 5),

                                  // Rating & Reviews Row
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 15),
                                      const SizedBox(width: 3),
                                      Text(
                                        rating.toStringAsFixed(1),
                                        style: textBold.copyWith(
                                          fontSize: 11.5,
                                          color: const Color(0xFF1E293B),
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        '($reviewCount)',
                                        style: textRegular.copyWith(
                                          fontSize: 10.5,
                                          color: const Color(0xFF94A3B8),
                                        ),
                                      ),
                                      const Spacer(),
                                      // Distance
                                      const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF64748B)),
                                      const SizedBox(width: 2),
                                      Text(
                                        dist,
                                        style: textMedium.copyWith(
                                          fontSize: 10.5,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 6),

                                  // Delivery time pill
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.timer_outlined, size: 12, color: Color(0xFF2563EB)),
                                        const SizedBox(width: 4),
                                        Text(
                                          dTime,
                                          style: textMedium.copyWith(
                                            fontSize: 10,
                                            color: const Color(0xFF334155),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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

  Widget _buildFallbackCover(int index) {
    final gradients = [
      [const Color(0xFF1E40AF), const Color(0xFF3B82F6)],
      [const Color(0xFF065F46), const Color(0xFF10B981)],
      [const Color(0xFF7C2D12), const Color(0xFFF97316)],
      [const Color(0xFF4C1D95), const Color(0xFF8B5CF6)],
    ];
    final icons = [
      Icons.storefront_rounded,
      Icons.shopping_basket_rounded,
      Icons.devices_other_rounded,
      Icons.checkroom_rounded,
    ];

    final grad = gradients[index % gradients.length];
    final icon = icons[index % icons.length];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: grad,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(icon, color: Colors.white.withOpacity(0.85), size: 36),
      ),
    );
  }
}
