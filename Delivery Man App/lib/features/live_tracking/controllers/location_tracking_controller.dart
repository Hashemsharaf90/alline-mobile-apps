import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/data/api/api_client.dart';
import 'package:sixvalley_delivery_boy/utill/app_constants.dart';

class LocationTrackingController extends GetxController implements GetxService {
  final ApiClient apiClient;

  LocationTrackingController({required this.apiClient});

  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isTracking = false;
  bool _starting = false;
  bool _hasError = false;
  int _generation = 0;
  bool get isTracking => _isTracking;
  bool get hasError => _hasError;

  void startTracking() async {
    if (_isTracking || _starting) return;
    _starting = true;
    final generation = _generation;
    try {

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return;
    }

    if (generation != _generation) return;
    _isTracking = true;
    _hasError = false;

    late LocationSettings locationSettings;
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        intervalDuration: const Duration(seconds: 15),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText: "Tracking your delivery in the background",
          notificationTitle: "Active Delivery",
          enableWakeLock: true,
        )
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 10,
        pauseLocationUpdatesAutomatically: true,
        showBackgroundLocationIndicator: true,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );
    }

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position? position) {
        if (position != null) {
          _recordLocation(position);
        }
      },
      onError: (_) { _hasError = true; update(); },
    );
    update();
    } catch (_) { _hasError = true; update(); }
    finally { _starting = false; }
  }

  void stopTracking() {
    _generation++;
    if (!_isTracking) return;
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _isTracking = false;
    _hasError = false;
    update();
  }

  Future<void> _recordLocation(Position position) async {
    try {
      final response = await apiClient.postData(AppConstants.recordLocationUri, {
        'location': '${position.latitude},${position.longitude}',
        'latitude': position.latitude,
        'longitude': position.longitude,
      });
      _hasError = response.statusCode != 200;
      update();
    } catch (e) {
      _hasError = true;
      update();
    }
  }

  @override
  void onClose() {
    stopTracking();
    super.onClose();
  }
}
