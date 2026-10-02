import 'package:flutter/material.dart';
import 'package:sixvalley_delivery_boy/theme/alline/alline_colors.dart';
import 'package:sixvalley_delivery_boy/theme/alline/alline_typography.dart';
import 'package:sixvalley_delivery_boy/utill/dimensions.dart';

class AllineEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const AllineEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeExtraLarge,
        horizontal: Dimensions.paddingSizeDefault,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AllineColors.primaryBlue.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: AllineColors.primaryBlue.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: AllineTypography.titleMedium
                .copyWith(color: Theme.of(context).colorScheme.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AllineTypography.body.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
