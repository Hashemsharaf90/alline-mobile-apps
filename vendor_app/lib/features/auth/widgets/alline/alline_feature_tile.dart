import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

class AllineFeatureTile extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final Color? iconBgColor;

  const AllineFeatureTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AllineColors.darkCard : AllineColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorResources.getBorder(context)),
        boxShadow: [
          BoxShadow(
            color: AllineColors.primaryDark.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBgColor ?? AllineColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: icon,
          ),
          const SizedBox(width: 12),

          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: ColorResources.getTextTitle(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: ColorResources.getTextSubTitle(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
