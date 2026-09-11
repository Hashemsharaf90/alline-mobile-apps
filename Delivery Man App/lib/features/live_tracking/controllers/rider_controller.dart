import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixvalley_delivery_boy/features/order/controllers/order_controller.dart';
import 'package:sixvalley_delivery_boy/data/repository/rider_repository.dart';
import 'package:sixvalley_delivery_boy/features/live_tracking/domain/models/distance_model.dart';
import 'package:sixvalley_delivery_boy/utill/images.dart';

class RiderController extends GetxController implements GetxService {
  final RiderRepository riderRepo;
  RiderController({required this.riderRepo});

  double _persistentContentHeight = (Get.context?.width ?? 411) <= 400 ? 220 : 260;
  double get persistentContentHeight => _persistentContentHeight;

  final List<LatLng> _latLngList = [const LatLng(23.8376661, 90.3701626),];
  List<LatLng> toTatLngList = [const LatLng(23.8376661, 90.3701626),];

  List<LatLng> get latLngList => _latLngList;
  double? _distance;
  double? get distance => _distance;

  Position? _position;
  Position? get position => _position;
  LatLng _initialPosition = const LatLng(23.83721, 90.363715);
  LatLng get initialPosition => _initialPosition;
  final List<MarkerData> _customMarkers = [];
  List<MarkerData> get customMarkers => _customMarkers;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  GoogleMapController? mapController;
  int _reload = 0;
  int get reload => _reload;

