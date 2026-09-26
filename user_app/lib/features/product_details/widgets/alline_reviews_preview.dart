import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/domain/models/product_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/review/controllers/review_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/review/domain/models/review_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/review/screens/review_screen.dart';
import 'package:flutter_sixvalley_ecommerce/helper/date_converter.dart';
import 'package:provider/provider.dart';

/// Alline Reviews Preview Section.
///
/// Features:
/// - Real rating breakdown & 5-star distribution bars
/// - Previews 2-3 genuine customer reviews
/// - "عرض جميع التقييمات" action button
/// - Authentic empty state ("كن أول من يقيّم هذا المنتج" — no fake reviews)
class AllineReviewsPreview extends StatelessWidget {
  final ProductDetailsModel? product;

  const AllineReviewsPreview({super.key, required this.product});

  static const _primary = AllineColors.primary;
  static const _text = Color(0xFF071B49);
  static const _secondary = Color(0xFF6D85AF);
  static const _border = Color(0xFFE1E8F2);
  static const _orange = AllineColors.accent;
  static const _softBlue = Color(0xFFF4F8FE);

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewController>(
      builder: (context, reviewCtrl, _) {
        final reviews = reviewCtrl.reviewList ?? [];
        final totalReviews = reviewCtrl.totalReviews;
        final avgRating =
            double.tryParse(reviewCtrl.averageRating ?? product?.averageReview ?? '0') ??
                0.0;
        final bool hasReviews = totalReviews > 0 || reviews.isNotEmpty;

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'التقييمات والمراجعات',
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _text,
                    ),
                  ),
                  if (hasReviews && totalReviews > 0)
                    Text(
                      '($totalReviews تقييم)',
                      style: const TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 13,
                        color: _secondary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              if (hasReviews) ...[
                // Rating Overview & Distribution
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _softBlue,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _border),
                  ),
                  child: Row(
                    children: [
                      // Average Score Column
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            avgRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontFamily: 'AllineTajawal',
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: _text,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              5,
                              (i) => Icon(
                                i < avgRating.floor()
                                    ? Icons.star_rounded
                                    : (i < avgRating
                                        ? Icons.star_half_rounded
                                        : Icons.star_outline_rounded),
                                color: _orange,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$totalReviews تقييم',
                            style: const TextStyle(
                              fontFamily: 'AllineTajawal',
                              fontSize: 11.5,
                              color: _secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 1,
                        height: 70,
                        color: _border,
                      ),
                      const SizedBox(width: 16),

                      // Rating Breakdown Bars (5 to 1)
                      Expanded(
                        child: Column(
                          children: [5, 4, 3, 2, 1].map((stars) {
                            final count = reviewCtrl.getStarCount(stars);
                            final percent = totalReviews > 0
                                ? (count / totalReviews)
                                : 0.0;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 1.5),
                              child: Row(
                                children: [
                                  Text(
                                    '$stars★',
                                    style: const TextStyle(
                                      fontFamily: 'AllineTajawal',
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: _secondary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: LinearProgressIndicator(
                                        value: percent.clamp(0.0, 1.0),
                                        minHeight: 5,
                                        backgroundColor: _border,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                _orange),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 2–3 Recent Reviews
                ...reviews.take(3).map((review) => _ReviewItem(review: review)),

                // "عرض جميع التقييمات" Button
                if (reviews.length > 2 || totalReviews > 3) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ReviewScreen(
                              reviewList: reviews,
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _border),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'عرض جميع التقييمات ($totalReviews)',
                        style: const TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: _primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ] else ...[
                // Empty Reviews State
                Container(
                  padding: const EdgeInsets.all(18),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _softBlue,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _border),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.rate_review_outlined,
                          size: 36, color: _secondary),
                      SizedBox(height: 8),
                      Text(
                        'لا توجد تقييمات بعد',
                        style: TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _text,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'كن أول من يقيّم هذا المنتج ويشارك تجربته مع الآخرين',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 12,
                          color: _secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final ReviewModel review;

  const _ReviewItem({required this.review});

  static const _text = Color(0xFF071B49);
  static const _secondary = Color(0xFF6D85AF);
  static const _border = Color(0xFFE1E8F2);
  static const _orange = AllineColors.accent;

  @override
  Widget build(BuildContext context) {
    final name = review.customer != null
        ? '${review.customer?.fName ?? ''} ${review.customer?.lName ?? ''}'
            .trim()
        : 'عميل ألاين';

    final rating = review.rating ?? 5;
    final comment = review.comment?.trim() ?? '';
    final dateStr = review.createdAt != null
        ? DateConverter.localDateToIsoStringAMPM(
            DateTime.tryParse(review.createdAt!) ?? DateTime.now())
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name, Rating & Date
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE1E8F2),
                ),
                child: ClipOval(
                  child: CustomImageWidget(
                    image: review.customer?.imageFullUrl?.path ?? '',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isNotEmpty ? name : 'عميل ألاين',
                      style: const TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _text,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 13,
                          color: _orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (dateStr.isNotEmpty)
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 11,
                    color: _secondary,
                  ),
                ),
            ],
          ),

          // Comment
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              comment,
              style: const TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 13,
                color: _text,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
