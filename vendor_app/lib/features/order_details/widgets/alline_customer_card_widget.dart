import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/order/domain/models/order_model.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';
import 'package:url_launcher/url_launcher.dart';

class AllineCustomerCardWidget extends StatelessWidget {
  final Order? order;
  const AllineCustomerCardWidget({super.key, required this.order});

  Future<void> _launchCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri(scheme: 'tel', path: cleanPhone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchWhatsApp(String phone) async {
    var cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.startsWith('0') && cleanPhone.length == 10) {
      cleanPhone = cleanPhone.substring(1);
    }
    if (!cleanPhone.startsWith('967') && cleanPhone.length == 9) {
      cleanPhone = '967$cleanPhone';
    }
    final uri = Uri.https('wa.me', '/$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentOrder = order;
    if (currentOrder == null) return const SizedBox.shrink();

    final isGuest = currentOrder.isGuest ?? false;
    final nameFromAddress = currentOrder.shippingAddressData?.contactPersonName ??
        currentOrder.billingAddressData?.contactPersonName;
    final registeredName = [
      currentOrder.customer?.fName,
      currentOrder.customer?.lName,
    ].where((part) => part != null && part.trim().isNotEmpty).join(' ');
    final customerName = isGuest
        ? (nameFromAddress?.trim().isNotEmpty == true
            ? nameFromAddress!
            : 'عميل زائر')
        : registeredName.isNotEmpty
            ? registeredName
            : (nameFromAddress?.trim().isNotEmpty == true
                ? nameFromAddress!
                : 'عميل Alline');
    final phone = (isGuest
            ? currentOrder.shippingAddressData?.phone ??
                currentOrder.billingAddressData?.phone
            : currentOrder.customer?.phone ??
                currentOrder.shippingAddressData?.phone) ??
        '';

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
              _icon(context, Icons.person_outline_rounded),
              const SizedBox(width: 9),
              Expanded(child: _sectionTitle(context, 'بيانات العميل')),
              if (isGuest)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: ColorResources.getWarning(context).withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    'طلب زائر',
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: ColorResources.getWarning(context),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: ColorResources.getPrimary(context).withValues(alpha: .1),
                child: Text(
                  customerName.substring(0, 1),
                  style: TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontWeight: FontWeight.w800,
                    color: ColorResources.getPrimary(context),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: ColorResources.getTextTitle(context),
                      ),
                    ),
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            phone,
                            style: TextStyle(
                              fontFamily: 'AllineTajawal',
                              fontSize: 13,
                              color: ColorResources.getTextSubTitle(context),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (phone.isNotEmpty) ...[
            const SizedBox(height: 13),
            Row(
              children: [
                Expanded(
                  child: _contactButton(
                    context,
                    label: 'اتصال',
                    icon: Icons.call_outlined,
                    color: ColorResources.getPrimary(context),
                    onTap: () => _launchCall(phone),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _contactButton(
                    context,
                    label: 'واتساب',
                    icon: Icons.chat_bubble_outline_rounded,
                    color: ColorResources.getSuccess(context),
                    onTap: () => _launchWhatsApp(phone),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _icon(BuildContext context, IconData icon) => Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: ColorResources.getPrimary(context).withValues(alpha: .1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: ColorResources.getPrimary(context)),
      );

  Widget _sectionTitle(BuildContext context, String text) => Text(
        text,
        style: TextStyle(
          fontFamily: 'AllineTajawal',
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: ColorResources.getTextTitle(context),
        ),
      );

  Widget _contactButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) => OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 17, color: color),
        label: Text(
          label,
          style: TextStyle(
            fontFamily: 'AllineTajawal',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 40),
          side: BorderSide(color: color.withValues(alpha: .28)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
        ),
      );
}
