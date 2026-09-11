import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/controllers/shop_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/domain/models/seller_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';

class AllineStoreTabsSectionWidget extends StatefulWidget {
  const AllineStoreTabsSectionWidget({super.key});

  @override
  State<AllineStoreTabsSectionWidget> createState() => _AllineStoreTabsSectionWidgetState();
}

class _AllineStoreTabsSectionWidgetState extends State<AllineStoreTabsSectionWidget> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['الكل 🔥', 'الأقرب 📍', 'الجديدة ⭐', 'المفضلة ❤️'];

  static const List<String> _realCovers = [
    Images.storeHypermarketHd,
    Images.storeFreshMarketHd,
    Images.storeBakeryHd,
    Images.storeButcheryHd,
    Images.storePharmacyHd,
    Images.storeElectronicsHd,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tabs Header
        Container(
          height: 42,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _tabs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final isSelected = _selectedTabIndex == index;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
                          )
                        : null,
                    color: isSelected ? null : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0D9488)
                          : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF0D9488).withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      _tabs[index],
                      style: textBold.copyWith(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // Hero Store Cards List
        Consumer<ShopController>(
          builder: (context, shopCtrl, _) {
            final sellers = shopCtrl.allSellerModel?.sellers ?? shopCtrl.topSellerModel?.sellers;
            if (sellers == null || sellers.isEmpty) {
              return const SizedBox();
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: sellers.length > 8 ? 8 : sellers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final seller = sellers[index];
                final shop = seller.shop;

                final double distance = 0.5 + (index * 0.85);
                final int eta = 20 + (index * 5);
                final double rating = 4.7 + ((index % 3) * 0.1);
                final fallbackCover = _realCovers[index % _realCovers.length];

                return InkWell(
                  onTap: () {
                    if (seller.id != null) {
                      RouterHelper.getTopSellerRoute(
                        action: RouteAction.push,
                        sellerId: seller.id,
                        slug: seller.shop?.slug,
                        name: seller.shop?.name,
                        banner: seller.shop?.bannerFullUrl?.path,
                        image: seller.shop?.imageFullUrl?.path,
                        temporaryClose: seller.shop?.temporaryClose,
                        vacationStatus: seller.shop?.vacationStatus,
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Store Banner Area
                        Stack(
                          children: [
                            Container(
                              height: 110,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                                child: (shop?.bannerFullUrl?.path != null &&
                                        shop!.bannerFullUrl!.path!.isNotEmpty &&
                                        !shop.bannerFullUrl!.path!.contains('placeholder'))
                                    ? Image.network(
                                        shop.bannerFullUrl!.path!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Image.asset(
                                          fallbackCover,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Image.asset(
                                        fallbackCover,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),

                            // Overlay gradient
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.65),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),

                            // Open Status Tag
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 4,
                                    ),
                                  ],
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
                                      'مفتوح 🟢',
                                      style: textBold.copyWith(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Favorite Icon
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.favorite_border_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),

                            // Store Logo overlapping banner
                            Positioned(
                              bottom: 8,
                              right: 14,
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        shop?.name ?? 'متجر Alline المعتمد',
                                        style: textBold.copyWith(
                                          color: Colors.white,
                                          fontSize: Dimensions.fontSizeLarge,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        shop?.address ?? 'صنعاء - الجمهورية اليمنية',
                                        style: textRegular.copyWith(
                                          color: Colors.white.withValues(alpha: 0.85),
                                          fontSize: Dimensions.fontSizeExtraSmall,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isDark ? const Color(0xFF475569) : Colors.white,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.2),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        shop?.imageFullUrl?.path ?? '',
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Center(
                                          child: Icon(
                                            Icons.storefront_rounded,
                                            size: 28,
                                            color: const Color(0xFF0D9488),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Bottom Metrics Pill Row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Distance Chip
                              _buildMetricChip(
                                icon: Icons.near_me_rounded,
                                label: '${distance.toStringAsFixed(2)} كم',
                                color: const Color(0xFF0284C7),
                              ),

                              // ETA Chip
                              _buildMetricChip(
                                icon: Icons.timer_outlined,
                                label: '$eta-$eta دقيقة',
                                color: const Color(0xFFE85D04),
                              ),

                              // Delivery Fee Chip
                              _buildMetricChip(
                                icon: Icons.delivery_dining_rounded,
                                label: 'توصيل سريع ⚡',
                                color: const Color(0xFF10B981),
                              ),

                              // Rating Chip
                              _buildMetricChip(
                                icon: Icons.star_rounded,
                                label: rating.toStringAsFixed(1),
                                color: const Color(0xFFF59E0B),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: textBold.copyWith(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
