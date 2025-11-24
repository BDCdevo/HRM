import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import 'api_interceptor.dart';

/// Dio HTTP Client for HRM App
///
/// Singleton pattern for managing HTTP requests to the backend API
class DioClient {
  static DioClient? _instance;
  late Dio dio;

  DioClient._() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        headers: ApiConfig.headers,
        connectTimeout: ApiConfig.connectionTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        validateStatus: (status) => status != null && status >= 200 && status < 300,
      ),
    );

    // Add API Interceptor for Token Management
    dio.interceptors.add(ApiInterceptor());

    // Add Logging Interceptor (Debug Mode Only)
    // IMPORTANT: This interceptor is ONLY active in debug mode
    // It will NOT print anything in production/release builds
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: false, // Don't log headers (contains token)
          requestBody: false,   // Don't log request body (may contain sensitive data)
          responseHeader: false, // Don't log response headers
          responseBody: true,   // Only log response body for debugging
          error: true,
          logPrint: (obj) {
            if (kDebugMode) {
              debugPrint('🌐 DIO: $obj');
            }
          },
        ),
      );
    }
  }

  /// Get singleton instance
  static DioClient getInstance() {
    _instance ??= DioClient._();
    return _instance!;
  }

  /// GET Request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// POST Request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// PUT Request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// DELETE Request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// PATCH Request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }
}
