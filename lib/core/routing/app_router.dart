import 'package:flutter/material.dart';
import '../../features/auth/ui/screens/login_screen.dart';
import '../../features/auth/ui/screens/admin_login_screen.dart';
import '../../features/auth/ui/screens/register_screen.dart';
import '../navigation/main_navigation_screen.dart';
// import '../../features/profile/ui/screens/profile_screen.dart'; // Removed - now using More screen
import '../../features/profile/ui/screens/edit_profile_screen.dart';
import '../../features/profile/ui/screens/change_password_screen.dart';
import '../../features/notifications/ui/screens/notifications_screen.dart';
import '../../features/settings/ui/screens/settings_screen.dart';
import '../../features/reports/ui/screens/monthly_report_screen.dart';
import '../../features/work_schedule/ui/screens/work_schedule_screen.dart';
import '../../features/leave/ui/screens/apply_leave_screen.dart';
import '../../features/leave/ui/screens/leave_history_screen.dart';
import '../../features/leave/ui/screens/leave_balance_screen.dart';
import '../../features/attendance/ui/screens/attendance_history_screen.dart';
import '../../features/about/ui/screens/about_screen.dart';
import '../../features/chat/ui/screens/chat_test_screen.dart';
import '../../features/requests/ui/screens/requests_main_screen.dart';
import 'route_transitions.dart';

/// App Router
///
/// Centralized routing system for the entire application
/// with named routes, custom transitions, and route guards
class AppRouter {
  // Route Names
  static const String splash = '/';
  static const String login = '/login';
  static const String adminLogin = '/admin-login';
  static const String register = '/register';
  static const String mainNavigation = '/main';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String changePassword = '/change-password';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String monthlyReport = '/monthly-report';
  static const String workSchedule = '/work-schedule';
  static const String applyLeave = '/apply-leave';
  static const String leaveHistory = '/leave-history';
  static const String leaveBalance = '/leave-balance';
  static const String attendanceHistory = '/attendance-history';
  static const String chatTest = '/chat-test';
  static const String requests = '/requests';

  /// Generate Route
  ///
  /// Main route generator with custom transitions
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth Routes
      case splash:
      case login:
        return _buildRoute(
          const LoginScreen(),
          settings: settings,
          transition: RouteTransitionType.fade,
        );

      case adminLogin:
        return _buildRoute(
          const AdminLoginScreen(),
          settings: settings,
          transition: RouteTransitionType.slideFromRight,
        );

      case register:
        return _buildRoute(
          const RegisterScreen(),
          settings: settings,
          transition: RouteTransitionType.slideFromBottom,
        );

      // Main Navigation
      case mainNavigation:
        return _buildRoute(
          const MainNavigationScreen(),
          settings: settings,
          transition: RouteTransitionType.fade,
        );

      // Profile Routes
      case profile:
        // Redirect to Edit Profile (ProfileScreen is now part of More tab)
        return _buildRoute(
          const EditProfileScreen(),
          settings: settings,
          transition: RouteTransitionType.slideFromRight,
        );

      case editProfile:
        return _buildRoute(
          const EditProfileScreen(),
          settings: settings,
          transition: RouteTransitionType.slideFromRight,
        );

      case changePassword:
        return _buildRoute(
          const ChangePasswordScreen(),
          settings: settings,
          transition: RouteTransitionType.slideFromRight,
        );

      // Other Routes
      case notifications:
        return _buildRoute(
          const NotificationsScreen(),
          settings: settings,
          transition: RouteTransitionType.slideFromRight,
        );

      case AppRouter.settings:
        return _buildRoute(
          const SettingsScreen(),
          settings: settings,
          transition: RouteTransitionType.slideFromRight,
        );

      case about:
        return _buildRoute(
          const AboutScreen(),
          settings: settings,
          transition: RouteTransitionType.slideFromRight,
        );

      case monthlyReport:
        return _buildRoute(
          const MonthlyReportScreen(),
          settings: settings,
          transition: RouteTransitionType.slideFromRight,
        );

      case workSchedule:
        return _buildRoute(
          const WorkScheduleScreen(),
          settings: settings,
          transition: RouteTransitionType.slideFromRight,
        );

      // Leave Routes
      case applyLeave:
        return _buildRoute(
          const ApplyLeaveScreen(),
          settings: settings,
          transition: RouteTransitionType.slideFromBottom,
        );

      case leaveHistory:
        return _buildRoute(
          const LeaveHistoryScreen(),
          settings: settings,
          transition: RouteTransitionType.slideFromRight,
        );

      case leaveBalance:
        return _buildRoute(
          const LeaveBalanceScreen(),
          settings: settings,
          transition: RouteTransitionType.slideFromRight,
        );

      // Attendance Routes
      case attendanceHistory:
        return _buildRoute(
          const AttendanceHistoryScreen(),
          settings: settings,
          transition: RouteTransitionType.slideFromRight,
        );

      // Chat Test Route
      case chatTest:
        return _buildRoute(
          const ChatTestScreen(),
          settings: settings,
          transition: RouteTransitionType.slideFromRight,
        );

      // Requests Route
      case requests:
        return _buildRoute(
          const RequestsMainScreen(),
          settings: settings,
          transition: RouteTransitionType.slideFromRight,
        );

      default:
        return _buildRoute(
          _ErrorScreen(routeName: settings.name ?? 'unknown'),
          settings: settings,
        );
    }
  }

  /// Build Route with Custom Transition
  static PageRoute _buildRoute(
    Widget page, {
    required RouteSettings settings,
    RouteTransitionType transition = RouteTransitionType.material,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomPageRoute(
      builder: (context) => page,
      settings: settings,
      transitionType: transition,
      duration: duration,
    );
  }

  /// Navigate To
  ///
  /// Helper method to navigate to a named route
  static Future<T?> navigateTo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate And Replace
  ///
  /// Navigate to a route and remove the previous route
  static Future<T?> navigateAndReplace<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed<T, void>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate And Remove Until
  ///
  /// Navigate to a route and remove all routes until predicate
  static Future<T?> navigateAndRemoveUntil<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  /// Go Back
  ///
  /// Pop the current route
  static void goBack(BuildContext context, [dynamic result]) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, result);
    }
  }

  /// Can Go Back
  ///
  /// Check if we can go back
  static bool canGoBack(BuildContext context) {
    return Navigator.canPop(context);
  }
}

/// Error Screen
///
/// Displayed when route is not found
class _ErrorScreen extends StatelessWidget {
  final String routeName;

  const _ErrorScreen({required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Route not found: $routeName',
              style: const TextStyle(fontSize: 18),
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
