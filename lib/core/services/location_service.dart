import 'package:geolocator/geolocator.dart';

/// Location Service
///
/// Handles GPS location retrieval and permission management
class LocationService {
  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission status
  static Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  static Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get current position
  ///
  /// Throws exception if:
  /// - Location services are disabled
  /// - Location permissions are denied
  /// - Unable to get location
  static Future<Position> getCurrentPosition() async {
    print('🌍 LocationService.getCurrentPosition called');

    // Check if location services are enabled
    print('🔍 Checking if location services are enabled...');
    bool serviceEnabled = await isLocationServiceEnabled();
    print('📍 Location services enabled: $serviceEnabled');

    if (!serviceEnabled) {
      print('❌ Location services are disabled');
      throw Exception(
          'Location services are disabled. Please enable location in your device settings.');
    }

    // Check permission status
    print('🔍 Checking location permission...');
    LocationPermission permission = await checkPermission();
    print('📍 Current permission: $permission');

    if (permission == LocationPermission.denied) {
      print('⚠️ Permission denied, requesting...');
      // Request permission
      permission = await requestPermission();
      print('📍 Permission after request: $permission');

      if (permission == LocationPermission.denied) {
        print('❌ Permission denied by user');
        throw Exception(
            'Location permission denied. Please grant location access to check in.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('❌ Permission denied forever');
      throw Exception(
          'Location permission permanently denied. Please enable it in app settings.');
    }

    // Get current position
    try {
      print('🚀 Getting current position...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      print('✅ Got position: ${position.latitude}, ${position.longitude}');
      print('📍 Accuracy: ${position.accuracy}m, Altitude: ${position.altitude}m');
      print('⏰ Timestamp: ${position.timestamp}');
      return position;
    } catch (e) {
      print('❌ Error getting position: $e');
      print('❌ Error type: ${e.runtimeType}');
      throw Exception('Unable to get your location. Please try again. Error: $e');
    }
  }

  /// Open location settings
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings
  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Calculate distance between two coordinates (in meters)
  ///
  /// Uses Haversine formula
  static double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Format distance for display
  ///
  /// Returns formatted string like "150 m" or "1.2 km"
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()} m';
    }
    return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
  }
}
