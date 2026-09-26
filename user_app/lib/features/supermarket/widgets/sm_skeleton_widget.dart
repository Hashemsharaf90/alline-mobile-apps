import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Shared shimmer primitives used across the Supermarket Hub.
// ═══════════════════════════════════════════════════════════════════════════

/// A single animated shimmer box.  Use as a placeholder for any rect element.
class SmShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const SmShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFECF1F8),
      highlightColor: const Color(0xFFF8FAFD),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFECF1F8),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// Shimmer skeleton for a store card in the Nearby Stores section.
class SmStoreCardSkeleton extends StatelessWidget {
  const SmStoreCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E8F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          Container(
            height: 100,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Shimmer.fromColors(
              baseColor: const Color(0xFFECF1F8),
              highlightColor: const Color(0xFFF8FAFD),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFECF1F8),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SmShimmerBox(width: 110, height: 12),
                const SizedBox(height: 6),
                SmShimmerBox(width: 70, height: 10),
                const SizedBox(height: 4),
                SmShimmerBox(width: 90, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer skeleton for a product card (matches SupermarketProductCard size).
class SmProductCardSkeleton extends StatelessWidget {
  const SmProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E8F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: const Color(0xFFECF1F8),
            highlightColor: const Color(0xFFF8FAFD),
            child: Container(
              height: 130,
              decoration: const BoxDecoration(
                color: Color(0xFFECF1F8),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SmShimmerBox(width: 100, height: 11),
                const SizedBox(height: 5),
                SmShimmerBox(width: 70, height: 11),
                const SizedBox(height: 6),
                SmShimmerBox(width: 120, height: 28, radius: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer skeleton for category chip.
class SmCategoryChipSkeleton extends StatelessWidget {
  const SmCategoryChipSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFECF1F8),
      highlightColor: const Color(0xFFF8FAFD),
      child: Container(
        width: 72,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFECF1F8),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

/// Horizontal list of [SmStoreCardSkeleton] — shown while stores load.
class SmNearbyStoresSkeleton extends StatelessWidget {
  const SmNearbyStoresSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 192,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => const SmStoreCardSkeleton(),
      ),
    );
  }
}

/// Horizontal list of [SmProductCardSkeleton] — shown while products load.
class SmProductListSkeleton extends StatelessWidget {
  const SmProductListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 224,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => const SmProductCardSkeleton(),
      ),
    );
  }
}