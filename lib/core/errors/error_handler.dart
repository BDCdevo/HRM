/// Central Error Handler
///
/// Provides unified error handling and display across the app

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'app_error.dart';
import 'error_display_helper.dart';

/// Main error handler class
class ErrorHandler {
  /// Handle error and show appropriate UI
  ///
  /// [context] - BuildContext for showing dialogs/snackbars
  /// [error] - The error to handle
  /// [displayType] - How to display the error (snackbar, dialog, toast)
  /// [onRetry] - Optional callback for retry action
  static void handle({
    required BuildContext context,
    required Object error,
    ErrorDisplayType displayType = ErrorDisplayType.snackbar,
    VoidCallback? onRetry,
    bool showRetryButton = true,
  }) {
    final appError = _convertToAppError(error);

    // Log the error for debugging
    _logError(appError, error);

    // Display the error to user
    ErrorDisplayHelper.show(
      context: context,
      error: appError,
      displayType: displayType,
      onRetry: (appError.isRetryable && onRetry != null && showRetryButton) ? onRetry : null,
    );
  }

  /// Handle error silently (log only, no UI)
  static void handleSilently(Object error) {
    final appError = _convertToAppError(error);
    _logError(appError, error);
  }

  /// Convert any error to AppError
  static AppError _convertToAppError(Object error) {
    if (error is AppError) {
      return error;
    }

    if (error is DioException) {
      return fromDioException(error);
    }

    // Unknown error type
    return UnknownError.unexpected(error);
  }

  /// Log error for debugging (Debug Mode Only)
  static void _logError(AppError appError, Object originalError) {
    // Only log in debug mode
    if (!kDebugMode) return;

    final severity = appError.severity;
    final icon = _getSeverityIcon(severity);

    debugPrint('$icon [$severity] ${appError.runtimeType}: ${appError.message}');

    if (appError.details != null) {
      debugPrint('   📝 Details: ${appError.details}');
    }

    // Log original error if it's different
    if (originalError is! AppError) {
      debugPrint('   🔍 Original: $originalError');
    }

    // Special logging for specific error types
    if (appError is ValidationError && appError.fieldErrors != null) {
      debugPrint('   📋 Field Errors:');
      appError.fieldErrors!.forEach((field, errors) {
        debugPrint('      • $field: ${errors.join(", ")}');
      });
    }

    if (appError is GeofenceError) {
      if (appError.distanceMeters != null) {
        debugPrint('   📍 Distance: ${appError.distanceMeters}m (allowed: ${appError.allowedRadius}m)');
      }
    }

    if (appError is ServerError && appError.statusCode != null) {
      debugPrint('   🌐 Status Code: ${appError.statusCode}');
    }
  }

  /// Get icon for severity level
  static String _getSeverityIcon(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return 'ℹ️';
      case ErrorSeverity.warning:
        return '⚠️';
      case ErrorSeverity.error:
        return '❌';
      case ErrorSeverity.critical:
        return '🚨';
    }
  }

  /// Get user-friendly error message
  static String getUserMessage(AppError error) {
    return error.message;
  }

  /// Get error details for display
  static String? getErrorDetails(AppError error) {
    return error.details;
  }

  /// Check if error is retryable
  static bool isRetryable(AppError error) {
    return error.isRetryable;
  }

  /// Get retry message based on error type
  static String getRetryMessage(AppError error) {
    if (error is NetworkError) {
      return 'التحقق من الاتصال';
    }
    if (error is ServerError) {
      return 'إعادة المحاولة';
    }
    return 'حاول مرة أخرى';
  }
}

/// Error display types
enum ErrorDisplayType {
  snackbar,  // SnackBar at bottom
  dialog,    // Dialog popup
  toast,     // Toast notification (lightweight)
  fullScreen // Full error screen
}
