import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/controllers/shop_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/domain/models/seller_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/screens/shop_screen.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class AllineStoreTabsSectionWidget extends StatefulWidget {
  const AllineStoreTabsSectionWidget({super.key});

  @override
  State<AllineStoreTabsSectionWidget> createState() => _AllineStoreTabsSectionWidgetState();
}

class _AllineStoreTabsSectionWidgetState extends State<AllineStoreTabsSectionWidget> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['الكل', 'الأقرب 📍', 'الجديدة ⭐', 'المفضلة ❤️'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tabs Header
        Container(
          height: 40,
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
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFF43F5E)
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFF43F5E)
                          : Theme.of(context).dividerColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _tabs[index],
                      style: textBold.copyWith(
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyLarge?.color,
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

        // Stores List
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
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final seller = sellers[index];
                final shop = seller.shop;

                // Mock distance calculation based on index
                final double distance = 0.5 + (index * 0.85);

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
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left: Favorite & Status Badge
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'مفتوح 🟢',
                                style: textBold.copyWith(
                                  fontSize: Dimensions.fontSizeExtraSmall,
                                  color: const Color(0xFFD97706),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Icon(
                              Icons.favorite_border_rounded,
                              size: 20,
                              color: Theme.of(context).hintColor,
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),

                        // Middle: Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                seller.shop?.name ?? shop?.name ?? 'متجر Alline المعتمد',
                                style: textBold.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                seller.shop?.address ?? shop?.address ?? 'صنعاء - الجمهورية اليمنية',
                                style: textRegular.copyWith(
                                  fontSize: Dimensions.fontSizeExtraSmall,
                                  color: Theme.of(context).hintColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'توصيل سريع ⚡',
                                          style: textMedium.copyWith(
                                            fontSize: 10,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF43F5E).withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'خصم Alline 👑',
                                      style: textMedium.copyWith(
                                        fontSize: 10,
                                        color: const Color(0xFFF43F5E),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Right: Logo + Distance
                        Column(
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  seller.shop?.imageFullUrl?.path ?? '',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(Icons.storefront_rounded, size: 28, color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${distance.toStringAsFixed(2)} كم',
                              style: textBold.copyWith(
                                fontSize: 10,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          ],
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
}
