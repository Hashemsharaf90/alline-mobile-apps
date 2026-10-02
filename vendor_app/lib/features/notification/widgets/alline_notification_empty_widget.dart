import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/notification/controllers/notification_controller.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

class AllineNotificationEmptyWidget extends StatelessWidget {
  const AllineNotificationEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = context.watch<NotificationController>();
    final isFiltered = controller.unreadFilterIndex != 0 ||
        controller.selectedCategory != 'all';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Styled Outer Glow Circle
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? AllineColors.primary.withValues(alpha: 0.15)
                    : AllineColors.softBlue,
                border: Border.all(
                  color: isDark
                      ? AllineColors.darkBorder
                      : AllineColors.border,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? AllineColors.darkCard
                        : AllineColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AllineColors.primary.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    isFiltered
                        ? Icons.filter_alt_off_outlined
                        : Icons.notifications_off_outlined,
                    size: 30,
                    color: isDark ? const Color(0xFF60A5FA) : AllineColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              isFiltered
                  ? 'لا توجد إشعارات مطابقة للتصفية'
                  : 'لا توجد إشعارات حالياً',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isDark ? AllineColors.darkText : AllineColors.navyText,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              isFiltered
                  ? 'يمكنك التبديل إلى عرض "الكل" لمشاهدة كافة تحديثات متجرك'
                  : 'سنخبرك هنا عندما يحدث شيء مهم في متجرك.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: isDark ? AllineColors.darkTextSub : AllineColors.coolGray,
                height: 1.4,
              ),
            ),

            if (isFiltered) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {
                  controller.setUnreadFilter(0);
                  controller.setSelectedCategory('all');
                },
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text(
                  'عرض جميع الإشعارات',
                  style: TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AllineColors.primary,
                  side: const BorderSide(color: AllineColors.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
