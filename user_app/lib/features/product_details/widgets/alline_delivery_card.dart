import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/features/location/controllers/location_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/location/screens/location_setup_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/domain/models/product_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:provider/provider.dart';

/// Alline Delivery Information Card.
///
/// Features:
/// - 🚚 التوصيل إلى: [موقع المستخدم المحدد] مع زر "تغيير"
/// - متوقع الوصول: خلال 1-2 يوم
/// - رسوم التوصيل: شحن مجاني (أخضر) أو السعر التقديري أو تحسب عند إتمام الطلب
class AllineDeliveryCard extends StatelessWidget {
  final ProductDetailsModel? product;

  const AllineDeliveryCard({super.key, required this.product});

  static const _primary = AllineColors.primary;
  static const _text = Color(0xFF071B49);
  static const _secondary = Color(0xFF6D85AF);
  static const _border = Color(0xFFE1E8F2);
  static const _softBlue = Color(0xFFF4F8FE);
  static const _success = AllineColors.success;

  @override
  Widget build(BuildContext context) {
    if (product == null || product?.productType == 'digital') {
      return const SizedBox.shrink();
    }

    final bool isFreeShipping = product?.freeShipping == 1;
    final double? shippingCost = product?.shippingCost;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _softBlue,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Column(
          children: [
            // Row 1: Delivery Location with "تغيير"
            Consumer<LocationController>(
              builder: (context, location, _) {
                final address = location.deliveryLabel?.trim().isNotEmpty == true
                    ? location.deliveryLabel!.trim()
                    : (location.address.name?.trim().isNotEmpty == true
                        ? location.address.name!.trim()
                        : 'صنعاء، اليمن');

                return Row(
                  children: [
                    const Icon(
                      Icons.two_wheeler_rounded,
                      size: 20,
                      color: _primary,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'التوصيل إلى:',
                      style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _text,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _primary,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LocationSetupScreen(),
                        ),
                      ),
                      borderRadius: BorderRadius.circular(6),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        child: Text(
                          'تغيير',
                          style: TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _primary,
                            decoration: TextDecoration.underline,
                            decorationColor: _primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: _border, height: 1),
            ),

            // Row 2: ETA & Shipping Cost
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ETA
                const Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: _secondary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'متوقع الوصول: ',
                      style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 12,
                        color: _secondary,
                      ),
                    ),
                    Text(
                      'خلال 1–2 يوم',
                      style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _text,
                      ),
                    ),
                  ],
                ),

                // Shipping fee tag
                if (isFreeShipping)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'شحن مجاني',
                      style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: _success,
                      ),
                    ),
                  )
                else if (shippingCost != null && shippingCost > 0)
                  Text(
                    'الشحن: ${PriceConverter.convertPrice(context, shippingCost)}',
                    style: const TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _text,
                    ),
                  )
                else
                  const Text(
                    'رسوم التوصيل تحسب عند الطلب',
                    style: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 11,
                      color: _secondary,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
