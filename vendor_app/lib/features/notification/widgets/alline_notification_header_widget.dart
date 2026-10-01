import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/notification/controllers/notification_controller.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

class AllineNotificationHeaderWidget extends StatelessWidget {
  final VoidCallback onOpenSettings;

  const AllineNotificationHeaderWidget({
    super.key,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: isDark ? AllineColors.darkCard : AllineColors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AllineColors.darkBorder : AllineColors.border,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (Navigator.of(context).canPop())
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AllineColors.darkSurface
                              : AllineColors.softBlue,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? AllineColors.darkBorder
                                : AllineColors.border,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: isDark
                              ? AllineColors.darkText
                              : AllineColors.navyText,
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'الإشعارات',
                        style: TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AllineColors.darkText
                              : AllineColors.navyText,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'تابع آخر التحديثات والأنشطة الخاصة بمتجرك',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: isDark
                              ? AllineColors.darkTextSub
                              : AllineColors.coolGray,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Consumer<NotificationController>(
                  builder: (context, controller, _) {
                    final unreadCount = controller.unreadCount;
                    if (unreadCount <= 0) return const SizedBox.shrink();

                    return InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () async {
                        await controller.markAllAsRead();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'تم تحديد جميع الإشعارات كمقروءة',
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
                        }
                      },
                      child: Container(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AllineColors.primary.withValues(alpha: 0.15)
                              : AllineColors.softBlue,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AllineColors.primary.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.done_all_rounded,
                              size: 15,
                              color: isDark
                                  ? const Color(0xFF60A5FA)
                                  : AllineColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'تحديد كمقروء',
                              style: TextStyle(
                                fontFamily: 'AllineTajawal',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                  ? const Color(0xFF60A5FA)
                                  : AllineColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 6),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: onOpenSettings,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AllineColors.darkSurface
                          : AllineColors.softBlue,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? AllineColors.darkBorder
                            : AllineColors.border,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      size: 18,
                      color: isDark
                          ? AllineColors.darkTextSub
                          : AllineColors.coolGray,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
