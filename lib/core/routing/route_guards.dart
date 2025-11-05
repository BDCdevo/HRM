import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/logic/cubit/auth_cubit.dart';
import '../../features/auth/logic/cubit/auth_state.dart';
import 'app_router.dart';

/// Route Guard
///
/// Checks authentication status before allowing navigation
class RouteGuard {
  /// Check if user is authenticated
  static bool isAuthenticated(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    return authState is AuthAuthenticated;
  }

  /// Check if user is admin
  static bool isAdmin(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      // Add logic to check if user is admin
      // For now, return false
      return false;
    }
    return false;
  }

  /// Require Authentication
  ///
  /// Returns the widget if authenticated, otherwise navigates to login
  static Widget requireAuth(
    BuildContext context,
    Widget child, {
    String? redirectTo,
  }) {
    if (isAuthenticated(context)) {
      return child;
    } else {
      // Navigate to login after the frame is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppRouter.navigateAndRemoveUntil(
          context,
          redirectTo ?? AppRouter.login,
        );
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }

  /// Require Guest
  ///
  /// Returns the widget if not authenticated, otherwise navigates to main
  static Widget requireGuest(
    BuildContext context,
    Widget child, {
    String? redirectTo,
  }) {
    if (!isAuthenticated(context)) {
      return child;
    } else {
      // Navigate to main navigation after the frame is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppRouter.navigateAndRemoveUntil(
          context,
          redirectTo ?? AppRouter.mainNavigation,
        );
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }

  /// Require Admin
  ///
  /// Returns the widget if user is admin, otherwise shows access denied
  static Widget requireAdmin(
    BuildContext context,
    Widget child,
  ) {
    if (isAdmin(context)) {
      return child;
    } else {
      return const _AccessDeniedScreen();
    }
  }
}

/// Protected Route Widget
///
/// Wraps a widget with authentication check
class ProtectedRoute extends StatelessWidget {
  final Widget child;
  final bool requireAdmin;
  final String? redirectTo;

  const ProtectedRoute({
    super.key,
    required this.child,
    this.requireAdmin = false,
    this.redirectTo,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is AuthAuthenticated) {
          if (requireAdmin && !RouteGuard.isAdmin(context)) {
            return const _AccessDeniedScreen();
          }
          return child;
        }

        // Not authenticated, redirect to login
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppRouter.navigateAndRemoveUntil(
            context,
            redirectTo ?? AppRouter.login,
          );
        });

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

/// Access Denied Screen
class _AccessDeniedScreen extends StatelessWidget {
  const _AccessDeniedScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Denied'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Access Denied',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You do not have permission to access this page.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
