import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// WiFi Service
///
/// Provides WiFi network information for attendance check-in validation
class WifiService {
  static final WifiService _instance = WifiService._internal();
  factory WifiService() => _instance;
  WifiService._internal();

  final NetworkInfo _networkInfo = NetworkInfo();

  /// Check and request location permission (required for WiFi info on Android)
  Future<bool> requestPermissions() async {
    // Location permission is required to get WiFi info
    final locationStatus = await Permission.location.request();

    if (locationStatus.isGranted) {
      return true;
    }

    // On Android 10+, also need ACCESS_FINE_LOCATION
    if (locationStatus.isDenied) {
      final fineLocation = await Permission.locationWhenInUse.request();
      return fineLocation.isGranted;
    }

    return false;
  }

  /// Get current WiFi SSID (network name)
  Future<String?> getWifiSSID() async {
    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        print('❌ WiFi: Location permission denied');
        return null;
      }

      final ssid = await _networkInfo.getWifiName();
      // Remove quotes if present (Android returns "SSID")
      if (ssid != null) {
        return ssid.replaceAll('"', '');
      }
      return null;
    } catch (e) {
      print('❌ WiFi SSID Error: $e');
      return null;
    }
  }

  /// Get current WiFi BSSID (router MAC address)
  Future<String?> getWifiBSSID() async {
    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        print('❌ WiFi: Location permission denied');
        return null;
      }

      final bssid = await _networkInfo.getWifiBSSID();
      return bssid?.toUpperCase();
    } catch (e) {
      print('❌ WiFi BSSID Error: $e');
      return null;
    }
  }

  /// Get complete WiFi info
  Future<WifiInfo?> getWifiInfo() async {
    final ssid = await getWifiSSID();
    final bssid = await getWifiBSSID();

    if (ssid == null) {
      return null;
    }

    return WifiInfo(
      ssid: ssid,
      bssid: bssid,
    );
  }

  /// Check if device is connected to WiFi
  Future<bool> isConnectedToWifi() async {
    final ssid = await getWifiSSID();
    return ssid != null && ssid.isNotEmpty && ssid != '<unknown ssid>';
  }
}

/// WiFi Information Model
class WifiInfo {
  final String? ssid;
  final String? bssid;

  WifiInfo({
    this.ssid,
    this.bssid,
  });

  Map<String, dynamic> toJson() => {
    'ssid': ssid,
    'bssid': bssid,
  };

  @override
  String toString() => 'WifiInfo(ssid: $ssid, bssid: $bssid)';
}
