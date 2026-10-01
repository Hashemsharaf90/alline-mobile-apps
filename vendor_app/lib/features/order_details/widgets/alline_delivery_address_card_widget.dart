import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/order/domain/models/order_model.dart';
import 'package:sixvalley_vendor_app/features/order_details/controllers/order_details_controller.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/show_on_map_dialog_widget.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

class AllineDeliveryAddressCardWidget extends StatelessWidget {
  final Order? order;
  const AllineDeliveryAddressCardWidget({super.key, required this.order});

  Future<void> _showMap(BuildContext context, BillingAddressData address) async {
    await Provider.of<OrderDetailsController>(context, listen: false)
        .setMarker(address);
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => ShowOnMapDialogWidget(billingAddressData: address),
    );
  }

  @override
  Widget build(BuildContext context) {
    final address = order?.shippingAddressData ?? order?.billingAddressData;
    final city = address?.city?.trim() ?? '';
    final street = address?.address?.trim() ?? '';
    final zip = address?.zip?.trim() ?? '';
    final fullAddress = [city, street, zip]
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    final latitude = double.tryParse(address?.latitude ?? '');
    final longitude = double.tryParse(address?.longitude ?? '');
    final canShowMap = latitude != null && longitude != null;

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
                child: Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: ColorResources.getPrimary(context),
                ),
              ),
              const SizedBox(width: 9),
              Text(
                'عنوان التوصيل',
                style: TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: ColorResources.getTextTitle(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (fullAddress.isEmpty)
            Text(
              'لم يحدد العميل عنوانًا للتوصيل.',
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 13,
                color: ColorResources.getTextSubTitle(context),
              ),
            )
          else ...[
            Text(
              fullAddress.join('، '),
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 14,
                height: 1.6,
                fontWeight: FontWeight.w600,
                color: ColorResources.getTextTitle(context),
              ),
            ),
            if (canShowMap) ...[
              const SizedBox(height: 10),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () => _showMap(context, address!),
                  icon: const Icon(Icons.map_outlined, size: 17),
                  label: const Text('عرض الموقع على الخريطة'),
                  style: TextButton.styleFrom(
                    foregroundColor: ColorResources.getPrimary(context),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    textStyle: const TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
