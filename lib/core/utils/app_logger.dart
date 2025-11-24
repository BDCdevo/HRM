import 'package:flutter/foundation.dart';

/// Production-Safe Logger
///
/// Provides safe logging that only outputs in debug mode
/// In production/release builds, all logs are automatically suppressed
///
/// Usage:
/// ```dart
/// AppLogger.debug('User logged in');
/// AppLogger.info('API request successful');
/// AppLogger.warning('Low battery detected');
/// AppLogger.error('Network request failed');
/// ```
class AppLogger {
  // Private constructor to prevent instantiation
  AppLogger._();

  /// Log debug message (Debug Mode Only)
  ///
  /// Use for detailed debugging information that shouldn't appear in production
  static void debug(String message, [dynamic data]) {
    if (kDebugMode) {
      debugPrint('🐛 DEBUG: $message');
      if (data != null) {
        debugPrint('   Data: $data');
      }
    }
  }

  /// Log info message (Debug Mode Only)
  ///
  /// Use for general informational messages
  static void info(String message, [dynamic data]) {
    if (kDebugMode) {
      debugPrint('ℹ️  INFO: $message');
      if (data != null) {
        debugPrint('   Data: $data');
      }
    }
  }

  /// Log warning message (Debug Mode Only)
  ///
  /// Use for potentially harmful situations
  static void warning(String message, [dynamic data]) {
    if (kDebugMode) {
      debugPrint('⚠️  WARNING: $message');
      if (data != null) {
        debugPrint('   Data: $data');
      }
    }
  }

  /// Log error message (Debug Mode Only)
  ///
  /// Use for error events that might still allow the app to continue
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('❌ ERROR: $message');
      if (error != null) {
        debugPrint('   Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('   Stack Trace: $stackTrace');
      }
    }
  }

  /// Log network request (Debug Mode Only)
  ///
  /// Use for logging network requests and responses
  static void network(String method, String url, {int? statusCode, dynamic data}) {
    if (kDebugMode) {
      if (statusCode != null) {
        debugPrint('🌐 NETWORK [$statusCode]: $method $url');
      } else {
        debugPrint('🌐 NETWORK: $method $url');
      }
      if (data != null) {
        debugPrint('   Data: $data');
      }
    }
  }

  /// Log user action (Debug Mode Only)
  ///
  /// Use for tracking user interactions
  static void action(String action, [Map<String, dynamic>? params]) {
    if (kDebugMode) {
      debugPrint('👤 ACTION: $action');
      if (params != null && params.isNotEmpty) {
        debugPrint('   Params: $params');
      }
    }
  }

  /// Log performance metric (Debug Mode Only)
  ///
  /// Use for performance monitoring
  static void performance(String operation, Duration duration) {
    if (kDebugMode) {
      debugPrint('⏱️  PERFORMANCE: $operation took ${duration.inMilliseconds}ms');
    }
  }

  /// Log security event (Always Logs - Even in Production)
  ///
  /// IMPORTANT: Use ONLY for critical security events
  /// This is the ONLY method that logs in production
  /// Examples: authentication failures, unauthorized access attempts
  static void security(String message, [Map<String, dynamic>? context]) {
    // Always log security events, even in production
    debugPrint('🔒 SECURITY: $message');
    if (context != null && context.isNotEmpty) {
      debugPrint('   Context: $context');
    }

    // TODO: In production, also send to security monitoring service
    // Example: Firebase Crashlytics, Sentry, custom analytics
    if (kReleaseMode) {
      _reportSecurityEvent(message, context);
    }
  }

  /// Report security event to monitoring service
  static void _reportSecurityEvent(String message, Map<String, dynamic>? context) {
    // TODO: Implement reporting to your security monitoring service
    // Example implementations:
    //
    // Firebase Crashlytics:
    // FirebaseCrashlytics.instance.log('SECURITY: $message');
    //
    // Sentry:
    // Sentry.captureMessage('SECURITY: $message', level: SentryLevel.warning);
    //
    // Custom Analytics:
    // AnalyticsService.logSecurityEvent(message, context);
  }
}
