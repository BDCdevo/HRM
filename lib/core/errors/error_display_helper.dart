/// Error Display Helper
///
/// Handles displaying errors to users in different formats

import 'package:flutter/material.dart';
import '../styles/app_colors.dart';
import 'app_error.dart';
import 'error_handler.dart';
import '../widgets/error_widgets.dart';

class ErrorDisplayHelper {
  /// Show error to user
  static void show({
    required BuildContext context,
    required AppError error,
    ErrorDisplayType displayType = ErrorDisplayType.snackbar,
    VoidCallback? onRetry,
  }) {
    switch (displayType) {
      case ErrorDisplayType.snackbar:
        _showSnackBar(context, error, onRetry);
        break;

      case ErrorDisplayType.dialog:
        _showDialog(context, error, onRetry);
        break;

      case ErrorDisplayType.toast:
        _showToast(context, error);
        break;

      case ErrorDisplayType.fullScreen:
        // Full screen is handled by the screen itself
        break;
    }
  }

  /// Show error as SnackBar
  static void _showSnackBar(
    BuildContext context,
    AppError error,
    VoidCallback? onRetry,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getErrorIcon(error),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    error.message,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (error.details != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      error.details!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        backgroundColor: _getErrorColor(error),
        behavior: SnackBarBehavior.floating,
        duration: _getDuration(error),
        action: onRetry != null
            ? SnackBarAction(
                label: 'إعادة المحاولة',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// Show error as Dialog
  static void _showDialog(
    BuildContext context,
    AppError error,
    VoidCallback? onRetry,
  ) {
    showDialog(
      context: context,
      barrierDismissible: error.severity != ErrorSeverity.critical,
      builder: (context) => ErrorDialog(
        error: error,
        onRetry: onRetry,
      ),
    );
  }

  /// Show error as Toast (lightweight notification)
  static void _showToast(BuildContext context, AppError error) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => ErrorToast(error: error),
    );

    overlay.insert(overlayEntry);

    // Remove after duration
    Future.delayed(_getDuration(error), () {
      overlayEntry.remove();
    });
  }

  /// Get icon for error type
  static IconData _getErrorIcon(AppError error) {
    if (error is NetworkError) return Icons.wifi_off;
    if (error is AuthError) return Icons.lock_outline;
    if (error is ValidationError) return Icons.error_outline;
    if (error is ServerError) return Icons.cloud_off;
    if (error is PermissionError) return Icons.block;
    if (error is GeofenceError) return Icons.location_off;

    switch (error.severity) {
      case ErrorSeverity.info:
        return Icons.info_outline;
      case ErrorSeverity.warning:
        return Icons.warning_amber;
      case ErrorSeverity.error:
        return Icons.error_outline;
      case ErrorSeverity.critical:
        return Icons.dangerous;
    }
  }

  /// Get color for error type
  static Color _getErrorColor(AppError error) {
    switch (error.severity) {
      case ErrorSeverity.info:
        return Colors.blue;
      case ErrorSeverity.warning:
        return AppColors.warning;
      case ErrorSeverity.error:
        return AppColors.error;
      case ErrorSeverity.critical:
        return Colors.red.shade900;
    }
  }

  /// Get display duration based on severity
  static Duration _getDuration(AppError error) {
    switch (error.severity) {
      case ErrorSeverity.info:
        return const Duration(seconds: 2);
      case ErrorSeverity.warning:
        return const Duration(seconds: 3);
      case ErrorSeverity.error:
        return const Duration(seconds: 4);
      case ErrorSeverity.critical:
        return const Duration(seconds: 6);
    }
  }
}
