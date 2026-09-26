import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';

class CartPageShimmerWidget extends StatelessWidget {
  const CartPageShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AllineThemeColors.of(context);
    return Shimmer.fromColors(
      baseColor: colors.skeletonBase,
      highlightColor: colors.skeletonHighlight,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => const _CartShimmerCard(),
      ),
    );
  }
}

class _CartShimmerCard extends StatelessWidget {
  const _CartShimmerCard();

  @override
  Widget build(BuildContext context) {
    final colors = AllineThemeColors.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(children: [
        const Row(children: [
          _ShimmerBox(width: 26, height: 26, radius: 8),
          SizedBox(width: 10),
          _ShimmerBox(width: 116, height: 16, radius: 6),
        ]),
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const _ShimmerBox(width: 84, height: 84, radius: 12),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(width: double.infinity, height: 16, radius: 6),
                SizedBox(height: 8),
                _ShimmerBox(width: 150, height: 14, radius: 6),
                SizedBox(height: 16),
                _ShimmerBox(width: 92, height: 18, radius: 6),
              ],
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Divider(height: 1, color: colors.border),
        const SizedBox(height: 10),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ShimmerBox(width: 62, height: 34, radius: 10),
            _ShimmerBox(width: 126, height: 40, radius: 12),
          ],
        ),
      ]),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AllineThemeColors.of(context).surface,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}
