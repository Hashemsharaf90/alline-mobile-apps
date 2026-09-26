import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';

class AllineSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onViewAll;
  const AllineSectionHeader(
      {super.key, required this.title, this.subtitle, this.onViewAll});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: context.allineColors.textPrimary,
                      ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AllineThemeColors.of(context).textSecondary,
                          )),
                ],
              ])),
          if (onViewAll != null)
            TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsetsDirectional.only(start: 8),
                    textStyle: Theme.of(context).textTheme.labelMedium,
                    minimumSize: const Size(64, 44)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('عرض الكل'),
                    SizedBox(width: 3),
                    Icon(Icons.arrow_forward_ios_rounded, size: 13),
                  ],
                )),
        ]),
      );
}
