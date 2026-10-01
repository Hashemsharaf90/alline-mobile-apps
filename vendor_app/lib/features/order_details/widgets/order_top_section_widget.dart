import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_confirmation_dialog_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_dialog_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixvalley_vendor_app/features/order/domain/models/order_model.dart';
import 'package:sixvalley_vendor_app/features/order_details/controllers/order_details_controller.dart';
import 'package:sixvalley_vendor_app/features/order_edit/screens/edit_product_screen.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class OrderTopSectionWidget extends StatelessWidget {
  final Order? orderModel;
  final bool? fromNotification;

  const OrderTopSectionWidget({
    super.key,
    this.orderModel,
    this.fromNotification,
  });

  Future<void> _goBack(BuildContext context) async {
    Provider.of<OrderDetailsController>(context, listen: false)
        .emptyOrderDetails();
    if (fromNotification == true) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (_) => false,
      );
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (_) => false,
      );
    }
  }

  Future<void> _handleMenu(BuildContext context, String action) async {
    if (orderModel?.id == null) return;

    final controller =
        Provider.of<OrderDetailsController>(context, listen: false);
    if (action == 'invoice') {
      if (controller.isInvoiceLoading) return;
      await controller.getOrderInvoice(orderModel!.id.toString(), context);
      return;
    }

    final config = Provider.of<SplashController>(context, listen: false)
        .configModel;
    final status = orderModel?.orderStatus?.toLowerCase();
    final canEdit = config?.canVendorEditOrder == 1 &&
        (status == 'pending' || status == 'confirmed');
    final orderItems = controller.orderDetails;
    final onlyDigitalProduct = orderItems != null &&
        orderItems.length == 1 &&
        orderItems.first.productDetails?.productType == 'digital';
    final paymentNeedsConfirmation =
        orderModel?.paymentStatus != 'paid' &&
            orderModel?.paymentMethod == 'offline_payment';

    if (paymentNeedsConfirmation) {
      showCustomSnackBarWidget(
        getTranslated('please_confirm_offline_payment', context) ?? '',
        context,
        sanckBarType: SnackBarType.warning,
      );
    } else if (onlyDigitalProduct) {
      showCustomSnackBarWidget(
        getTranslated('order_containing_only_digital', context) ?? '',
        context,
        sanckBarType: SnackBarType.warning,
      );
    } else if (!canEdit) {
      showCustomSnackBarWidget(
        getTranslated('vendors_are_not_allowed_to_edit', context) ?? '',
        context,
        sanckBarType: SnackBarType.warning,
      );
    } else {
      showAnimatedDialogWidget(
        context,
        CustomConfirmationDialogWidget(
          icon: Images.editOrderWarningIcon,
          title: getTranslated('edit_this_order', context) ?? '',
          description:
              getTranslated('make_sure_you_have_saved_all_changes', context) ??
                  '',
          onYesPressed: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditProductScreen(orderDetails: orderItems ?? []),
              ),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleColor = ColorResources.getTextTitle(context);
    final subtitleColor = ColorResources.getTextSubTitle(context);

    return Row(
      children: [
        SizedBox(
          width: 44,
          height: 44,
          child: IconButton(
            tooltip: 'رجوع',
            onPressed: () => _goBack(context),
            icon: Icon(Icons.arrow_back_rounded, color: titleColor),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تفاصيل الطلب',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: robotoBold.copyWith(fontSize: 17, color: titleColor),
              ),
              Text(
                orderModel?.id == null ? 'عرض بيانات الطلب' : 'طلب #${orderModel!.id}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: robotoRegular.copyWith(fontSize: 12, color: subtitleColor),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          tooltip: 'المزيد من الخيارات',
          icon: Consumer<OrderDetailsController>(
            builder: (context, controller, _) => controller.isInvoiceLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ColorResources.getPrimary(context),
                    ),
                  )
                : Icon(Icons.more_vert_rounded, color: subtitleColor),
          ),
          onSelected: (value) => _handleMenu(context, value),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit_outlined, size: 19),
                  const SizedBox(width: 10),
                  Text(getTranslated('edit_order', context) ?? 'تعديل الطلب'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'invoice',
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf_outlined, size: 19),
                  const SizedBox(width: 10),
                  Text(getTranslated('download_invoice', context) ?? 'تحميل الفاتورة'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
