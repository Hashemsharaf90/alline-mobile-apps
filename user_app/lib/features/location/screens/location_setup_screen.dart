import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/features/location/controllers/location_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/location/screens/select_location_screen.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

enum _LocationSetupStatus { idle, loading, selected, denied, failed }

class LocationSetupScreen extends StatefulWidget {
  const LocationSetupScreen({super.key});

  @override
  State<LocationSetupScreen> createState() => _LocationSetupScreenState();
}

class _LocationSetupScreenState extends State<LocationSetupScreen> {
  static const _primary = AllineColors.primary;
  static const _darkBlue = AllineColors.primaryDark;
  static const _text = Color(0xFF071B49);
  static const _secondary = Color(0xFF6D85AF);
  static const _softBlue = Color(0xFFF4F8FE);
  static const _border = Color(0xFFE1E8F2);
  static const _error = AllineColors.error;

  _LocationSetupStatus _status = _LocationSetupStatus.idle;

  TextStyle _style(double size,
          {Color color = _text, FontWeight weight = FontWeight.w400}) =>
      TextStyle(
        fontFamily: 'AllineTajawal',
        fontSize: size,
        height: 1.45,
        color: color,
        fontWeight: weight,
      );

  Future<void> _useCurrentLocation() async {
    if (_status == _LocationSetupStatus.loading) return;
    setState(() => _status = _LocationSetupStatus.loading);

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (mounted) setState(() => _status = _LocationSetupStatus.failed);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _status = _LocationSetupStatus.denied);
        return;
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 12),
          ),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null ||
          (position.latitude == 0 && position.longitude == 0)) {
        if (mounted) setState(() => _status = _LocationSetupStatus.failed);
        return;
      }

      if (!mounted) return;
      final location = context.read<LocationController>();
      await location.setPickedCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
        fromAddress: true,
        context: context,
      );
      if (!mounted) return;
      setState(() => _status = location.address.name?.trim().isNotEmpty == true
          ? _LocationSetupStatus.selected
          : _LocationSetupStatus.failed);
    } catch (_) {
      if (mounted) setState(() => _status = _LocationSetupStatus.failed);
    }
  }

  Future<void> _selectManually() async {
    final selected = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const SelectLocationScreen(googleMapController: null),
      ),
    );
    if (!mounted || selected != true) return;
    final location = context.read<LocationController>();
    if (location.address.name?.trim().isNotEmpty == true) {
      setState(() => _status = _LocationSetupStatus.selected);
    }
  }

  Future<void> _continueToHome() async {
    if (_status == _LocationSetupStatus.selected) {
      await context.read<LocationController>().confirmDeliveryLocation();
      if (!mounted) return;
    }
    RouterHelper.getDashboardRoute(
      action: RouteAction.pushNamedAndRemoveUntil,
      page: 'home',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _status == _LocationSetupStatus.loading;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _softBlue,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/images/alline/login_logo_transparent.png',
                        width: 76,
                        height: 76,
                        fit: BoxFit.contain,
                        semanticLabel: 'Alline',
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'حدد موقع التوصيل',
                      textAlign: TextAlign.center,
                      style:
                          _style(24, color: _darkBlue, weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'حدد موقعك لنتمكن من عرض المتاجر والمنتجات المتاحة للتوصيل إلى منطقتك',
                      textAlign: TextAlign.center,
                      style: _style(14, color: _secondary),
                    ),
                    const SizedBox(height: 22),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: _status == _LocationSetupStatus.selected
                          ? _selectedLocationCard()
                          : _status == _LocationSetupStatus.denied
                              ? _messageCard(
                                  key: const ValueKey('denied'),
                                  icon: Icons.location_off_outlined,
                                  title: 'لم نتمكن من الوصول إلى موقعك',
                                  description:
                                      'يمكنك تحديد موقعك يدويًا أو السماح بالوصول إلى الموقع من إعدادات الجهاز.',
                                  error: true,
                                  actionLabel: 'فتح الإعدادات',
                                  onAction: Geolocator.openAppSettings,
                                )
                              : _status == _LocationSetupStatus.failed
                                  ? _messageCard(
                                      key: const ValueKey('failed'),
                                      icon: Icons.gps_off_rounded,
                                      title: 'تعذر تحديد موقعك',
                                      description:
                                          'تأكد من تفعيل خدمة الموقع وحاول مرة أخرى.',
                                      error: true,
                                      actionLabel: 'حاول مرة أخرى',
                                      onAction: _useCurrentLocation,
                                    )
                                  : _locationIllustration(),
                    ),
                    const SizedBox(height: 24),
                    if (_status == _LocationSetupStatus.selected) ...[
                      _primaryButton(
                        label: 'تأكيد الموقع',
                        icon: Icons.check_circle_outline_rounded,
                        onPressed: _continueToHome,
                      ),
                      const SizedBox(height: 12),
                      _secondaryButton(
                        label: 'تغيير الموقع',
                        icon: Icons.edit_location_alt_outlined,
                        onPressed: _selectManually,
                      ),
                    ] else ...[
                      _primaryButton(
                        label: isLoading
                            ? 'جارٍ تحديد موقعك...'
                            : 'استخدام موقعي الحالي',
                        icon: Icons.my_location_rounded,
                        loading: isLoading,
                        onPressed: isLoading ? null : _useCurrentLocation,
                      ),
                      const SizedBox(height: 12),
                      _secondaryButton(
                        label: 'تحديد الموقع يدويًا',
                        icon: Icons.map_outlined,
                        onPressed: isLoading ? null : _selectManually,
                      ),
                    ],
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: isLoading ? null : _continueToHome,
                      style: TextButton.styleFrom(
                        foregroundColor: _secondary,
                        minimumSize: const Size.fromHeight(44),
                      ),
                      child: Text('تخطي الآن',
                          style: _style(14, color: _secondary)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline_rounded,
                            size: 16, color: _secondary),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'نستخدم موقعك لتحسين خيارات المتاجر والتوصيل فقط',
                            textAlign: TextAlign.center,
                            style: _style(12, color: _secondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _locationIllustration() => Container(
        key: const ValueKey('illustration'),
        height: 210,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: _darkBlue.withValues(alpha: .05),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 146,
              height: 146,
              decoration: const BoxDecoration(
                color: _softBlue,
                shape: BoxShape.circle,
              ),
            ),
            Transform.rotate(
              angle: -.14,
              child: const Icon(Icons.map_rounded,
                  size: 118, color: Color(0xFFDCEBFC)),
            ),
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: _primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 6),
                boxShadow: [
                  BoxShadow(
                    color: _primary.withValues(alpha: .2),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: const Icon(Icons.location_on_rounded,
                  size: 42, color: Colors.white),
            ),
            const Positioned(
              top: 38,
              left: 54,
              child: _MapBadge(icon: Icons.storefront_rounded),
            ),
            const Positioned(
              bottom: 38,
              right: 48,
              child:
                  _MapBadge(icon: Icons.two_wheeler_rounded, orange: true),
            ),
          ],
        ),
      );

  Widget _selectedLocationCard() => Consumer<LocationController>(
        key: const ValueKey('selected'),
        builder: (context, location, _) {
          final address = location.address.name?.trim() ?? '';
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _border),
              boxShadow: [
                BoxShadow(
                  color: _darkBlue.withValues(alpha: .05),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _softBlue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.location_on_rounded,
                      color: _primary, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الموقع المحدد',
                          style: _style(13, color: _secondary)),
                      const SizedBox(height: 4),
                      Text(address,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: _style(16, weight: FontWeight.w700)),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle_rounded,
                    color: AllineColors.success, size: 24),
              ],
            ),
          );
        },
      );

  Widget _messageCard({
    required Key key,
    required IconData icon,
    required String title,
    required String description,
    required bool error,
    required String actionLabel,
    required Future<void> Function() onAction,
  }) =>
      Container(
        key: key,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _border),
        ),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: (error ? _error : _primary).withValues(alpha: .08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: error ? _error : _primary, size: 30),
            ),
            const SizedBox(height: 14),
            Text(title,
                textAlign: TextAlign.center,
                style: _style(18, weight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(description,
                textAlign: TextAlign.center,
                style: _style(13, color: _secondary)),
            const SizedBox(height: 10),
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel,
                  style: _style(14, color: _primary, weight: FontWeight.w700)),
            ),
          ],
        ),
      );

  Widget _primaryButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    bool loading = false,
  }) =>
      SizedBox(
        height: 56,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            disabledBackgroundColor:
                loading ? _primary : const Color(0xFFDCE7F4),
            foregroundColor: Colors.white,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          icon: loading
              ? const SizedBox(
                  width: 19,
                  height: 19,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.2),
                )
              : Icon(icon, size: 21),
          label: Text(label,
              style: _style(16, color: Colors.white, weight: FontWeight.w700)),
        ),
      );

  Widget _secondaryButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
  }) =>
      SizedBox(
        height: 56,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: _primary,
            side: const BorderSide(color: _border),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          icon: Icon(icon, size: 21),
          label: Text(label,
              style: _style(16, color: _primary, weight: FontWeight.w700)),
        ),
      );
}

class _MapBadge extends StatelessWidget {
  final IconData icon;
  final bool orange;

  const _MapBadge({required this.icon, this.orange = false});

  @override
  Widget build(BuildContext context) => Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: const Color(0xFFE1E8F2)),
          boxShadow: [
            BoxShadow(
              color: AllineColors.primaryDark.withValues(alpha: .08),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon,
            size: 22,
            color: orange ? AllineColors.accent : AllineColors.brightBlue),
      );
}
