/// Connectivity Helper
///
/// Lightweight helper to check internet connectivity without external packages
/// Uses Dio to verify actual internet connection

import 'package:dio/dio.dart';

class ConnectivityHelper {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  /// Check if internet is available
  ///
  /// Returns true if internet connection is working
  /// Uses Google DNS as fallback check (reliable and fast)
  static Future<bool> hasInternetConnection() async {
    try {
      // Try to reach a reliable endpoint
      final response = await _dio.get('https://www.google.com');
      return response.statusCode == 200;
    } on DioException catch (e) {
      // Check specific error types
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return false;
      }

      // Check for network errors
      if (e.error != null && e.error.toString().contains('SocketException')) {
        return false;
      }

      // Any other error means no internet
      return false;
    } catch (e) {
      // Any exception means no internet
      return false;
    }
  }

  /// Check connectivity before performing an action
  ///
  /// Returns true if connected, shows error dialog if not
  /// Usage:
  /// ```dart
  /// if (!await ConnectivityHelper.checkConnectivity(context)) return;
  /// // Proceed with network operation
  /// ```
  static Future<bool> checkConnectivity(context) async {
    final hasConnection = await hasInternetConnection();

    if (!hasConnection && context != null) {
      // Import error handler
      // Commented out to avoid circular dependency
      // You can uncomment and use it in your screens
      /*
      ErrorHandler.handle(
        context: context,
        error: NetworkError.noInternet(),
        displayType: ErrorDisplayType.dialog,
      );
      */
    }

    return hasConnection;
  }

  /// Quick ping to check if API server is reachable
  ///
  /// Useful to check if YOUR server is up (not just internet)
  static Future<bool> canReachServer(String serverUrl) async {
    try {
      final response = await _dio.get(
        serverUrl,
        options: Options(
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      );
      return response.statusCode != null && response.statusCode! < 500;
    } catch (e) {
      return false;
    }
  }
}
