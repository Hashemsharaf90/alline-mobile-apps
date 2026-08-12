import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_sixvalley_ecommerce/features/location/controllers/location_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:latlong2/latlong.dart' as osm;
import 'package:provider/provider.dart';

class SelectLocationScreen extends StatefulWidget {
  final google_maps.GoogleMapController? googleMapController;
  const SelectLocationScreen({super.key, required this.googleMapController});

  @override
  SelectLocationScreenState createState() => SelectLocationScreenState();
}

class SelectLocationScreenState extends State<SelectLocationScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _locationController = TextEditingController();
  osm.LatLng? _cameraCenter;

  @override
  void initState() {
    super.initState();
    Provider.of<LocationController>(context, listen: false).setPickData();
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationController>(context);
    final initialCenter = osm.LatLng(
      locationProvider.pickPosition.latitude == 0
          ? 15.3694
          : locationProvider.pickPosition.latitude,
      locationProvider.pickPosition.longitude == 0
          ? 44.1910
          : locationProvider.pickPosition.longitude,
    );

    _locationController.text = '${locationProvider.pickAddress?.name ?? ''} '
            '${locationProvider.pickAddress?.subAdministrativeArea ?? ''} '
            '${locationProvider.pickAddress?.isoCountryCode ?? ''}'
        .trim();

    return Scaffold(
      appBar: CustomAppBar(
          title: getTranslated('select_delivery_address', context)),
      body: Consumer<LocationController>(
        builder: (context, locationController, child) => Stack(
          clipBehavior: Clip.none,
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: initialCenter,
                initialZoom: 16,
                onPositionChanged: (camera, hasGesture) {
                  _cameraCenter = camera.center;
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.sixamtech.sixvalley',
                  maxZoom: 19,
                ),
                const RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('OpenStreetMap contributors'),
                  ],
                ),
              ],
            ),
            if (locationController.pickAddress != null)
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge, vertical: 18.0),
                margin: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge, vertical: 23.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius:
                      BorderRadius.circular(Dimensions.paddingSizeSmall),
                ),
                child: Row(children: [
                  Expanded(
                    child: Text(
                      _locationController.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.open_with, size: 20),
                ]),
              ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () async {
                      await locationController.getCurrentLocation(
                          context, false);
                      final current = osm.LatLng(
                        locationController.pickPosition.latitude,
                        locationController.pickPosition.longitude,
                      );
                      _cameraCenter = current;
                      _mapController.move(current, 17);
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.only(
                          right: Dimensions.paddingSizeLarge),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(Dimensions.paddingSizeSmall),
                        color: Theme.of(context).hintColor,
                      ),
                      child: Icon(Icons.my_location,
                          color: Theme.of(context).primaryColor, size: 35),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeLarge),
                      child: CustomButton(
                        buttonText: getTranslated('select_location', context),
                        onTap: () async {
                          final selected = _cameraCenter ?? initialCenter;
                          await locationController.setPickedCoordinates(
                            latitude: selected.latitude,
                            longitude: selected.longitude,
                            fromAddress: false,
                            context: context,
                          );
                          locationController.setAddAddressData();
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Icon(Icons.location_on,
                  color: Theme.of(context).primaryColor, size: 50),
            ),
            if (locationController.loading)
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
