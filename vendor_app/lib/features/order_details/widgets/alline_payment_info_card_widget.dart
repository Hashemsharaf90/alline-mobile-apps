import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/order/domain/models/order_model.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

class AllinePaymentInfoCardWidget extends StatelessWidget {
  final Order? order;
  const AllinePaymentInfoCardWidget({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final currentOrder = order;
    if (currentOrder == null) return const SizedBox.shrink();

    final method = currentOrder.paymentMethod;
    final methodLabel = switch (method) {
      'cash_on_delivery' => 'الدفع عند الاستلام',
      'pay_by_wallet' => 'محفظة Alline الإلكترونية',
      null || '' => 'غير محدد',
      _ => getTranslated(method!, context) ?? method!,
    };
    final status = currentOrder.paymentStatus?.toLowerCase();
    final (statusLabel, statusColor, statusIcon) = switch (status) {
      'paid' => ('مدفوع', ColorResources.getSuccess(context), Icons.check_circle_outline_rounded),
      'failed' => ('تعذر الدفع', ColorResources.getError(context), Icons.error_outline_rounded),
      'pending' => ('قيد الانتظار', ColorResources.getWarning(context), Icons.schedule_rounded),
      _ => ('غير مدفوع', ColorResources.getWarning(context), Icons.pending_outlined),
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: ColorResources.getBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: ColorResources.getPrimary(context).withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.payments_outlined,
                    size: 18, color: ColorResources.getPrimary(context)),
              ),
              const SizedBox(width: 9),
              Text(
                'الدفع',
                style: TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: ColorResources.getTextTitle(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          _row(context, 'طريقة الدفع', methodLabel),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'حالة الدفع',
                  style: TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 13,
                    color: ColorResources.getTextSubTitle(context),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: .11),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 5),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) => Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 13,
                color: ColorResources.getTextSubTitle(context),
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: ColorResources.getTextTitle(context),
              ),
            ),
          ),
        ],
      );
}
