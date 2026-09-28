import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';

class AllineAuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final String? badgeText;

  const AllineAuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showBackButton = false,
    this.onBackPressed,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        if (showBackButton)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: InkWell(
              onTap: onBackPressed ?? () => Navigator.maybePop(context),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? AllineColors.darkCard : AllineColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: ColorResources.getBorder(context)),
                  boxShadow: [
                    BoxShadow(
                      color: AllineColors.primaryDark.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: ColorResources.getTextTitle(context),
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),

        // Official Alline Logo
        Center(
          child: Container(
            width: 76,
            height: 76,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? AllineColors.darkCard : AllineColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AllineColors.primary.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Image.asset(
              Images.allineLogoClean,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Image.asset(
                Images.logo,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Badge if specified
        if (badgeText != null && badgeText!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AllineColors.darkBlue, AllineColors.primary],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AllineColors.primary.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              badgeText!,
              style: const TextStyle(
                fontFamily: 'AllineTajawal',
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],

        // Title
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'AllineTajawal',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: ColorResources.getTextTitle(context),
            height: 1.25,
          ),
        ),

        const SizedBox(height: 6),

        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'AllineTajawal',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: ColorResources.getTextSubTitle(context),
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}