  final bool _showCancelTripButton = false;
  bool get showCancelTripButton => _showCancelTripButton;


  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
    getPolyline(
        from: _initialPosition,
        to:  LatLng(double.parse(Get.find<OrderController>().selectedOrderLat!), double.parse(Get.find<OrderController>().selectedOrderLng!))
    );
    setFromToMarker(
        from: _initialPosition,
        to:  LatLng(double.parse(Get.find<OrderController>().selectedOrderLat!), double.parse(Get.find<OrderController>().selectedOrderLng!))
    );
  }


  void setFullView(){
    _persistentContentHeight = 600;
    update();
  }
  void setHalfView(){
    _persistentContentHeight = 260;
    update();
  }



  Future<void> getCurrentLocation() async {
    try {
      Position newLocalData = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _position = newLocalData;
      _initialPosition = LatLng(_position!.latitude, _position!.longitude);
      mapController!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _initialPosition, zoom: 15)));
      _distance = await getDistanceInKM(_initialPosition, LatLng(double.parse(Get.find<OrderController>().selectedOrderLat!),
          double.parse(Get.find<OrderController>().selectedOrderLng!)));
    }catch(e){
      debugPrint(e.toString());
    }
  }

  Future<double?> getDistanceInKM(LatLng originLatLng, LatLng destinationLatLng) async {
    _distance = -1;
    Response response = await riderRepo.getDistanceInMeter(originLatLng, destinationLatLng);
    try {
      if (response.statusCode == 200 && response.body['status'] == 'OK') {
        _distance = DistanceModel.fromJson(response.body).rows![0].elements![0].distance!.value! / 1000;
      } else {
        _distance = Geolocator.distanceBetween(
          originLatLng.latitude, originLatLng.longitude, destinationLatLng.latitude, destinationLatLng.longitude,
        ) / 1000;
      }
    } catch (e) {
      _distance = Geolocator.distanceBetween(
        originLatLng.latitude, originLatLng.longitude, destinationLatLng.latitude, destinationLatLng.longitude,
      ) / 1000;
    }
    update();
    return _distance;
  }



  /// Updated for flutter_polyline_points: ^3.0.1
  Future<void> getPolyline({LatLng? from, LatLng? to}) async {
    final List<LatLng> polylineCoordinates = [];

    final LatLng origin = from ?? _initialPosition;
    final LatLng destination = to ??
        LatLng(
          double.parse(Get.find<OrderController>().selectedOrderLat!),
          double.parse(Get.find<OrderController>().selectedOrderLng!),
        );

    try {
      final Response response = await riderRepo.getRoutePolyline(origin, destination);
      final dynamic routes = response.body is Map ? response.body['routes'] : null;
      final dynamic firstRoute = routes is List && routes.isNotEmpty ? routes.first : null;
      final dynamic polyline = firstRoute is Map ? firstRoute['polyline'] : null;
      final dynamic encodedPolyline = polyline is Map ? polyline['encodedPolyline'] : null;

      if (response.statusCode == 200 && encodedPolyline is String && encodedPolyline.isNotEmpty) {
        final decoded = PolylinePoints.decodePolyline(encodedPolyline);
        polylineCoordinates.addAll(decoded.map((point) => LatLng(point.latitude, point.longitude)));
      } else {
        debugPrint('getPolyline: backend did not return a route. status=${response.statusCode}');
      }
    } catch (e, st) {
      debugPrint('getPolyline exception: $e\n$st');
    }
    _addPolyLine(polylineCoordinates);
  }
  void _addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      points: polylineCoordinates,
      width: 5,
      color: Theme.of(Get.context!).primaryColor,
    );
    polylines[id] = polyline;
    update();
  }



  void setFromToMarker({required LatLng from, required LatLng to}) async{
    _customMarkers.clear();
    _customMarkers.add(MarkerData(
      marker: Marker(markerId: const MarkerId('id-0'), position: from),
      child: Image.asset(Images.startPositionIcon, height: 50, width: 50),
    ));

    _customMarkers.add(MarkerData(
      marker: Marker(markerId: const MarkerId('id-1'), position: to),
      child: Image.asset(Images.destinationIcon, height: 40, width: 40),
    ));
    _distance = await getDistanceInKM(from, to);
    try {

      LatLngBounds? bounds;
      if(mapController != null) {
        bounds = LatLngBounds(
          southwest: Get.find<RiderController>().initialPosition,
          northeast: LatLng(double.parse(Get.find<OrderController>().selectedOrderLat!), double.parse(Get.find<OrderController>().selectedOrderLng!)),
        );
      }

      LatLng centerBounds = LatLng(
        (bounds!.northeast.latitude + bounds.southwest.latitude)/2,
        (bounds.northeast.longitude + bounds.southwest.longitude)/2,
      );
      double bearing = Geolocator.bearingBetween(from.latitude, from.longitude, to.latitude, to.longitude);
      mapController!.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
        bearing: bearing, target: centerBounds, zoom: 16,
      )));
      zoomToFit(mapController, bounds, centerBounds, bearing, padding: 0.5);

    }catch(e) {
      // debugPrint(e);
    }


    await Future.delayed(const Duration(milliseconds: 500));
    _reload = 0;
    if(_reload == 0) {
      update();
      _reload = 1;
    }
  }


  Future<void> zoomToFit(GoogleMapController? controller, LatLngBounds? bounds, LatLng centerBounds, double bearing, {double padding = 0.5}) async {
    bool keepZoomingOut = true;

    while(keepZoomingOut) {

      final LatLngBounds screenBounds = await controller!.getVisibleRegion();
      if(fits(bounds!, screenBounds)) {
        keepZoomingOut = false;
        final double zoomLevel = await controller.getZoomLevel() - padding;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
          bearing: bearing,
        )));
        break;
      }
      else {
        // Zooming out by 0.1 zoom level per iteration
        final double zoomLevel = await controller.getZoomLevel() - 0.1;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
      }
    }
  }

  bool fits(LatLngBounds fitBounds, LatLngBounds screenBounds) {
    final bool northEastLatitudeCheck = screenBounds.northeast.latitude >= fitBounds.northeast.latitude;
    final bool northEastLongitudeCheck = screenBounds.northeast.longitude >= fitBounds.northeast.longitude;

    final bool southWestLatitudeCheck = screenBounds.southwest.latitude <= fitBounds.southwest.latitude;
    final bool southWestLongitudeCheck = screenBounds.southwest.longitude <= fitBounds.southwest.longitude;

    return northEastLatitudeCheck && northEastLongitudeCheck && southWestLatitudeCheck && southWestLongitudeCheck;
  }

}
