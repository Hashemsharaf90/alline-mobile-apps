import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/order/domain/models/order_model.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

class AllineOrderHeaderCardWidget extends StatelessWidget {
  final Order? order;
  const AllineOrderHeaderCardWidget({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final currentOrder = order;
    if (currentOrder == null) return const SizedBox.shrink();

    final createdAt = DateTime.tryParse(currentOrder.createdAt ?? '');
    final dateText = createdAt == null
        ? null
        : DateConverter.localDateToIsoStringAMPM(createdAt);
    final orderType = switch (currentOrder.orderType) {
      'POS' => 'نقطة بيع',
      'supermarket' => 'طلب Alline',
      _ when currentOrder.shippingResponsibility != 'sellerwise_shipping' =>
        'طلب Alline',
      _ => 'طلب متجر',
    };

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 9, 14, 4),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: ColorResources.getBorder(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'طلب #${currentOrder.id ?? '—'}',
                  style: TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: ColorResources.getTextTitle(context),
                  ),
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 8,
                  runSpacing: 5,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _metaChip(context, orderType, Icons.storefront_outlined),
                    if (dateText != null)
                      _metaChip(context, dateText, Icons.schedule_rounded),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.receipt_long_outlined,
            color: ColorResources.getPrimary(context),
            size: 25,
          ),
        ],
      ),
    );
  }

  Widget _metaChip(BuildContext context, String label, IconData icon) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: ColorResources.getScaffoldBg(context),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: ColorResources.getTextSubTitle(context)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 11,
                color: ColorResources.getTextSubTitle(context),
              ),
            ),
          ],
        ),
      );
}
