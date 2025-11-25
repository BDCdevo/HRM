import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/logic/cubit/auth_cubit.dart';
import '../../../auth/logic/cubit/auth_state.dart';
import '../../../auth/ui/screens/login_screen.dart';
import '../../../attendance/logic/cubit/attendance_cubit.dart';
import '../../../attendance/logic/cubit/attendance_state.dart';
import '../../../notifications/ui/screens/notifications_screen.dart';
import '../../../notifications/logic/cubit/notifications_cubit.dart';
import '../../../notifications/logic/cubit/notifications_state.dart';
import '../../../profile/logic/cubit/profile_cubit.dart';
import '../../../profile/logic/cubit/profile_state.dart';
// import '../../../profile/ui/screens/profile_screen.dart'; // Removed - using More tab for profile
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
  late final ProfileCubit _profileCubit;

  @override
  void initState() {
    super.initState();
    _dashboardCubit = DashboardCubit();
    _attendanceCubit = AttendanceCubit();
    _notificationsCubit = NotificationsCubit();
    _profileCubit = ProfileCubit();
    // Fetch dashboard stats and attendance status when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _dashboardCubit.fetchDashboardStats();
        _attendanceCubit.fetchTodayStatus();
        _notificationsCubit.fetchNotifications();
        _profileCubit.fetchProfile(); // Fetch profile to get image
      }
    });
  }

  @override
  void dispose() {
    _dashboardCubit.close();
    _attendanceCubit.close();
    _notificationsCubit.close();
    _profileCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _dashboardCubit),
        BlocProvider.value(value: _attendanceCubit),
        BlocProvider.value(value: _notificationsCubit),
        BlocProvider.value(value: _profileCubit),
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
            child: BlocConsumer<DashboardCubit, DashboardState>(
              listener: (context, dashboardState) {
                // Show error as SnackBar instead of full screen
                if (dashboardState.hasError && dashboardState.displayError != null) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              dashboardState.displayError!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.error.withOpacity(0.9),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(seconds: 4),
                      action: SnackBarAction(
                        label: 'إعادة المحاولة',
                        textColor: Colors.white,
                        onPressed: () {
                          context.read<DashboardCubit>().fetchDashboardStats();
                        },
                      ),
                    ),
                  );
                }
              },
              builder: (context, dashboardState) {
              // Show skeleton ONLY on first load (no cached data)
              if (dashboardState.isLoading && !dashboardState.hasData) {
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
                    // Notification Bell with Avatar Background
                    BlocBuilder<NotificationsCubit, NotificationsState>(
                      builder: (context, notifState) {
                        final unreadCount = notifState is NotificationsLoaded
                            ? notifState.unreadCount
                            : 0;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.white.withOpacity(0.15),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  const Icon(Icons.notifications, color: AppColors.white, size: 22),
                                  // Badge for unread notifications (dynamic)
                                  if (unreadCount > 0)
                                    Positioned(
                                      right: -4,
                                      top: -4,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: AppColors.error,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 18,
                                          minHeight: 18,
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
                            ),
                          ),
                        );
                      },
                    ),
                    // User Profile Photo (with profile data)
                    BlocBuilder<ProfileCubit, ProfileState>(
                      builder: (context, profileState) {
                        final profile = profileState is ProfileLoaded
                            ? profileState.profile
                            : null;

                        return Padding(
                          padding: const EdgeInsets.only(right: 12, left: 8),
                          child: CircleAvatar(
                            backgroundColor: AppColors.white,
                            radius: 18,
                            child: profile != null && profile.hasImage
                                ? ClipOval(
                                    child: Image.network(
                                      profile.image!.url,
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
                        );
                      },
                    ),
                  ],
                ),
                body: RefreshIndicator(
                  onRefresh: () async {
                    await context.read<DashboardCubit>().refresh();
                    _attendanceCubit.fetchTodayStatus();
                    _profileCubit.fetchProfile(); // Refresh profile image
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
                                        _getGreeting(),
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.white.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        user.fullName,
                                        style: AppTextStyles.headlineMedium.copyWith(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Refresh Icon with loading indicator
                                  dashboardState.isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.white,
                                          ),
                                        )
                                      : IconButton(
                                          icon: const Icon(Icons.refresh, color: AppColors.white, size: 24),
                                          onPressed: () {
                                            context.read<DashboardCubit>().refresh();
                                            _attendanceCubit.fetchTodayStatus();
                                          },
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
                                Builder(
                                  builder: (context) {
                                    // Use stats from current or previous state
                                    final currentStats = dashboardState.previousStats;

                                    // Use stats from API or default values
                                    final presentCount = currentStats?.todayPresent ?? 0;
                                    final absentCount = currentStats?.todayAbsent ?? 0;
                                    final checkedOutCount = currentStats?.todayCheckedOut ?? 0;

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
  Widget _buildDefaultAvatar(UserModel user) {
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
  String _getGreeting() {
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
    } else if (hour >= 17) {
      greeting = 'Good Evening';
    }
    return '$greeting ';
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
  Widget _buildTodayAttendanceCard(BuildContext context, dynamic status) {
    final hasActiveSession = status?.hasActiveSession ?? false;

    // If has active session, show counter card
    if (hasActiveSession) {
      return CheckInCounterCard(status: status);
    }

    // Otherwise, show check-in card with status
    return CheckInCard(status: status);
  }

}
