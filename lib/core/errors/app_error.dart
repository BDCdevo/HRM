/// App Error Classes
///
/// Defines all error types in the application for consistent error handling

import 'package:dio/dio.dart';

/// Base class for all application errors
abstract class AppError implements Exception {
  final String message;
  final String? details;
  final ErrorSeverity severity;
  final bool isRetryable;

  const AppError({
    required this.message,
    this.details,
    this.severity = ErrorSeverity.error,
    this.isRetryable = false,
  });

  @override
  String toString() => message;
}

/// Error severity levels
enum ErrorSeverity {
  info,    // معلومات فقط
  warning, // تحذير
  error,   // خطأ
  critical // خطأ حرج
}

/// Network-related errors
class NetworkError extends AppError {
  const NetworkError({
    required super.message,
    super.details,
    super.severity = ErrorSeverity.error,
    super.isRetryable = true,
  });

  factory NetworkError.noInternet() => const NetworkError(
        message: 'لا يوجد اتصال بالإنترنت',
        details: 'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى',
        isRetryable: true,
      );

  factory NetworkError.timeout() => const NetworkError(
        message: 'انتهت مهلة الاتصال',
        details: 'استغرق الطلب وقتاً طويلاً. يرجى المحاولة مرة أخرى',
        isRetryable: true,
      );

  factory NetworkError.serverUnreachable() => const NetworkError(
        message: 'لا يمكن الوصول إلى الخادم',
        details: 'تعذر الاتصال بالخادم. يرجى المحاولة لاحقاً',
        isRetryable: true,
      );
}

/// Authentication errors
class AuthError extends AppError {
  const AuthError({
    required super.message,
    super.details,
    super.severity = ErrorSeverity.error,
    super.isRetryable = false,
  });

  factory AuthError.invalidCredentials() => const AuthError(
        message: 'بيانات الدخول غير صحيحة',
        details: 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
      );

  factory AuthError.sessionExpired() => const AuthError(
        message: 'انتهت الجلسة',
        details: 'يرجى تسجيل الدخول مرة أخرى',
      );

  factory AuthError.unauthorized() => const AuthError(
        message: 'غير مصرح',
        details: 'ليس لديك صلاحية للوصول إلى هذا المورد',
      );

  factory AuthError.accountLocked() => const AuthError(
        message: 'الحساب محظور',
        details: 'تم حظر حسابك. يرجى التواصل مع الدعم',
        severity: ErrorSeverity.critical,
      );
}

/// Server errors (5xx)
class ServerError extends AppError {
  final int? statusCode;

  const ServerError({
    required super.message,
    super.details,
    this.statusCode,
    super.severity = ErrorSeverity.error,
    super.isRetryable = true,
  });

  factory ServerError.internal() => const ServerError(
        message: 'خطأ في الخادم',
        details: 'حدث خطأ غير متوقع. يرجى المحاولة لاحقاً',
        statusCode: 500,
      );

  factory ServerError.serviceUnavailable() => const ServerError(
        message: 'الخدمة غير متاحة',
        details: 'الخادم مشغول حالياً. يرجى المحاولة لاحقاً',
        statusCode: 503,
      );

  factory ServerError.maintenance() => const ServerError(
        message: 'صيانة مجدولة',
        details: 'النظام قيد الصيانة. سنعود قريباً',
        statusCode: 503,
        severity: ErrorSeverity.warning,
      );
}

/// Validation errors
class ValidationError extends AppError {
  final Map<String, List<String>>? fieldErrors;

  const ValidationError({
    required super.message,
    super.details,
    this.fieldErrors,
    super.severity = ErrorSeverity.warning,
    super.isRetryable = false,
  });

  factory ValidationError.fromMap(Map<String, dynamic> errors) {
    final fieldErrors = <String, List<String>>{};

    errors.forEach((key, value) {
      if (value is List) {
        fieldErrors[key] = value.map((e) => e.toString()).toList();
      } else {
        fieldErrors[key] = [value.toString()];
      }
    });

    final firstError = fieldErrors.values.first.first;

    return ValidationError(
      message: 'خطأ في البيانات المدخلة',
      details: firstError,
      fieldErrors: fieldErrors,
    );
  }

  /// Get error for specific field
  String? getFieldError(String fieldName) {
    if (fieldErrors == null) return null;
    final errors = fieldErrors![fieldName];
    return errors?.isNotEmpty == true ? errors!.first : null;
  }
}

/// Business logic errors
class BusinessError extends AppError {
  const BusinessError({
    required super.message,
    super.details,
    super.severity = ErrorSeverity.warning,
    super.isRetryable = false,
  });

