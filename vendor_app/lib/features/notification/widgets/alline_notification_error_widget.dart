import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

class AllineNotificationErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const AllineNotificationErrorWidget({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AllineColors.error.withValues(alpha: 0.1),
                border: Border.all(
                  color: AllineColors.error.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: 36,
                  color: AllineColors.error,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'تعذر تحميل الإشعارات',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isDark ? AllineColors.darkText : AllineColors.navyText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'تحقق من اتصالك بالإنترنت وحاول مرة أخرى.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: isDark ? AllineColors.darkTextSub : AllineColors.coolGray,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AllineColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
