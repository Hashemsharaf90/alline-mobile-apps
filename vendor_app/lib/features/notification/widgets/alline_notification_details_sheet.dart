import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sixvalley_vendor_app/features/notification/domain/models/alline_notification_category.dart';
import 'package:sixvalley_vendor_app/features/notification/domain/models/notification_model.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

class AllineNotificationDetailsSheet extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback? onNavigate;
  final String? actionLabel;

  const AllineNotificationDetailsSheet({
    super.key,
    required this.item,
    this.onNavigate,
    this.actionLabel,
  });

  static Future<void> show(
    BuildContext context, {
    required NotificationItem item,
    VoidCallback? onNavigate,
    String? actionLabel,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AllineNotificationDetailsSheet(
        item: item,
        onNavigate: onNavigate,
        actionLabel: actionLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final category = AllineNotificationCategory.detect(item);
    final relativeTime = AllineNotificationCategory.formatRelativeTime(item.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AllineColors.darkCard : AllineColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: isDark ? AllineColors.darkBorder : AllineColors.border,
          width: 1,
        ),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? AllineColors.darkBorder
                      : AllineColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Top Row: Category Pill & Close Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: category.color.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(category.icon, size: 14, color: category.color),
                      const SizedBox(width: 5),
                      Text(
                        category.label,
                        style: TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: category.color,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: isDark ? AllineColors.darkTextSub : AllineColors.coolGray,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Notification Title
            Text(
              item.title ?? 'تفاصيل الإشعار',
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AllineColors.darkText : AllineColors.navyText,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),

            // Relative Timestamp
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: isDark ? AllineColors.darkTextSub : AllineColors.coolGray,
                ),
                const SizedBox(width: 4),
                Text(
                  relativeTime,
                  style: TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AllineColors.darkTextSub : AllineColors.coolGray,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description Body Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AllineColors.darkSurface : AllineColors.softBlue,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AllineColors.darkBorder : AllineColors.border,
                  width: 1,
                ),
              ),
              child: Text(
                (item.description != null && item.description!.isNotEmpty)
                    ? item.description!
                    : (item.title ?? ''),
                style: TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: isDark ? AllineColors.darkText : AllineColors.navyText,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Actions Row
            Row(
              children: [
                // Copy Text Button
                Expanded(
                  flex: onNavigate != null ? 1 : 2,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final copyContent = '${item.title ?? ''}\n${item.description ?? ''}';
                      Clipboard.setData(ClipboardData(text: copyContent));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'تم نسخ نص الإشعار',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontFamily: 'AllineTajawal',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text(
                      'نسخ',
                      style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: isDark ? AllineColors.darkText : AllineColors.navyText,
                      side: BorderSide(
                        color: isDark ? AllineColors.darkBorder : AllineColors.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                if (onNavigate != null) ...[
                  const SizedBox(width: 12),
                  // Deep Link Action Button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onNavigate!();
                      },
                      icon: const Icon(Icons.arrow_back_rounded, size: 16),
                      label: Text(
                        actionLabel ?? 'الانتقال للقسم',
                        style: const TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: AllineColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
