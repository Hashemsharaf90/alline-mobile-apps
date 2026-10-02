import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/notification/controllers/notification_controller.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

class AllineNotificationSummaryWidget extends StatelessWidget {
  const AllineNotificationSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<NotificationController>(
      builder: (context, controller, _) {
        final unreadCount = controller.unreadCount;
        final selectedIndex = controller.unreadFilterIndex;

        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Summary Badge / Text
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: unreadCount > 0
                          ? AllineColors.primary
                          : (isDark
                              ? AllineColors.darkTextSub
                              : AllineColors.coolGray),
                      boxShadow: unreadCount > 0
                          ? [
                              BoxShadow(
                                color: AllineColors.primary
                                    .withValues(alpha: 0.4),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    unreadCount > 0
                        ? '$unreadCount إشعاراً جديداً'
                        : 'جميع الإشعارات مقروءة',
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: unreadCount > 0
                          ? (isDark
                              ? const Color(0xFF60A5FA)
                              : AllineColors.primaryDark)
                          : (isDark
                              ? AllineColors.darkTextSub
                              : AllineColors.coolGray),
                    ),
                  ),
                ],
              ),

              // Segmented Filter Pills (الكل | غير مقروء)
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isDark
                      ? AllineColors.darkSurface
                      : const Color(0xFFE9F0FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AllineColors.darkBorder
                        : AllineColors.border,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _FilterTab(
                      label: 'الكل',
                      isSelected: selectedIndex == 0,
                      isDark: isDark,
                      onTap: () => controller.setUnreadFilter(0),
                    ),
                    const SizedBox(width: 2),
                    _FilterTab(
                      label: 'غير مقروء',
                      badgeCount: unreadCount > 0 ? unreadCount : null,
                      isSelected: selectedIndex == 1,
                      isDark: isDark,
                      onTap: () => controller.setUnreadFilter(1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final int? badgeCount;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    this.badgeCount,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AllineColors.darkCard : AllineColors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? AllineColors.darkText : AllineColors.navyText)
                    : (isDark ? AllineColors.darkTextSub : AllineColors.coolGray),
              ),
            ),
            if (badgeCount != null) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AllineColors.primary
                      : AllineColors.coolGray.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeCount! > 99 ? '99+' : '$badgeCount',
                  style: const TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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
