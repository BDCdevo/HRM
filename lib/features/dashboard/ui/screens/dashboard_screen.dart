import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/theme/cubit/theme_cubit.dart';
import '../../../auth/logic/cubit/auth_cubit.dart';
import '../../../auth/logic/cubit/auth_state.dart';
import '../../../auth/ui/screens/login_screen.dart';
import '../../../attendance/logic/cubit/attendance_cubit.dart';
import '../../../attendance/logic/cubit/attendance_state.dart';
import '../../../notifications/ui/screens/notifications_screen.dart';
import '../../../notifications/logic/cubit/notifications_cubit.dart';
import '../../../notifications/logic/cubit/notifications_state.dart';
import '../../../profile/ui/screens/profile_screen.dart';
import '../../logic/cubit/dashboard_cubit.dart';
import '../../logic/cubit/dashboard_state.dart';
import '../widgets/check_in_card.dart';
import '../widgets/check_in_counter_card.dart';
import '../widgets/today_attendance_stats_card.dart';
import '../widgets/services_grid_widget.dart';

/// Dashboard Screen
///
/// Main screen after successful login
/// Shows user information, quick stats, and quick actions
/// Fetches real data from the backend API
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardCubit _dashboardCubit;
  late final AttendanceCubit _attendanceCubit;
  late final NotificationsCubit _notificationsCubit;

  @override
  void initState() {
    super.initState();
    _dashboardCubit = DashboardCubit();
    _attendanceCubit = AttendanceCubit();
    _notificationsCubit = NotificationsCubit();
    // Fetch dashboard stats and attendance status when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _dashboardCubit.fetchDashboardStats();
        _attendanceCubit.fetchTodayStatus();
        _notificationsCubit.fetchNotifications();
      }
    });
  }

  @override
  void dispose() {
    _dashboardCubit.close();
    _attendanceCubit.close();
    _notificationsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _dashboardCubit),
        BlocProvider.value(value: _attendanceCubit),
        BlocProvider.value(value: _notificationsCubit),
      ],
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            // Navigate back to login screen
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
              (route) => false,
            );
          }
        },
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final user = authState.user;

          return BlocListener<AttendanceCubit, AttendanceState>(
            listener: (context, attendanceState) {
              if (attendanceState is CheckInSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(attendanceState.attendance.message ?? 'Checked in successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
                // Refresh status after successful check-in
                _attendanceCubit.fetchTodayStatus();
              } else if (attendanceState is CheckOutSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(attendanceState.attendance.message ?? 'Checked out successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
                // Refresh status after successful check-out
                _attendanceCubit.fetchTodayStatus();
              } else if (attendanceState is AttendanceError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(attendanceState.displayMessage),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, dashboardState) {
              // Show loading state with skeleton
              if (dashboardState is DashboardLoading) {
                return Scaffold(
                  appBar: PreferredSize(
                    preferredSize: const Size.fromHeight(56),
                    child: AppBar(
                      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                      elevation: 0,
                    ),
                  ),
                  body: const DashboardSkeleton(),
                );
              }

              // Show error state
              if (dashboardState is DashboardError) {
                final isDark = Theme.of(context).brightness == Brightness.dark;

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error Loading Dashboard',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dashboardState.displayMessage,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: 'Retry',
                          onPressed: () {
                            context.read<DashboardCubit>().fetchDashboardStats();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Get stats from loaded state or use defaults
              final stats = dashboardState is DashboardLoaded
                  ? dashboardState.stats
                  : null;

              return Scaffold(
                appBar: AppBar(
                  backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                  elevation: 0,
                  leading: Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: AppColors.white),
                      onPressed: () {
                        // TODO: Open drawer
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),

                  actions: [
                    // Dark Mode Toggle
                    IconButton(
                      icon: Icon(
                        context.watch<ThemeCubit>().isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                        color: AppColors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        context.read<ThemeCubit>().toggleTheme();
                      },
                    ),
                    // Notification Bell with Dynamic Badge
                    BlocBuilder<NotificationsCubit, NotificationsState>(
                      builder: (context, notifState) {
                        final unreadCount = notifState is NotificationsLoaded
                            ? notifState.unreadCount
                            : 0;

                        return IconButton(
                          icon: Stack(
                            children: [
                              const Icon(Icons.notifications, color: AppColors.white, size: 28),
                              // Badge for unread notifications (dynamic)
                              if (unreadCount > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const NotificationsScreen(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    // User Profile Photo
                    Padding(
                      padding: const EdgeInsets.only(right: 12, left: 8),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          backgroundColor: AppColors.white,
                          radius: 18,
                          child: user.image != null && user.image!.url.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    user.image!.url,
                                    width: 36,
                                    height: 36,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildDefaultAvatar(user);
                                    },
                                  ),
                                )
                              : _buildDefaultAvatar(user),
                        ),
                      ),
                    ),
                  ],
                ),
                body: RefreshIndicator(
                  onRefresh: () async {
                    await context.read<DashboardCubit>().refresh();
                    _attendanceCubit.fetchTodayStatus();
                  },
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Dark Header Section
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(context).appBarTheme.backgroundColor,
                              ),
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Greeting and Name
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _getGreeting(user.firstName),
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.white.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        user.firstName,
                                        style: AppTextStyles.headlineMedium.copyWith(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Refresh and WhatsApp Icons
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.refresh, color: AppColors.white, size: 24),
                                        onPressed: () {
                                          context.read<DashboardCubit>().refresh();
                                          _attendanceCubit.fetchTodayStatus();
                                        },
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.whatsappGreen, // WhatsApp green
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        child: const Icon(
                                          Icons.chat,
                                          color: AppColors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Content with overlapping card
                            Transform.translate(
                              offset: const Offset(0, -80),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Today's Attendance Card (overlapping)
                                    BlocBuilder<AttendanceCubit, AttendanceState>(
                                      builder: (context, attendanceState) {
                                        final status = attendanceState is AttendanceStatusLoaded
                                            ? attendanceState.status
                                            : null;
                                        return _buildTodayAttendanceCard(context, status);
                                      },
                                    ),

                                    const SizedBox(height: 24),

                                // Today's Attendance Stats Card
                                BlocBuilder<DashboardCubit, DashboardState>(
                                  builder: (context, dashboardState) {
                                    final stats = dashboardState is DashboardLoaded
                                        ? dashboardState.stats
                                        : null;

                                    // Use stats from API or default values
                                    final presentCount = stats?.todayPresent ?? 0;
                                    final absentCount = stats?.todayAbsent ?? 0;
                                    final checkedOutCount = stats?.todayCheckedOut ?? 0;

                                    return TodayAttendanceStatsCard(
                                      presentCount: presentCount,
                                      absentCount: absentCount,
                                      checkedOutCount: checkedOutCount,
                                    );
                                  },
                                ),

                                const SizedBox(height: 24),

                                // Services Grid
                                const ServicesGridWidget(),

                                const SizedBox(height: 24),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
            ),
          );
        },
      ),
    );
  }

  /// Build Default Avatar
  Widget _buildDefaultAvatar(user) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.7),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'U',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Get Greeting based on time of day
  String _getGreeting(String name) {
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
    } else if (hour >= 17) {
      greeting = 'Good Evening';
    }
    return '$greeting ($name)';
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthCubit>().logout();
              },
              child: Text(
                'Logout',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build Today's Attendance Card
  Widget _buildTodayAttendanceCard(BuildContext context, status) {
    final hasActiveSession = status?.hasActiveSession ?? false;

    // If has active session, show counter card
    if (hasActiveSession) {
      return CheckInCounterCard(status: status);
    }

    // Otherwise, show check-in card with status
    return CheckInCard(status: status);
  }

}
