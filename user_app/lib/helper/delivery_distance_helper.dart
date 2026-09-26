import 'dart:math';
import 'package:geolocator/geolocator.dart';

/// Helper to calculate distance and delivery fee in Yemeni Rial (YER)
/// Origin: Al-Zira'a Street, Sana'a (شارع الزراعة، صنعاء)
class DeliveryDistanceHelper {
  // Store Location: شارع الزراعة، صنعاء
  static const double storeLatitude = 15.3582;
  static const double storeLongitude = 44.1985;
  static const String storeName = 'شارع الزراعة، صنعاء';
  static const String storeDescription = 'متجر Alline الرئيسي (شارع الزراعة)';

  // Fee rates in Yemeni Rial (YER)
  static const double baseFeeYer = 500.0;
  static const double perKmFeeYer = 250.0;
  static const double minFeeYer = 1000.0;

  // Urban road factor (Sana'a street grid detour ratio ~1.30)
  static const double roadFactor = 1.30;

  /// Calculate straight-line distance in kilometers.
  static double calculateDistanceKm({
    required double destinationLat,
    required double destinationLng,
  }) {
    if (destinationLat == 0.0 || destinationLng == 0.0) {
      return 0.0;
    }

    try {
      final double distanceMeters = Geolocator.distanceBetween(
        storeLatitude,
        storeLongitude,
        destinationLat,
        destinationLng,
      );
      return double.parse((distanceMeters / 1000.0).toStringAsFixed(2));
    } catch (_) {
      // Fallback Haversine formula
      return double.parse(
        _haversineKm(storeLatitude, storeLongitude, destinationLat, destinationLng)
            .toStringAsFixed(2),
      );
    }
  }

  /// Calculate estimated road distance in kilometers (accounts for urban road network).
  static double calculateRoadDistanceKm({
    required double destinationLat,
    required double destinationLng,
  }) {
    final straightKm = calculateDistanceKm(
      destinationLat: destinationLat,
      destinationLng: destinationLng,
    );
    if (straightKm <= 0.0) return 0.0;
    return double.parse((straightKm * roadFactor).toStringAsFixed(2));
  }

  /// Calculate estimated delivery ETA in minutes
  /// (15 mins preparation + 2.4 mins per road km in Sana'a traffic).
  static int calculateEtaMinutes(double roadDistanceKm) {
    if (roadDistanceKm <= 0.0) return 30;
    final int travelMinutes = (roadDistanceKm * 2.4).round();
    final int totalMinutes = 15 + travelMinutes;
    // Round to nearest 5 minutes
    return ((totalMinutes / 5.0).round() * 5);
  }

  /// Format estimated delivery time in Arabic
  static String formatEtaText(int etaMinutes) {
    if (etaMinutes <= 0) return '30 - 45 دقيقة';
    final int minRange = max(15, etaMinutes - 5);
    final int maxRange = etaMinutes + 10;
    if (maxRange >= 60) {
      final double hours = etaMinutes / 60.0;
      if (hours <= 1.5) {
        return 'ساعة إلى ساعة ونصف تقريباً';
      }
      return '${hours.toStringAsFixed(1)} ساعة تقريباً';
    }
    return '$minRange - $maxRange دقيقة';
  }

  /// Calculate delivery fee in YER based on distance in km.
  static double calculateFeeFromDistanceKm(double distanceKm) {
    if (distanceKm <= 0.0) {
      return minFeeYer;
    }
    final double rawFee = baseFeeYer + (distanceKm * perKmFeeYer);
    // Round to nearest 50 YER for clean local currency amounts
    final double rounded = ((rawFee / 50.0).round() * 50.0);
    return max(minFeeYer, rounded);
  }

  /// Calculate delivery fee directly from destination coordinates.
  static double calculateDeliveryFeeYer({
    required double? destinationLat,
    required double? destinationLng,
  }) {
    if (destinationLat == null ||
        destinationLng == null ||
        destinationLat == 0.0 ||
        destinationLng == 0.0) {
      return minFeeYer;
    }

    final double distanceKm = calculateDistanceKm(
      destinationLat: destinationLat,
      destinationLng: destinationLng,
    );
    return calculateFeeFromDistanceKm(distanceKm);
  }

  /// Parse coordinate safely
  static double? parseCoordinate(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    if (val is String) {
      final trimmed = val.trim();
      if (trimmed.isEmpty) return null;
      return double.tryParse(trimmed);
    }
    return null;
  }

  /// Haversine fallback formula
  static double _haversineKm(
      double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.017453292519943295; // Math.PI / 180
    final double a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
}
