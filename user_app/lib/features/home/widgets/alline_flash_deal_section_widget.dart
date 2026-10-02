import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/controllers/flash_deal_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/alline_product_card.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';

class AllineFlashDealSectionWidget extends StatelessWidget {
  const AllineFlashDealSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FlashDealController>(
      builder: (context, megaDeal, child) {
        if (megaDeal.flashDeal == null || megaDeal.flashDealList.isEmpty) {
          return const SizedBox.shrink();
        }

        final duration = megaDeal.duration;
        final days = duration != null ? duration.inDays : 0;
        final hours = duration != null ? duration.inHours.remainder(24) : 0;
        final minutes = duration != null ? duration.inMinutes.remainder(60) : 0;
        final seconds = duration != null ? duration.inSeconds.remainder(60) : 0;

        final items = megaDeal.flashDealList.take(8).toList();
        final height =
            224.0 + (MediaQuery.textScalerOf(context).scale(13) - 13) * 4;
        final primary = Theme.of(context).primaryColor;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'عروض الفلاش ⚡',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.allineColors.textPrimary,
                          ),
                    ),
                    const SizedBox(width: 8),
                    if (duration != null && !duration.isNegative)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (days > 0) ...[
                            _buildTimerBox(context, days, 'ي', primary),
                            const SizedBox(width: 4),
                          ],
                          _buildTimerBox(context, hours, 'س', primary),
                          const SizedBox(width: 4),
                          _buildTimerBox(context, minutes, 'د', primary),
                          const SizedBox(width: 4),
                          _buildTimerBox(context, seconds, 'ث', primary),
                        ],
                      ),
                    const Spacer(),
                    InkWell(
                      onTap: () => RouterHelper.getFlashDealScreenViewRoute(),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'عرض الكل',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 11,
                              color: primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: height,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => SizedBox(
                    width: 148,
                    child: AllineProductCardCompact(product: items[index]),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimerBox(
      BuildContext context, int value, String unit, Color primary) {
    final str = value.toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: primary.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Text(
        '$str$unit',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: primary,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
      ),
    );
  }
}
