import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/features/location/controllers/location_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/screens/notification_screen.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';

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
        child: Row(
          children: [
            Image.asset('assets/images/alline/login_logo_transparent.png',
                width: 52, height: 44, fit: BoxFit.contain),
            const SizedBox(width: 8),
            Expanded(
              child: Consumer<LocationController>(
                builder: (context, location, _) {
                  final raw =
                      location.deliveryLabel ?? location.address.name ?? '';
                  final label = _displayLocation(raw);
                  return InkWell(
                    onTap: () => RouterHelper.getLocationSetupRoute(
                        action: RouteAction.push),
                    borderRadius: BorderRadius.circular(12),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 44),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              size: 19, color: _primary),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('التوصيل إلى',
                                    maxLines: 1,
                                    style: textRegular.copyWith(
                                        fontSize: 9.5, color: _secondary)),
                                Text(label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textBold.copyWith(
                                        fontSize: 12,
                                        color: isDark ? Colors.white : _text)),
                              ],
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded,
                              size: 17, color: _secondary),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 4),
            _HeaderAction(
              tooltip: 'الدعم الفني',
              icon: Icons.headset_mic_rounded,
              surface: iconSurface,
              foreground: isDark ? Colors.white : _text,
              onTap: () =>
                  RouterHelper.getSupportTicketRoute(action: RouteAction.push),
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
                      builder: (_) => const NotificationScreen())),
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
    return parts.isEmpty ? 'صنعاء، اليمن' : parts.take(2).join('، ');
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
  Widget build(BuildContext context) => Tooltip(
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
