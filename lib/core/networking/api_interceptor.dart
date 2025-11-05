import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// API Interceptor for Token Management
///
/// Automatically adds Bearer token to all requests
/// Handles 401 Unauthorized errors
class ApiInterceptor extends Interceptor {
  final storage = const FlutterSecureStorage();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add Bearer Token to all requests (except login/register)
    final token = await storage.read(key: 'auth_token');

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      print('🔐 Token added to request: ${token.substring(0, 20)}...');
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    print('✅ Response [${response.statusCode}]: ${response.requestOptions.path}');
    super.onResponse(response, handler);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    print('❌ Error [${err.response?.statusCode}]: ${err.requestOptions.path}');

    // Handle 401 Unauthorized - Token expired or invalid
    if (err.response?.statusCode == 401) {
      print('⚠️ Unauthorized! Token expired or invalid.');
      // TODO: Redirect to login screen
      // You can implement auto-logout here
      _handleUnauthorized();
    }

    super.onError(err, handler);
  }

  /// Handle Unauthorized Error (401)
  Future<void> _handleUnauthorized() async {
    // Clear stored token
    await storage.delete(key: 'auth_token');

    // TODO: Navigate to login screen
    // This can be implemented using a navigation key or event bus
    print('🔓 Token cleared. User needs to login again.');
  }
}
