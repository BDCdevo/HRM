/// Error Display Widgets
///
/// Beautiful and user-friendly error widgets

import 'package:flutter/material.dart';
import '../styles/app_colors.dart';
import '../errors/app_error.dart';

/// Error Dialog Widget
class ErrorDialog extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;

  const ErrorDialog({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _getErrorColor(error).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getErrorIcon(error),
              color: _getErrorColor(error),
              size: 40,
            ),
          ),
          const SizedBox(height: 20),

          // Error Title
          Text(
            error.message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Error Details
          if (error.details != null)
            Text(
              error.details!,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

          // Field Errors (for validation)
          if (error is ValidationError &&
              (error as ValidationError).fieldErrors != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: (error as ValidationError).fieldErrors!.entries.map((
                  entry,
                ) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 16,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.value.first,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              // Close Button
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isDark ? Colors.white24 : AppColors.border,
                      ),
                    ),
                  ),
                  child: Text(
                    'إغلاق',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              // Retry Button
              if (onRetry != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onRetry!();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'إعادة المحاولة',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  IconData _getErrorIcon(AppError error) {
    if (error is NetworkError) return Icons.wifi_off;
    if (error is AuthError) return Icons.lock_outline;
    if (error is ValidationError) return Icons.error_outline;
    if (error is ServerError) return Icons.cloud_off;
    if (error is PermissionError) return Icons.block;
    if (error is GeofenceError) return Icons.location_off;
    return Icons.error_outline;
  }

  Color _getErrorColor(AppError error) {
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
}

/// Error Toast Widget (lightweight notification)
class ErrorToast extends StatefulWidget {
  final AppError error;

  const ErrorToast({super.key, required this.error});

  @override
  State<ErrorToast> createState() => _ErrorToastState();
}

class _ErrorToastState extends State<ErrorToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // Auto dismiss
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getErrorColor(widget.error),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    _getErrorIcon(widget.error),
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.error.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getErrorIcon(AppError error) {
    if (error is NetworkError) return Icons.wifi_off;
    if (error is AuthError) return Icons.lock_outline;
    if (error is ValidationError) return Icons.error_outline;
    if (error is ServerError) return Icons.cloud_off;
    if (error is PermissionError) return Icons.block;
    if (error is GeofenceError) return Icons.location_off;
    return Icons.error_outline;
  }

  Color _getErrorColor(AppError error) {
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
}

/// Full Screen Error Widget
class ErrorScreen extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;

  const ErrorScreen({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Illustration
              Icon(
                _getErrorIcon(error),
                size: 120,
                color: _getErrorColor(error).withOpacity(0.3),
              ),
              const SizedBox(height: 32),

              // Error Message
              Text(
                error.message,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Error Details
              if (error.details != null)
                Text(
                  error.details!,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 48),

              // Retry Button
              if (onRetry != null)
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getErrorIcon(AppError error) {
    if (error is NetworkError) return Icons.wifi_off_rounded;
    if (error is AuthError) return Icons.lock_outline_rounded;
    if (error is ValidationError) return Icons.error_outline_rounded;
    if (error is ServerError) return Icons.cloud_off_rounded;
    if (error is PermissionError) return Icons.block_rounded;
    if (error is GeofenceError) return Icons.location_off_rounded;
    return Icons.error_outline_rounded;
  }

  Color _getErrorColor(AppError error) {
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
}

/// Inline Error Widget (for forms)
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const InlineErrorWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
          if (onRetry != null)
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              color: AppColors.error,
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}

/// Empty State Widget (for lists with no data)
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty State Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 60,
                color: AppColors.primary.withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            // Message
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Action Button
            if (onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel ?? 'إضافة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact Error Widget (for list items)
class CompactErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const CompactErrorWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.error.withValues(alpha: 0.5),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(color: AppColors.error, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('إعادة المحاولة'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Professional Error SnackBar Helper
///
/// Use this to show error messages as SnackBar instead of full screen errors
class ErrorSnackBar {
  /// Show a professional error SnackBar with icon and retry button
  static void show({
    required BuildContext context,
    required String message,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
    bool isNetworkError = false,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isNetworkError ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: duration,
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

  /// Convert common error messages to Arabic user-friendly messages
  static String getArabicMessage(String error) {
    if (error.contains('401') || error.contains('Unauthenticated')) {
      return 'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى';
    } else if (error.contains('500')) {
      return 'خطأ في السيرفر. يرجى المحاولة لاحقاً';
    } else if (error.contains('Network') || error.contains('connection') || error.contains('SocketException')) {
      return 'لا يوجد اتصال بالإنترنت';
    } else if (error.contains('timeout')) {
      return 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى';
    } else if (error.contains('404')) {
      return 'البيانات غير موجودة';
    }
    return error;
  }

  /// Check if error is network related
  static bool isNetworkRelated(String error) {
    return error.contains('Network') ||
           error.contains('connection') ||
           error.contains('SocketException') ||
           error.contains('timeout');
  }
}
