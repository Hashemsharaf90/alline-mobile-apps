import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

class AllineOrderProgressWidget extends StatelessWidget {
  final String? status;
  const AllineOrderProgressWidget({super.key, required this.status});

  static const _steps = <(String, String, IconData)>[
    ('pending', 'تم إنشاء الطلب', Icons.receipt_long_outlined),
    ('confirmed', 'تم تأكيد الطلب', Icons.check_rounded),
    ('processing', 'قيد التجهيز', Icons.inventory_2_outlined),
    ('out_for_delivery', 'قيد التوصيل', Icons.local_shipping_outlined),
    ('delivered', 'مكتمل', Icons.task_alt_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final currentStatus = status?.toLowerCase() ?? 'pending';
    final terminal = switch (currentStatus) {
      'canceled' || 'cancelled' => (
          'تم إلغاء الطلب',
          'أُلغي هذا الطلب، ولا توجد إجراءات تشغيلية متبقية.',
          AllineColors.error,
          Icons.cancel_outlined,
        ),
      'returned' => (
          'الطلب مرتجع',
          'تم تسجيل هذا الطلب كمرتجع.',
          AllineColors.warning,
          Icons.assignment_return_outlined,
        ),
      'failed' => (
          'تعذر التسليم',
          'لم تكتمل عملية تسليم هذا الطلب.',
          AllineColors.error,
          Icons.error_outline_rounded,
        ),
      _ => null,
    };

    if (terminal != null) {
      return _card(
        context,
        child: Row(
          children: [
            _iconCircle(terminal.$3, terminal.$4),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(terminal.$1, style: _titleStyle(context)),
                  const SizedBox(height: 3),
                  Text(terminal.$2, style: _bodyStyle(context)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final activeIndex = _steps.indexWhere((step) => step.$1 == currentStatus);
    final currentIndex = activeIndex < 0 ? 0 : activeIndex;
    final currentLabel = currentStatus == 'pending'
        ? 'طلب جديد'
        : _steps[currentIndex].$2;
    final currentMessage = switch (currentStatus) {
      'pending' => 'بانتظار مراجعة المتجر وتأكيد الطلب.',
      'confirmed' => 'تم تأكيد الطلب، وهو بانتظار بدء التجهيز.',
      'processing' => 'يتم تجهيز الطلب تمهيدًا للتوصيل.',
      'out_for_delivery' => 'الطلب في طريقه إلى العميل.',
      'delivered' => 'تم تسليم الطلب للعميل.',
      _ => 'تتم متابعة حالة الطلب.',
    };

    return _card(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconCircle(AllineColors.primary, Icons.circle),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(currentLabel, style: _titleStyle(context)),
                    const SizedBox(height: 3),
                    Text(currentMessage, style: _bodyStyle(context)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text('مسار الطلب', style: _sectionStyle(context)),
          const SizedBox(height: 12),
          for (var index = 0; index < _steps.length; index++)
            _buildStep(context, index, currentIndex),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, int index, int currentIndex) {
    final isComplete = index < currentIndex;
    final isCurrent = index == currentIndex;
    final color = isComplete
        ? ColorResources.getSuccess(context)
        : isCurrent
            ? ColorResources.getPrimary(context)
            : ColorResources.getTextSubTitle(context).withValues(alpha: .55);

    return SizedBox(
      height: index == _steps.length - 1 ? 34 : 46,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 26,
            child: Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isComplete || isCurrent
                        ? color.withValues(alpha: .12)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: isCurrent ? 2 : 1.4),
                  ),
                  child: Icon(
                    isComplete ? Icons.check_rounded : _steps[index].$3,
                    size: 13,
                    color: color,
                  ),
                ),
                if (index < _steps.length - 1)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: index < currentIndex
                          ? ColorResources.getSuccess(context).withValues(alpha: .6)
                          : ColorResources.getBorder(context),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              _steps[index].$2,
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 13,
                fontWeight: isCurrent || isComplete ? FontWeight.w700 : FontWeight.w500,
                color: isCurrent
                    ? ColorResources.getTextTitle(context)
                    : isComplete
                        ? ColorResources.getTextSubTitle(context)
                        : ColorResources.getTextSubTitle(context).withValues(alpha: .75),
              ),
            ),
          ),
          if (isCurrent) ...[
            const SizedBox(width: 7),
            Container(
              margin: const EdgeInsets.only(top: 3),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: ColorResources.getPrimary(context).withValues(alpha: .1),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                'الحالية',
                style: TextStyle(
                  fontFamily: 'AllineTajawal',
                  color: ColorResources.getPrimary(context),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _card(BuildContext context, {required Widget child}) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: ColorResources.getBorder(context)),
        ),
        child: child,
      );

  Widget _iconCircle(Color color, IconData icon) => Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 21),
      );

  TextStyle _titleStyle(BuildContext context) => TextStyle(
        fontFamily: 'AllineTajawal',
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: ColorResources.getTextTitle(context),
      );

  TextStyle _sectionStyle(BuildContext context) => TextStyle(
        fontFamily: 'AllineTajawal',
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: ColorResources.getTextTitle(context),
      );

  TextStyle _bodyStyle(BuildContext context) => TextStyle(
        fontFamily: 'AllineTajawal',
        fontSize: 12,
        color: ColorResources.getTextSubTitle(context),
      );
}
