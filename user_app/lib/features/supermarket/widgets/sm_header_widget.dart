import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/location/controllers/location_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/location/screens/location_setup_screen.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:provider/provider.dart';

/// Compact header for the Supermarket Hub.
///
/// Layout (RTL):
///   [Back] | [Title + Subtitle row] | [Location pill] | [Cart badge]
///
/// The location pill is tappable and opens [LocationSetupScreen].
class SmHeaderWidget extends StatelessWidget {
  const SmHeaderWidget({super.key});

  static const _bg = Colors.white;
  static const _text = Color(0xFF071B49);
  static const _secondary = Color(0xFF6D85AF);
  static const _primary = AllineColors.primary;
  static const _border = Color(0xFFE1E8F2);
  static const _orange = AllineColors.accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 10,
        left: 8,
        right: 8,
      ),
      child: Row(
        children: [
          // Back button
          _IconBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 6),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'السوبر ماركت',
                  style: TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _text,
                    height: 1.2,
                  ),
                ),
                Consumer<LocationController>(
                  builder: (context, loc, _) {
                    final label = loc.deliveryLabel?.trim();
                    return GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LocationSetupScreen(),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              color: _primary, size: 14),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              label?.isNotEmpty == true
                                  ? label!
                                  : 'حدد موقعك',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'AllineTajawal',
                                fontSize: 12,
                                color: label?.isNotEmpty == true
                                    ? _secondary
                                    : _primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'تغيير',
                            style: TextStyle(
                              fontFamily: 'AllineTajawal',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Cart button with badge
          Selector<CartController, int>(
            selector: (_, cart) => cart.cartList.length,
            builder: (context, count, _) => _IconBtn(
              icon: Icons.shopping_cart_outlined,
              badge: count,
              onTap: () => RouterHelper.getCartScreenRoute(
                action: RouteAction.push,
                showBackButton: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int badge;

  const _IconBtn({required this.icon, required this.onTap, this.badge = 0});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: SmHeaderWidget._border),
              ),
              child: Icon(icon, color: SmHeaderWidget._text, size: 21),
            ),
            if (badge > 0)
              PositionedDirectional(
                top: -4,
                end: -4,
                child: Container(
                  constraints:
                      const BoxConstraints(minWidth: 18, minHeight: 18),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
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
      );
}