import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class AllineOrderProgressWidget extends StatelessWidget {
  final String? status;
  const AllineOrderProgressWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final currentStatus = status?.toLowerCase() ?? 'pending';

    // Handle terminal negative statuses
    if (currentStatus == 'canceled' || currentStatus == 'cancelled') {
      return _buildAlertBanner(
        context,
        title: 'الطلب ملغي',
        message: 'تم إلغاء هذا الطلب ولم تعد هناك إجراءات تشغيلية مطلوبة.',
        icon: Icons.cancel_rounded,
        color: AllineColors.danger,
      );
    }
    if (currentStatus == 'returned') {
      return _buildAlertBanner(
        context,
        title: 'الطلب مرتجع',
        message: 'تم تسجيل هذا الطلب كمرتجع من قبل العميل أو الإدارة.',
        icon: Icons.assignment_return_rounded,
        color: const Color(0xFFD97706),
      );
    }
    if (currentStatus == 'failed') {
      return _buildAlertBanner(
        context,
        title: 'تعذر التسليم',
        message: 'فشلت محاولة تسليم هذا الطلب للعميل.',
        icon: Icons.error_outline_rounded,
        color: AllineColors.danger,
      );
    }

    final steps = [
      {'key': 'pending', 'label': 'طلب جديد', 'icon': Icons.fiber_new_rounded},
      {'key': 'confirmed', 'label': 'تم التأكيد', 'icon': Icons.check_circle_outline_rounded},
      {'key': 'processing', 'label': 'قيد التجهيز', 'icon': Icons.inventory_2_outlined},
      {'key': 'out_for_delivery', 'label': 'خرج للتوصيل', 'icon': Icons.two_wheeler_rounded},
      {'key': 'delivered', 'label': 'تم التسليم', 'icon': Icons.task_alt_rounded},
    ];

    int activeIndex = 0;
    if (currentStatus == 'confirmed') {
      activeIndex = 1;
    } else if (currentStatus == 'processing') {
      activeIndex = 2;
    } else if (currentStatus == 'out_for_delivery') {
      activeIndex = 3;
    } else if (currentStatus == 'delivered') {
      activeIndex = 4;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AllineColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'مسار معالجة الطلب',
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: AllineColors.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AllineColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'المرحلة ${activeIndex + 1} من ${steps.length}',
                  style: robotoBold.copyWith(
                    fontSize: 10,
                    color: AllineColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index.isOdd) {
                final stepBefore = index ~/ 2;
                final isPassed = stepBefore < activeIndex;
                return Expanded(
                  child: Container(
                    height: 3,
                    color: isPassed ? AllineColors.success : AllineColors.borderLight,
                  ),
                );
              }

              final stepIndex = index ~/ 2;
              final isCompleted = stepIndex < activeIndex;
              final isCurrent = stepIndex == activeIndex;

              Color circleBg;
              Color circleBorder;
              Color iconColor;

              if (isCompleted) {
                circleBg = AllineColors.success;
                circleBorder = AllineColors.success;
                iconColor = Colors.white;
              } else if (isCurrent) {
                circleBg = AllineColors.secondary;
                circleBorder = AllineColors.secondary;
                iconColor = Colors.white;
              } else {
                circleBg = AllineColors.backgroundLight;
                circleBorder = AllineColors.borderLight;
                iconColor = AllineColors.textLight;
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: circleBg,
                      border: Border.all(color: circleBorder, width: 2),
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : (steps[stepIndex]['icon'] as IconData),
                      size: 14,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 58,
                    child: Text(
                      steps[stepIndex]['label'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: robotoMedium.copyWith(
                        fontSize: 9,
                        color: isCurrent
                            ? AllineColors.secondary
                            : (isCompleted ? AllineColors.textDark : AllineColors.textLight),
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBanner(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: AllineColors.textDark,
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
