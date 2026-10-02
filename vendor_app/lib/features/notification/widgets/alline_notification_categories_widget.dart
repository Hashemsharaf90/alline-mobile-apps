import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/notification/controllers/notification_controller.dart';
import 'package:sixvalley_vendor_app/features/notification/domain/models/alline_notification_category.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

class AllineNotificationCategoriesWidget extends StatelessWidget {
  const AllineNotificationCategoriesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<NotificationController>(
      builder: (context, controller, _) {
        final selectedId = controller.selectedCategory;
        final counts = controller.categoryCounts;

        return SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 6),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: AllineNotificationCategory.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = AllineNotificationCategory.values[index];
              final isSelected = category.id == selectedId;
              final count = counts[category.id] ?? 0;

              return InkWell(
                onTap: () => controller.setSelectedCategory(category.id),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsetsDirectional.fromSTEB(10, 4, 10, 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                            ? AllineColors.primary.withValues(alpha: 0.25)
                            : AllineColors.primary)
                        : (isDark
                            ? AllineColors.darkCard
                            : AllineColors.white),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? (isDark ? AllineColors.primary : Colors.transparent)
                          : (isDark ? AllineColors.darkBorder : AllineColors.border),
                      width: 1,
                    ),
                    boxShadow: isSelected && !isDark
                        ? [
                            BoxShadow(
                              color: AllineColors.primary.withValues(alpha: 0.22),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category.icon,
                        size: 15,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? AllineColors.darkTextSub
                                : category.color),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category.label,
                        style: TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? AllineColors.darkText
                                  : AllineColors.navyText),
                        ),
                      ),
                      if (count > 0 && category != AllineNotificationCategory.all) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.25)
                                : (isDark
                                    ? AllineColors.darkSurface
                                    : AllineColors.softBlue),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontFamily: 'AllineTajawal',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                      ? AllineColors.darkTextSub
                                      : AllineColors.coolGray),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
