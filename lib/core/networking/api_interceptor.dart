import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../errors/app_error.dart';

/// API Interceptor for Token Management and Error Handling
///
/// Automatically adds Bearer token to all requests
/// Handles 401 Unauthorized errors and other HTTP errors
///
/// IMPORTANT: All debug logging is only active in debug mode
/// Production builds will NOT log any sensitive information
class ApiInterceptor extends Interceptor {
  final storage = const FlutterSecureStorage();

  // Callback for handling 401 logout navigation
  final Function()? onUnauthorized;

  ApiInterceptor({this.onUnauthorized});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add Bearer Token to all requests (except login/register)
    final token = await storage.read(key: 'auth_token');

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';

      // Only log in debug mode, and NEVER log the actual token
      if (kDebugMode) {
        debugPrint('🔐 Authorization token added to request');
      }
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    // Only log in debug mode
    if (kDebugMode) {
      debugPrint('✅ Response [${response.statusCode}]: ${response.requestOptions.path}');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;

    // Only log in debug mode
    if (kDebugMode) {
      debugPrint('❌ Error [$statusCode]: $path');

      // Convert to AppError for better logging
      final appError = fromDioException(err);
      _logDetailedError(appError, err);
    }

    // Handle specific status codes
    if (statusCode == 401) {
      _handleUnauthorized();
    } else if (statusCode == 403) {
      if (kDebugMode) {
        debugPrint('⚠️ Forbidden: Access denied');
      }
    } else if (statusCode == 404) {
      if (kDebugMode) {
        debugPrint('⚠️ Not Found: Resource does not exist');
      }
    } else if (statusCode != null && statusCode >= 500) {
      if (kDebugMode) {
        debugPrint('⚠️ Server Error: Something went wrong on the server');
      }
    }

    super.onError(err, handler);
  }

  /// Log detailed error information (Debug Mode Only)
  void _logDetailedError(AppError appError, DioException dioError) {
    if (!kDebugMode) return;

    debugPrint('   📝 Error Type: ${appError.runtimeType}');
    debugPrint('   💬 Message: ${appError.message}');

    if (appError.details != null) {
      debugPrint('   📄 Details: ${appError.details}');
    }

    // Log response data if available
    if (dioError.response?.data != null) {
      final data = dioError.response!.data;
      if (data is Map && data.containsKey('message')) {
        debugPrint('   🌐 Server Message: ${data['message']}');
      }
      if (data is Map && data.containsKey('errors')) {
        debugPrint('   ⚠️ Validation Errors: ${data['errors']}');
      }
    }

    // Log error type
    if (dioError.type == DioExceptionType.connectionTimeout) {
      debugPrint('   ⏱️ Connection timeout');
    } else if (dioError.type == DioExceptionType.receiveTimeout) {
      debugPrint('   ⏱️ Receive timeout');
    } else if (dioError.type == DioExceptionType.sendTimeout) {
      debugPrint('   ⏱️ Send timeout');
    } else if (dioError.type == DioExceptionType.badCertificate) {
      debugPrint('   🔒 SSL certificate error');
    } else if (dioError.type == DioExceptionType.connectionError) {
      debugPrint('   📡 Connection error');
    }
  }

  /// Handle Unauthorized Error (401)
  Future<void> _handleUnauthorized() async {
    if (kDebugMode) {
      debugPrint('⚠️ Unauthorized! Token expired or invalid.');
    }

    // Clear stored token
    await storage.delete(key: 'auth_token');

    if (kDebugMode) {
      debugPrint('🔓 Token cleared. User needs to login again.');
    }

    // Trigger logout callback if provided
    if (onUnauthorized != null) {
      onUnauthorized!();
    }
  }
}
