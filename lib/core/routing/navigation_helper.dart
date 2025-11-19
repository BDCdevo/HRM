import 'package:flutter/material.dart';
import 'app_router.dart';
import 'route_transitions.dart';

/// Navigation Helper
///
/// Additional helper methods for navigation throughout the app
class NavigationHelper {
  /// Show Bottom Sheet with Route Transition
  static Future<T?> showCustomBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor ?? Colors.transparent,
      isScrollControlled: true,
      builder: (context) => child,
    );
  }

  /// Show Dialog with Custom Transition
  static Future<T?> showCustomDialog<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  /// Navigate with Hero Transition
  static Future<T?> navigateWithHero<T>(
    BuildContext context,
    Widget screen,
    String heroTag,
  ) {
    return Navigator.push<T>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  /// Go to Login and Clear Stack
  static Future<void> goToLogin(BuildContext context) {
    return AppRouter.navigateAndRemoveUntil(
      context,
      AppRouter.login,
    );
  }

  /// Go to Main Navigation and Clear Stack
  static Future<void> goToHome(BuildContext context) {
    return AppRouter.navigateAndRemoveUntil(
      context,
      AppRouter.mainNavigation,
    );
  }

  /// Logout and Go to Login Screen
  static Future<void> logout(BuildContext context) {
    return AppRouter.navigateAndRemoveUntil(
      context,
      AppRouter.login,
    );
  }

  /// Check if Can Pop
  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }

  /// Pop Until Route Name
  static void popUntilRoute(BuildContext context, String routeName) {
    Navigator.popUntil(
      context,
      (route) => route.settings.name == routeName,
    );
  }

  /// Pop Until First Route
  static void popUntilFirst(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  /// Replace All and Navigate
  static Future<T?> replaceAllAndNavigate<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Show Confirmation Dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: confirmColor != null
                ? TextButton.styleFrom(foregroundColor: confirmColor)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Show Loading Dialog
  static Future<void> showLoadingDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Hide Loading Dialog
  static void hideLoadingDialog(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  /// Navigate with Result
  static Future<T?> navigateForResult<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    return await Navigator.pushNamed<T>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate and Wait for Result
  static Future<T?> navigateAndWait<T>(
    BuildContext context,
    Widget screen, {
    RouteTransitionType transition = RouteTransitionType.slideFromRight,
  }) async {
    return await Navigator.push<T>(
      context,
      CustomPageRoute<T>(
        builder: (context) => screen,
        transitionType: transition,
      ),
    );
  }
}