  factory BusinessError.notFound(String resource) => BusinessError(
        message: 'غير موجود',
        details: 'لم يتم العثور على $resource',
      );

  factory BusinessError.alreadyExists(String resource) => BusinessError(
        message: 'موجود بالفعل',
        details: '$resource موجود بالفعل',
      );

  factory BusinessError.notAllowed() => const BusinessError(
        message: 'غير مسموح',
        details: 'هذا الإجراء غير مسموح به',
      );

  factory BusinessError.insufficientBalance() => const BusinessError(
        message: 'رصيد غير كافٍ',
        details: 'رصيد الإجازات غير كافٍ',
      );
}

/// Location/Permission errors
class PermissionError extends AppError {
  const PermissionError({
    required super.message,
    super.details,
    super.severity = ErrorSeverity.warning,
    super.isRetryable = true,
  });

  factory PermissionError.locationDenied() => const PermissionError(
        message: 'تم رفض إذن الموقع',
        details: 'يجب السماح بالوصول للموقع لتسجيل الحضور',
      );

  factory PermissionError.locationDisabled() => const PermissionError(
        message: 'خدمة الموقع معطلة',
        details: 'يرجى تفعيل خدمة الموقع (GPS) من الإعدادات',
      );

  factory PermissionError.cameraPermissionDenied() => const PermissionError(
        message: 'تم رفض إذن الكاميرا',
        details: 'يرجى السماح بالوصول للكاميرا من الإعدادات',
      );

  factory PermissionError.storagePermissionDenied() => const PermissionError(
        message: 'تم رفض إذن التخزين',
        details: 'يرجى السماح بالوصول للتخزين من الإعدادات',
      );
}

/// Geofencing errors
class GeofenceError extends AppError {
  final double? distanceMeters;
  final double? allowedRadius;

  const GeofenceError({
    required super.message,
    super.details,
    this.distanceMeters,
    this.allowedRadius,
    super.severity = ErrorSeverity.warning,
    super.isRetryable = false,
  });

  factory GeofenceError.outsideBoundary({
    required double distance,
    required double radius,
  }) =>
      GeofenceError(
        message: 'خارج نطاق الفرع',
        details: 'أنت خارج نطاق الفرع المسموح (${distance.toStringAsFixed(0)}م من ${radius.toStringAsFixed(0)}م)',
        distanceMeters: distance,
        allowedRadius: radius,
      );

  factory GeofenceError.noBranchAssigned() => const GeofenceError(
        message: 'لم يتم تعيين فرع',
        details: 'لم يتم تعيين فرع لك. يرجى التواصل مع الإدارة',
      );
}

/// Unknown/Unexpected errors
class UnknownError extends AppError {
  final Object? originalError;

  const UnknownError({
    required super.message,
    super.details,
    this.originalError,
    super.severity = ErrorSeverity.error,
    super.isRetryable = true,
  });

  factory UnknownError.unexpected([Object? error]) => UnknownError(
        message: 'حدث خطأ غير متوقع',
        details: 'نعتذر عن الإزعاج. يرجى المحاولة مرة أخرى',
        originalError: error,
      );
}

/// Convert DioException to AppError
AppError fromDioException(DioException e) {
  // No internet connection
  if (e.type == DioExceptionType.unknown &&
      (e.error.toString().contains('SocketException') ||
       e.error.toString().contains('Network is unreachable'))) {
    return NetworkError.noInternet();
  }

  // Timeout errors
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout) {
    return NetworkError.timeout();
  }

  // Server responded with error
  if (e.response != null) {
    final statusCode = e.response!.statusCode;
    final data = e.response!.data;

    // Extract message from response
    String? serverMessage;
    if (data is Map<String, dynamic>) {
      serverMessage = data['message'] as String?;
    }

    switch (statusCode) {
      case 401:
        return AuthError.sessionExpired();

      case 403:
        return AuthError.unauthorized();

      case 404:
        return BusinessError.notFound('المورد المطلوب');

      case 422:
        // Validation error
        if (data is Map<String, dynamic> && data.containsKey('errors')) {
          return ValidationError.fromMap(data['errors'] as Map<String, dynamic>);
        }
        return ValidationError(
          message: 'خطأ في البيانات',
          details: serverMessage ?? 'يرجى التحقق من البيانات المدخلة',
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return ServerError(
          message: 'خطأ في الخادم',
          details: serverMessage ?? 'حدث خطأ في الخادم. يرجى المحاولة لاحقاً',
          statusCode: statusCode,
        );

      default:
        return UnknownError(
          message: serverMessage ?? 'حدث خطأ',
          details: 'رمز الخطأ: $statusCode',
          originalError: e,
        );
    }
  }

  // Unknown error
  return UnknownError.unexpected(e);
}
