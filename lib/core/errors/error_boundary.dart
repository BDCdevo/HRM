/// Global Error Boundary
///
/// Catches and handles all uncaught errors in the app

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app_error.dart';
import '../widgets/error_widgets.dart';

/// Initialize global error handlers
void initializeErrorBoundary() {
  // Catch Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    _logFlutterError(details);

    // In release mode, you might want to report to crash analytics
    if (kReleaseMode) {
      // TODO: Report to Firebase Crashlytics, Sentry, etc.
      _reportErrorToService(details);
    }
  };

  // Catch async errors not caught by Flutter
  PlatformDispatcher.instance.onError = (error, stack) {
    _logAsyncError(error, stack);

    // In release mode, report to crash analytics
    if (kReleaseMode) {
      // TODO: Report to Firebase Crashlytics, Sentry, etc.
      _reportErrorToService(error, stack);
    }

    return true; // Handled
  };
}

/// Log Flutter framework errors (Debug Mode Only)
void _logFlutterError(FlutterErrorDetails details) {
  // Only log detailed information in debug mode
  if (kDebugMode) {
    debugPrint('🚨 ═══════════════════════════════════════');
    debugPrint('🚨 FLUTTER ERROR');
    debugPrint('🚨 ═══════════════════════════════════════');
    debugPrint('📍 Source: ${details.context ?? "Unknown"}');
    debugPrint('❌ Error: ${details.exception}');
    debugPrint('📚 Stack Trace:');
    debugPrint(details.stack.toString());
    debugPrint('🚨 ═══════════════════════════════════════\n');
  }
}

/// Log async errors (Debug Mode Only)
void _logAsyncError(Object error, StackTrace stack) {
  // Only log detailed information in debug mode
  if (kDebugMode) {
    debugPrint('🚨 ═══════════════════════════════════════');
    debugPrint('🚨 ASYNC ERROR');
    debugPrint('🚨 ═══════════════════════════════════════');
    debugPrint('❌ Error: $error');
    debugPrint('📚 Stack Trace:');
    debugPrint(stack.toString());
    debugPrint('🚨 ═══════════════════════════════════════\n');
  }
}

/// Report error to external service
void _reportErrorToService(dynamic error, [StackTrace? stackTrace]) {
  // TODO: Implement error reporting to:
  // - Firebase Crashlytics
  // - Sentry
  // - Custom backend endpoint
  // - Analytics service

  debugPrint('📤 Error would be reported to crash service');
  debugPrint('   Error: $error');
  if (stackTrace != null) {
    debugPrint('   Stack: ${stackTrace.toString().substring(0, 200)}...');
  }
}

/// Error Boundary Widget
///
/// Wraps a widget tree and catches errors
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(FlutterErrorDetails)? errorBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _errorDetails;

  @override
  void initState() {
    super.initState();

    // Catch errors in this subtree
    // Note: This is limited - FlutterError.onError is global
  }

  @override
  Widget build(BuildContext context) {
    if (_errorDetails != null) {
      // Show error UI
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_errorDetails!);
      }

      // Default error UI
      return ErrorScreen(
        error: UnknownError(
          message: 'حدث خطأ غير متوقع',
          details: _errorDetails!.exceptionAsString(),
        ),
        onRetry: () {
          setState(() {
            _errorDetails = null;
          });
        },
      );
    }

    return widget.child;
  }
}

/// Custom Error Widget for release mode
class CustomErrorWidget extends StatelessWidget {
  final FlutterErrorDetails details;

  const CustomErrorWidget({
    super.key,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorScreen(
      error: UnknownError(
        message: 'حدث خطأ غير متوقع',
        details: kReleaseMode ? 'نعتذر عن الإزعاج. يرجى إعادة تشغيل التطبيق' : details.exceptionAsString(),
      ),
      onRetry: () {
        // In release mode, this would restart or go to home
        // For now, just log
        debugPrint('Retry tapped on error screen');
      },
    );
  }
}

/// Override default error widget
void setCustomErrorWidget() {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    // In debug mode, show the default red screen
    if (kDebugMode) {
      return ErrorWidget(details.exception);
    }

    // In release mode, show our custom error screen
    return CustomErrorWidget(details: details);
  };
}

/// Run app with error boundary
void runAppWithErrorBoundary(Widget app) {
  // Initialize error handlers
  initializeErrorBoundary();

  // Set custom error widget
  setCustomErrorWidget();

  // Run the app
  runApp(
    ErrorBoundary(
      child: app,
    ),
  );
}
