import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/features/location/controllers/location_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/location/widgets/location_search_dialog_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:provider/provider.dart';

class SelectLocationScreen extends StatefulWidget {
  final google_maps.GoogleMapController? googleMapController;

  const SelectLocationScreen({super.key, required this.googleMapController});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  static const _primary = AllineColors.primary;
  static const _darkBlue = AllineColors.primaryDark;
  static const _text = Color(0xFF071B49);
  static const _secondary = Color(0xFF6D85AF);
  static const _softBlue = Color(0xFFF4F8FE);
  static const _border = Color(0xFFE1E8F2);

  google_maps.GoogleMapController? _mapController;
  google_maps.CameraPosition? _cameraPosition;

  TextStyle _style(double size,
          {Color color = _text, FontWeight weight = FontWeight.w400}) =>
      TextStyle(
        fontFamily: 'AllineTajawal',
        fontSize: size,
        height: 1.4,
        color: color,
        fontWeight: weight,
      );

  @override
  void initState() {
    super.initState();
    context.read<LocationController>().setPickData();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _moveToCurrentLocation(LocationController location) async {
    await location.getCurrentLocation(context, false);
    if (!mounted ||
        (location.pickPosition.latitude == 0 &&
            location.pickPosition.longitude == 0)) {
      return;
    }
    final target = google_maps.LatLng(
      location.pickPosition.latitude,
      location.pickPosition.longitude,
    );
    _cameraPosition = google_maps.CameraPosition(target: target, zoom: 17);
    await _mapController?.animateCamera(
      google_maps.CameraUpdate.newLatLngZoom(target, 17),
    );
  }

  Future<void> _confirm(LocationController location) async {
    final selected = _cameraPosition?.target ??
        google_maps.LatLng(
          location.pickPosition.latitude == 0
              ? 15.3694
              : location.pickPosition.latitude,
          location.pickPosition.longitude == 0
              ? 44.1910
              : location.pickPosition.longitude,
        );
    await location.setPickedCoordinates(
      latitude: selected.latitude,
      longitude: selected.longitude,
      fromAddress: false,
      context: context,
    );
    location.setAddAddressData();
    await widget.googleMapController?.animateCamera(
      google_maps.CameraUpdate.newLatLngZoom(selected, 16),
    );
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _softBlue,
        body: Consumer<LocationController>(
          builder: (context, location, _) {
            final initialCenter = google_maps.LatLng(
              location.pickPosition.latitude == 0
                  ? 15.3694
                  : location.pickPosition.latitude,
              location.pickPosition.longitude == 0
                  ? 44.1910
                  : location.pickPosition.longitude,
            );
            final address = location.pickAddress?.name?.trim() ?? '';

            return Stack(
              children: [
                Positioned.fill(
                  child: google_maps.GoogleMap(
                    initialCameraPosition: google_maps.CameraPosition(
                      target: initialCenter,
                      zoom: 15.5,
                    ),
                    mapType: google_maps.MapType.normal,
                    compassEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    onMapCreated: (controller) {
                      _mapController = controller;
                      location.setMapController(controller);
                    },
                    onCameraMove: (position) => _cameraPosition = position,
                    onCameraIdle: () {
                      if (_cameraPosition != null) {
                        location.updateMapPosition(
                          _cameraPosition,
                          false,
                          null,
                          context,
                        );
                      }
                    },
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        _roundButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.of(context).pop(false),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () => showDialog<void>(
                              context: context,
                              barrierColor: _darkBlue.withValues(alpha: .18),
                              builder: (_) => LocationSearchDialogWidget(
                                mapController: _mapController,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              height: 52,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _border),
                                boxShadow: [
                                  BoxShadow(
                                    color: _darkBlue.withValues(alpha: .09),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.search_rounded,
                                      color: _primary, size: 22),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'ابحث عن منطقتك أو عنوانك',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: _style(14, color: _secondary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 88),
                    child: Icon(Icons.location_on_rounded,
                        color: _primary, size: 54),
                  ),
                ),
                Positioned(
                  left: 18,
                  bottom: 224,
                  child: _roundButton(
                    icon: Icons.my_location_rounded,
                    onTap: location.loading
                        ? null
                        : () => _moveToCurrentLocation(location),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                      border: Border.all(color: _border),
                      boxShadow: [
                        BoxShadow(
                          color: _darkBlue.withValues(alpha: .1),
                          blurRadius: 28,
                          offset: const Offset(0, -6),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('الموقع المحدد',
                              style: _style(13, color: _secondary)),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: _softBlue,
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: const Icon(Icons.location_on_rounded,
                                    color: _primary, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  address.isEmpty
                                      ? 'حرّك الخريطة لتحديد موقعك بدقة'
                                      : address,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: _style(15,
                                      color:
                                          address.isEmpty ? _secondary : _text,
                                      weight: address.isEmpty
                                          ? FontWeight.w400
                                          : FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              onPressed: location.loading
                                  ? null
                                  : () => _confirm(location),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primary,
                                disabledBackgroundColor: _primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: location.loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.2,
                                      ),
                                    )
                                  : Text('تأكيد الموقع',
                                      style: _style(16,
                                          color: Colors.white,
                                          weight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _roundButton({required IconData icon, required VoidCallback? onTap}) =>
      Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: _border),
        ),
        elevation: 3,
        shadowColor: _darkBlue.withValues(alpha: .12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: SizedBox(
            width: 52,
            height: 52,
            child: Icon(icon, color: _primary, size: 23),
          ),
        ),
      );
}
