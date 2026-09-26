import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/order/domain/models/order_model.dart';
import 'package:sixvalley_vendor_app/features/order_details/controllers/order_details_controller.dart';
import 'package:sixvalley_vendor_app/features/order_details/domain/models/order_setup_model.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/order_setup_bottom_sheet.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class AllineOrderActionBarWidget extends StatefulWidget {
  final Order? order;
  final bool onlyDigital;
  const AllineOrderActionBarWidget({super.key, required this.order, this.onlyDigital = false});

  @override
  State<AllineOrderActionBarWidget> createState() => _AllineOrderActionBarWidgetState();
}

class _AllineOrderActionBarWidgetState extends State<AllineOrderActionBarWidget> {
  bool _isProcessingAction = false;

  Future<void> _updateStatus(BuildContext context, String newStatus, String confirmTitle, String confirmMessage) async {
    final orderDetailsCtrl = Provider.of<OrderDetailsController>(context, listen: false);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          confirmTitle,
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: AllineColors.textDark),
        ),
        content: Text(
          confirmMessage,
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: AllineColors.textDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'إلغاء',
              style: robotoMedium.copyWith(color: AllineColors.textLight),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == 'canceled' ? AllineColors.danger : AllineColors.secondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'تأكيد',
              style: robotoBold.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isProcessingAction = true);
      try {
        await orderDetailsCtrl.setUpOrder(
          orderSetupModel: OrderSetupModel(
            orderId: widget.order?.id,
            orderStatus: newStatus,
            paymentStatus: widget.order?.paymentStatus ?? 'unpaid',
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isProcessingAction = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.order == null) return const SizedBox.shrink();
    if (widget.order?.orderType == 'POS') return const SizedBox.shrink();

    final status = widget.order?.orderStatus?.toLowerCase() ?? 'pending';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Advanced Setup Icon Button
            Container(
              decoration: BoxDecoration(
                color: AllineColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AllineColors.borderLight),
              ),
              child: IconButton(
                tooltip: 'إعدادات الطلب وتعيين المندوب',
                icon: const Icon(Icons.tune_rounded, color: AllineColors.secondary, size: 20),
                onPressed: () {
                  showModalBottomSheet(
                    backgroundColor: Theme.of(context).cardColor,
                    useSafeArea: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    isScrollControlled: true,
                    context: context,
                    builder: (ctx) => OrderSetupBottomSheet(
                      orderModel: widget.order,
                      onlyDigital: widget.onlyDigital,
                      bottomContext: context,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),

            // Invoice Download Button
            Consumer<OrderDetailsController>(
              builder: (ctx, detailsCtrl, _) {
                return Container(
                  decoration: BoxDecoration(
                    color: AllineColors.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AllineColors.borderLight),
                  ),
                  child: IconButton(
                    tooltip: 'تحميل الفاتورة PDF',
                    icon: detailsCtrl.isInvoiceLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AllineColors.secondary),
                          )
                        : const Icon(Icons.picture_as_pdf_outlined, color: AllineColors.secondary, size: 20),
                    onPressed: detailsCtrl.isInvoiceLoading
                        ? null
                        : () {
                            detailsCtrl.getOrderInvoice(widget.order!.id.toString(), context);
                          },
                  ),
                );
              },
            ),
            const SizedBox(width: 10),

            // Contextual Primary Action Button
            Expanded(
              child: _buildPrimaryActionButton(context, status),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryActionButton(BuildContext context, String status) {
    if (_isProcessingAction) {
      return Container(
        height: 48,
        decoration: BoxDecoration(
          color: AllineColors.secondary.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
          ),
        ),
      );
    }

    if (status == 'pending') {
      return Row(
        children: [
          // Reject button
          Expanded(
            flex: 2,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AllineColors.danger, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => _updateStatus(
                context,
                'canceled',
                'رفض الطلب',
                'هل أنت متأكد من رغبتك في إلغاء ورفض هذا الطلب؟',
              ),
              child: Text(
                'رفض الطلب',
                style: robotoBold.copyWith(
                  color: AllineColors.danger,
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Confirm button
          Expanded(
            flex: 3,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AllineColors.secondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
              label: Text(
                'تأكيد الطلب',
                style: robotoBold.copyWith(
                  color: Colors.white,
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
              onPressed: () => _updateStatus(
                context,
                'confirmed',
                'تأكيد الطلب',
                'هل تريد تأكيد هذا الطلب والانتقال إلى مرحلة التجهيز؟',
              ),
            ),
          ),
        ],
      );
    } else if (status == 'confirmed') {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AllineColors.secondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        icon: const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 18),
        label: Text(
          'بدء التجهيز ⏳',
          style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault),
        ),
        onPressed: () => _updateStatus(
          context,
          'processing',
          'بدء التجهيز',
          'هل بدأت في تجهيز وتحضير منتجات هذا الطلب الآن؟',
        ),
      );
    } else if (status == 'processing') {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0284C7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        icon: const Icon(Icons.two_wheeler_rounded, color: Colors.white, size: 20),
        label: Text(
          'جاهز للتوصيل 🛵',
          style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault),
        ),
        onPressed: () => _updateStatus(
          context,
          'out_for_delivery',
          'تسليم للمندوب والتوصيل',
          'هل تم الانتهاء من التجهيز والطلب جاهز للتوصيل للعميل؟',
        ),
      );
    } else if (status == 'out_for_delivery') {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AllineColors.success,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        icon: const Icon(Icons.task_alt_rounded, color: Colors.white, size: 18),
        label: Text(
          'تأكيد التسليم للعميل ✅',
          style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault),
        ),
        onPressed: () => _updateStatus(
          context,
          'delivered',
          'تأكيد استلام العميل',
          'هل تم تسليم الطلب للعميل واستلام القيمة المالية بنجاح؟',
        ),
      );
    } else if (status == 'delivered') {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AllineColors.success.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AllineColors.success),
        ),
        child: Center(
          child: Text(
            'تم تسليم الطلب بنجاح ✅',
            style: robotoBold.copyWith(color: AllineColors.success, fontSize: Dimensions.fontSizeDefault),
          ),
        ),
      );
    } else if (status == 'canceled' || status == 'cancelled') {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AllineColors.danger.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AllineColors.danger),
        ),
        child: Center(
          child: Text(
            'هذا الطلب ملغي ❌',
            style: robotoBold.copyWith(color: AllineColors.danger, fontSize: Dimensions.fontSizeDefault),
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AllineColors.backgroundLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'حالة الطلب: $status',
            style: robotoBold.copyWith(color: AllineColors.textLight, fontSize: Dimensions.fontSizeDefault),
          ),
        ),
      );
    }
  }
}
