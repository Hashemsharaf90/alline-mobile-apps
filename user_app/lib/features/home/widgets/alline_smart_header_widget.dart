import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/location/controllers/location_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/screens/notification_screen.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:provider/provider.dart';

class AllineSmartHeaderWidget extends StatelessWidget {
  const AllineSmartHeaderWidget({super.key});

  static const _primary = Color(0xFF015FC9);
  static const _text = Color(0xFF071B49);
  static const _secondary = Color(0xFF6D85AF);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF101A2E) : Colors.white;
    final iconSurface =
        isDark ? const Color(0xFF17243B) : const Color(0xFFF4F8FE);

    return ColoredBox(
      color: surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
        child: Column(
          children: [
            Row(
              children: [
                Semantics(
                  label: 'Alline',
                  image: true,
                  child: Image.asset(
                    'assets/images/alline/login_logo_transparent.png',
                    width: 52,
                    height: 44,
                    fit: BoxFit.contain,
                  ),
                ),
                const Spacer(),
                _HeaderAction(
                  tooltip: 'الدعم الفني',
                  icon: Icons.headset_mic_rounded,
                  surface: iconSurface,
                  foreground: isDark ? Colors.white : _text,
                  onTap: () => RouterHelper.getSupportTicketRoute(
                    action: RouteAction.push,
                  ),
                ),
                const SizedBox(width: 4),
                _HeaderAction(
                  tooltip: 'الإشعارات',
                  icon: Icons.notifications_none_rounded,
                  surface: iconSurface,
                  foreground: isDark ? Colors.white : _text,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationScreen(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Consumer<LocationController>(
              builder: (context, location, _) {
                final raw = location.deliveryLabel ?? location.address.name ?? '';
                final label = _displayLocation(raw);
                return Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => RouterHelper.getLocationSetupRoute(
                        action: RouteAction.push,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 44),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(end: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: _primary.withValues(alpha: .09),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.location_on_rounded,
                                  size: 18,
                                  color: _primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'التوصيل إلى',
                                    style: textRegular.copyWith(
                                      fontSize: 10.5,
                                      color: _secondary,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 220),
                                    child: Text(
                                      label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textBold.copyWith(
                                        fontSize: 13,
                                        color: isDark ? Colors.white : _text,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: _secondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static String _displayLocation(String value) {
    if (value.trim().isEmpty) return 'صنعاء، اليمن';
    final parts = value
        .split(RegExp(r'[,،]'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty && !part.contains('+'))
        .toList();
    if (parts.isEmpty) return 'صنعاء، اليمن';
    return parts.take(2).join('، ');
  }
}

class _HeaderAction extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final Color surface;
  final Color foreground;
  final VoidCallback onTap;

  const _HeaderAction({
    required this.tooltip,
    required this.icon,
    required this.surface,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: surface,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, color: foreground, size: 22),
          ),
        ),
      ),
    );
  }
}
