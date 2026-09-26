import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/order/domain/models/order_model.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class AllineCustomerCardWidget extends StatelessWidget {
  final Order? order;
  const AllineCustomerCardWidget({super.key, required this.order});

  Future<void> _launchCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    var cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (!cleanPhone.startsWith('967') && cleanPhone.length == 9) {
      cleanPhone = '967$cleanPhone';
    }
    final uri = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (order == null) return const SizedBox.shrink();

    final isGuest = order?.isGuest ?? false;
    final customerName = isGuest
        ? (order?.shippingAddressData?.contactPersonName ?? order?.billingAddressData?.contactPersonName ?? 'عميل زائر')
        : ((order?.customer != null) ? '${order!.customer!.fName} ${order!.customer!.lName ?? ""}'.trim() : 'عميل Alline');

    final phone = isGuest
        ? (order?.shippingAddressData?.phone ?? order?.billingAddressData?.phone ?? '')
        : (order?.customer?.phone ?? '');

    final address = order?.shippingAddressData?.address ?? order?.billingAddressData?.address ?? 'عنوان التوصيل غير محدد';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.all(16),
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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AllineColors.secondary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_outline_rounded, color: AllineColors.secondary, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'بيانات العميل والتوصيل',
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: AllineColors.textDark,
                    ),
                  ),
                ],
              ),
              if (isGuest)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AllineColors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'طلب زائر',
                    style: robotoBold.copyWith(fontSize: 10, color: AllineColors.orange),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AllineColors.borderLight),
          const SizedBox(height: 12),

          // Name and Contact Actions
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: AllineColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        phone,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: AllineColors.textLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Call Button
              if (phone.isNotEmpty) ...[
                InkWell(
                  onTap: () => _launchCall(phone),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AllineColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.phone_outlined, color: AllineColors.secondary, size: 18),
                  ),
                ),
                const SizedBox(width: 8),

                // WhatsApp Button
                InkWell(
                  onTap: () => _launchWhatsApp(phone),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AllineColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.chat_outlined, color: AllineColors.success, size: 18),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 10),

          // Delivery Address
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AllineColors.backgroundLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AllineColors.borderLight),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: AllineColors.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: AllineColors.textDark,
                    ),
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
