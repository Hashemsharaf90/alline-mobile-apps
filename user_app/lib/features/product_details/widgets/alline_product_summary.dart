import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/controllers/product_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/domain/models/product_details_model.dart';
import 'package:provider/provider.dart';

/// Alline Product Summary Widget.
///
/// Displays:
/// - Product Name (20–22px Bold, Alline primary text)
/// - Real rating with stars & review count (or "لا توجد تقييمات بعد" — no fake stars)
/// - Completed orders & wishlist count pills
class AllineProductSummary extends StatelessWidget {
  final ProductDetailsModel? product;

  const AllineProductSummary({super.key, required this.product});

  static const _text = Color(0xFF071B49);
  static const _secondary = Color(0xFF6D85AF);
  static const _orange = AllineColors.accent;
  static const _softBlue = Color(0xFFF4F8FE);

  @override
  Widget build(BuildContext context) {
    if (product == null) return const SizedBox.shrink();

    final avgRating = double.tryParse(product?.averageReview ?? '0') ?? 0.0;
    final reviewsCount = product?.reviewsCount ?? 0;
    final hasReviews = avgRating > 0 && reviewsCount > 0;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name
          Text(
            product?.name?.trim() ?? '',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'AllineTajawal',
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: _text,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),

          // Rating Row & Meta Badges
          Consumer<ProductDetailsController>(
            builder: (context, details, _) {
              return Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  // Real rating or empty rating notice
                  if (hasReviews)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            color: _orange, size: 19),
                        const SizedBox(width: 4),
                        Text(
                          avgRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _text,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '($reviewsCount تقييم)',
                          style: const TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 13,
                            color: _secondary,
                          ),
                        ),
                      ],
                    )
                  else
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_outline_rounded,
                            color: _secondary, size: 17),
                        SizedBox(width: 4),
                        Text(
                          'لا توجد تقييمات بعد',
                          style: TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 12.5,
                            color: _secondary,
                          ),
                        ),
                      ],
                    ),

                  // Order count pill if > 0
                  if ((details.orderCount ?? 0) > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _softBlue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${details.orderCount} طلب',
                        style: const TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 12,
                          color: _secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  // Wishlist count pill if > 0
                  if ((details.wishCount ?? 0) > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _softBlue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${details.wishCount} في المفضلة',
                        style: const TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 12,
                          color: _secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
