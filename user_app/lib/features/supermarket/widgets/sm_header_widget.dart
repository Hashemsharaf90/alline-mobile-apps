import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/location/controllers/location_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/location/screens/location_setup_screen.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:provider/provider.dart';

/// Branded Supermarket header: logo, title, delivery location and cart.
class SmHeaderWidget extends StatelessWidget {
  const SmHeaderWidget({super.key});

  static const _text = Color(0xFF071B49);
  static const _secondary = Color(0xFF6D85AF);
  static const _primary = AllineColors.primary;
  static const _border = Color(0xFFDCE7F4);
  static const _softBlue = Color(0xFFEAF3FF);
  static const _orange = AllineColors.accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.paddingOf(context).top + 8,
        16,
        14,
      ),
      child: Column(
        children: [
          Row(
            children: [
              _IconButton(
                icon: Icons.arrow_forward_ios_rounded,
                tooltip: 'رجوع',
                onTap: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height: 42,
                      child: Image.asset(
                        'assets/images/alline/login_logo_transparent.png',
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    const Text(
                      'السوبر ماركت',
                      style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 18,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                        color: _text,
                      ),
                    ),
                  ],
                ),
              ),
              Selector<CartController, int>(
                selector: (_, cart) => cart.cartList.length,
                builder: (context, count, _) => _IconButton(
                  icon: Icons.shopping_cart_outlined,
                  tooltip: 'السلة',
                  badge: count,
                  onTap: () => RouterHelper.getCartScreenRoute(
                    action: RouteAction.push,
                    showBackButton: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Consumer<LocationController>(
            builder: (context, location, _) {
              final label = location.deliveryLabel?.trim();
              final hasLocation = label?.isNotEmpty == true;
              return InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LocationSetupScreen(),
                  ),
                ),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _softBlue,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: _primary,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'موقع التوصيل',
                              style: TextStyle(
                                fontFamily: 'AllineTajawal',
                                color: _secondary,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              hasLocation ? label! : 'حدد موقعك لعرض المتاجر القريبة',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'AllineTajawal',
                                color: hasLocation ? _text : _primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        hasLocation ? 'تغيير' : 'تحديد',
                        style: const TextStyle(
                          fontFamily: 'AllineTajawal',
                          color: _primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_left_rounded,
                        color: _primary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final int badge;

  const _IconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: SmHeaderWidget._border),
                ),
                child: Icon(icon, color: SmHeaderWidget._text, size: 21),
              ),
              if (badge > 0)
                PositionedDirectional(
                  top: -5,
                  end: -5,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: SmHeaderWidget._orange,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      badge > 9 ? '9+' : '$badge',
                      style: const TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
