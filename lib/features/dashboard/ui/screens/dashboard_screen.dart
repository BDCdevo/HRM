import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/logic/cubit/auth_cubit.dart';
import '../../../auth/logic/cubit/auth_state.dart';
import '../../../auth/ui/screens/login_screen.dart';
import '../../../attendance/logic/cubit/attendance_cubit.dart';
import '../../../attendance/logic/cubit/attendance_state.dart';
import '../../../attendance/ui/screens/attendance_main_screen.dart';
import '../../../attendance/ui/screens/attendance_summary_screen.dart';
import '../../../notifications/logic/cubit/notifications_cubit.dart';
import '../../../profile/logic/cubit/profile_cubit.dart';
import '../../../profile/logic/cubit/profile_state.dart';
import '../../logic/cubit/dashboard_cubit.dart';
import '../../logic/cubit/dashboard_state.dart';
import '../../logic/cubit/weekly_stats_cubit.dart';
import '../../logic/cubit/weekly_stats_state.dart';
import '../widgets/services_grid_widget.dart';
import '../widgets/weekly_performance_gauge.dart';

/// Dashboard Screen - Clean Flat Design (Like Reference)
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
  late final WeeklyStatsCubit _weeklyStatsCubit;

  @override
  void initState() {
    super.initState();
    _dashboardCubit = DashboardCubit();
    _attendanceCubit = AttendanceCubit();
    _notificationsCubit = NotificationsCubit();
    _profileCubit = ProfileCubit();
    _weeklyStatsCubit = WeeklyStatsCubit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _dashboardCubit.fetchDashboardStats();
        _attendanceCubit.fetchTodayStatus();
        _notificationsCubit.fetchNotifications();
        _profileCubit.fetchProfile();
        _weeklyStatsCubit.fetchWeeklyStats();
      }
    });
  }

  @override
  void dispose() {
    _dashboardCubit.close();
    _attendanceCubit.close();
    _notificationsCubit.close();
    _profileCubit.close();
    _weeklyStatsCubit.close();
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
        BlocProvider.value(value: _weeklyStatsCubit),
      ],
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = authState.user;

          return BlocListener<AttendanceCubit, AttendanceState>(
            listener: (context, attendanceState) {
              if (attendanceState is CheckInSuccess) {
                _showSuccessSnackBar(context, attendanceState.attendance.message ?? 'Checked in successfully');
                _attendanceCubit.fetchTodayStatus();
              } else if (attendanceState is CheckOutSuccess) {
                _showSuccessSnackBar(context, attendanceState.attendance.message ?? 'Checked out successfully');
                _attendanceCubit.fetchTodayStatus();
              } else if (attendanceState is AttendanceError) {
                _showErrorSnackBar(context, attendanceState.displayMessage);
              }
            },
            child: BlocConsumer<DashboardCubit, DashboardState>(
              listener: (context, dashboardState) {
                if (dashboardState.hasError && dashboardState.displayError != null) {
                  _showErrorSnackBar(context, dashboardState.displayError!, showRetry: true);
                }
              },
              builder: (context, dashboardState) {
                final isDark = Theme.of(context).brightness == Brightness.dark;

                if (dashboardState.isLoading && !dashboardState.hasData) {
                  return Scaffold(
                    backgroundColor: isDark ? AppColors.darkBackground : AppColors.white,
                    body: const DashboardSkeleton(),
                  );
                }

                return Scaffold(
                  backgroundColor: isDark ? AppColors.darkBackground : AppColors.white,
                  body: SafeArea(
                    child: RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async {
                        await context.read<DashboardCubit>().refresh();
                        _attendanceCubit.fetchTodayStatus();
                        _profileCubit.fetchProfile();
                        _weeklyStatsCubit.fetchWeeklyStats();
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),

                            // Greeting + Animation in Stack (like reference)
                            BlocBuilder<AttendanceCubit, AttendanceState>(
                              builder: (context, attendanceState) {
                                final status = attendanceState is AttendanceStatusLoaded
                                    ? attendanceState.status
                                    : null;
                                return _buildGreetingWithAnimation(context, user, status, isDark, _attendanceCubit);
                              },
                            ),

                            const SizedBox(height: 16),

                            // Team Attendance (Manager/HR only) OR Weekly Performance (Regular employees)
                            BlocBuilder<ProfileCubit, ProfileState>(
                              builder: (context, profileState) {
                                final profile = profileState is ProfileLoaded ? profileState.profile : null;
                                final canManage = user.canManageEmployees || _isManagerFromProfile(profile);

                                if (canManage) {
                                  // Managers/HR see Team Attendance
                                  final stats = dashboardState is DashboardLoaded
                                      ? dashboardState.stats
                                      : dashboardState.previousStats;

                                  return _buildTeamAttendanceCard(
                                    context,
                                    stats?.todayPresent ?? 0,
                                    stats?.todayAbsent ?? 0,
                                    stats?.todayCheckedOut ?? 0,
                                    isDark,
                                  );
                                } else {
                                  // Regular employees see Weekly Performance Gauge
                                  return BlocBuilder<WeeklyStatsCubit, WeeklyStatsState>(
                                    builder: (context, weeklyState) {
                                      double weeklyHours = 0.0;
                                      double targetHours = 48.0;

                                      if (weeklyState is WeeklyStatsLoaded) {
                                        // Use data from API
                                        weeklyHours = weeklyState.stats.totalHours;
                                        targetHours = weeklyState.stats.targetHours;
                                      } else if (weeklyState is WeeklyStatsLoading) {
                                        // Show loading state - use 0 hours
                                        weeklyHours = 0.0;
                                      }

                                      return WeeklyPerformanceGauge(
                                        hoursWorked: weeklyHours,
                                        targetHours: targetHours,
                                      );
                                    },
                                  );
                                }
                              },
                            ),

                            const SizedBox(height: 24),

                            // Services Section
                            ServicesGridWidget(
                              onAttendanceReturn: () {
                                _attendanceCubit.fetchTodayStatus();
                              },
                            ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
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

  /// Build Greeting + Animation + Check-in in ONE Stack
  Widget _buildGreetingWithAnimation(BuildContext context, UserModel user, dynamic status, bool isDark, AttendanceCubit attendanceCubit) {
    return SizedBox(
      height: 340,  // Height for avatar + card + animation overlap
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Check-in Card at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildCheckInCard(context, status, isDark, attendanceCubit),
          ),

          // Avatar with yellow border - top left
          Positioned(
            left: 0,
            top: 0,
            child: BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, profileState) {
                final profile = profileState is ProfileLoaded ? profileState.profile : null;
                return Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.backgroundLight,
                    backgroundImage: profile != null && profile.hasImage
                        ? NetworkImage(profile.image!.url)
                        : null,
                    child: profile == null || !profile.hasImage
                        ? Text(
                            user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'U',
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),

          // Greeting + Name - next to avatar
          Positioned(
            left: 92,  // After avatar (78 + spacing)
            top: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getGreetingMessage(),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.firstName,
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: isDark ? AppColors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),

          // Animation on the right - overlapping card
          Positioned(
            right: -20,
            top: -50,
            child: Transform.flip(
              flipX: true,
              child: Lottie.asset(
                'assets/animations/home_anmation.json',
                height: 200,
                width: 240,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Notification bell - aligned with girl's head (top right area)
          Positioned(
            right: 8,
            top: 0,  // Same level as top of animation (girl's head area)
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed('/notifications');
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.backgroundLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Parse duration string (HH:MM:SS) to hours as double
  double _parseDurationToHours(String? durationStr) {
    if (durationStr == null || durationStr.isEmpty || durationStr == '00:00:00') {
      return 0.0;
    }

    try {
      final parts = durationStr.split(':');
      if (parts.length >= 2) {
        final hours = int.tryParse(parts[0]) ?? 0;
        final minutes = int.tryParse(parts[1]) ?? 0;
        final seconds = parts.length > 2 ? (int.tryParse(parts[2]) ?? 0) : 0;

        return hours + (minutes / 60) + (seconds / 3600);
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return 0.0;
  }

  /// Format time to 12-hour format (HH:MM AM/PM)
  String _formatTimeTo12Hour(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '--:--';

    try {
      // Handle different time formats
      String time = timeStr;

      // If it contains date, extract time part
      if (time.contains(' ')) {
        time = time.split(' ').last;
      }

      // Parse hours and minutes
      final parts = time.split(':');
      if (parts.length < 2) return '--:--';

      int hours = int.parse(parts[0]);
      final minutes = parts[1].padLeft(2, '0');

      // Convert to 12-hour format
      final period = hours >= 12 ? 'PM' : 'AM';
      hours = hours % 12;
      if (hours == 0) hours = 12;

      return '$hours:$minutes $period';
    } catch (e) {
      return '--:--';
    }
  }

  /// Build Check-in Card - Like Reference (Yellow top + Black bottom)
  Widget _buildCheckInCard(BuildContext context, dynamic status, bool isDark, AttendanceCubit attendanceCubit) {
    final hasActiveSession = status?.hasActiveSession ?? false;

    // Debug: Print all status data
    if (status != null) {
      print('📊 Dashboard Card - Status Data:');
      print('   checkInTime: ${status.checkInTime}');
      print('   checkOutTime: ${status.checkOutTime}');
      print('   workingHours: ${status.workingHours}');
      print('   duration: ${status.duration}');
      print('   hasActiveSession: ${status.hasActiveSession}');
      print('   totalHours (getter): ${status.totalHours}');
      print('   dailySummary?.workingHours: ${status.dailySummary?.workingHours}');
      print('   dailySummary?.checkInTime: ${status.dailySummary?.checkInTime}');
      print('   dailySummary?.checkOutTime: ${status.dailySummary?.checkOutTime}');
      print('   currentSession?.duration: ${status.currentSession?.duration}');
      print('   sessionsSummary?.totalHours: ${status.sessionsSummary?.totalHours}');
      print('   sessionsSummary?.totalDuration: ${status.sessionsSummary?.totalDuration}');
    }

    // Get check in time - try multiple sources
    String rawCheckInTime = '';
    if (status?.checkInTime != null && status.checkInTime.toString().isNotEmpty) {
      rawCheckInTime = status.checkInTime.toString();
    } else if (status?.dailySummary?.checkInTime != null && status.dailySummary.checkInTime.toString().isNotEmpty) {
      rawCheckInTime = status.dailySummary.checkInTime.toString();
    } else if (status?.currentSession?.checkInTime != null && status.currentSession.checkInTime.toString().isNotEmpty) {
      rawCheckInTime = status.currentSession.checkInTime.toString();
    }

    // Get check out time
    String rawCheckOutTime = '';
    if (status?.checkOutTime != null && status.checkOutTime.toString().isNotEmpty) {
      rawCheckOutTime = status.checkOutTime.toString();
    } else if (status?.dailySummary?.checkOutTime != null && status.dailySummary.checkOutTime.toString().isNotEmpty) {
      rawCheckOutTime = status.dailySummary.checkOutTime.toString();
    }

    // Format to 12-hour
    final checkInTime = _formatTimeTo12Hour(rawCheckInTime);
    final checkOutTime = _formatTimeTo12Hour(rawCheckOutTime);

    // Determine if user has checked out (not active session and has check out time)
    final hasCheckedOut = !hasActiveSession && rawCheckOutTime.isNotEmpty;

    // Get total working hours - prioritize sessionsSummary.totalHours for accurate total
    double workingHours = 0.0;

    // First try sessionsSummary.totalHours (most accurate for total hours across all sessions)
    if (status?.sessionsSummary?.totalHours != null && status.sessionsSummary.totalHours > 0) {
      workingHours = status.sessionsSummary.totalHours is double
          ? status.sessionsSummary.totalHours
          : double.tryParse(status.sessionsSummary.totalHours.toString()) ?? 0.0;
    }
    // Then try the totalHours getter (which already does sessionsSummary?.totalHours ?? workingHours)
    else if (status?.totalHours != null && status.totalHours > 0) {
      workingHours = status.totalHours;
    }
    // Then try workingHours directly
    else if (status?.workingHours != null && status.workingHours > 0) {
      workingHours = status.workingHours is double
          ? status.workingHours
          : double.tryParse(status.workingHours.toString()) ?? 0.0;
    }
    // Then try dailySummary
    else if (status?.dailySummary?.workingHours != null && status.dailySummary.workingHours > 0) {
      workingHours = status.dailySummary.workingHours is double
          ? status.dailySummary.workingHours
          : double.tryParse(status.dailySummary.workingHours.toString()) ?? 0.0;
    }
    // Then try duration string (format: "HH:MM:SS")
    else if (status?.duration != null && status.duration.toString().isNotEmpty && status.duration != '00:00:00') {
      workingHours = _parseDurationToHours(status.duration.toString());
    }
    // Try totalDuration from sessionsSummary
    else if (status?.sessionsSummary?.totalDuration != null) {
      workingHours = _parseDurationToHours(status.sessionsSummary.totalDuration);
    }
    // Try currentSession duration
    else if (status?.currentSession?.duration != null) {
      workingHours = _parseDurationToHours(status.currentSession.duration.toString());
    }

    // Format hours nicely (e.g., "2.5h" or "0h")
    final totalHoursDisplay = workingHours > 0 ? workingHours.toStringAsFixed(1) : '0';

    return GestureDetector(
      onTap: () async {
        // Navigate to attendance and refresh status when returning
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AttendanceMainScreen()),
        );
        // Refresh attendance status when coming back from attendance screen
        attendanceCubit.fetchTodayStatus();
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary, // Always yellow
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // TOP SECTION - Yellow with stats (like reference)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header row - Icon + Title + Toggle
                  Row(
                    children: [
                      // Icon
                      Icon(
                        hasActiveSession ? Icons.timer : Icons.fingerprint_rounded,
                        color: AppColors.textPrimary,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      // Title
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasActiveSession ? 'Working' : 'Attendance',
                              style: AppTextStyles.titleLarge.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              hasActiveSession ? 'Session active' : 'Track your time',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textPrimary.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Toggle/Status indicator - Black style matching yellow card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: hasActiveSession
                              ? AppColors.textPrimary
                              : AppColors.textPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              hasActiveSession ? 'ON' : 'OFF',
                              style: TextStyle(
                                color: hasActiveSession ? AppColors.white : AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: hasActiveSession ? AppColors.white : AppColors.textPrimary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Progress Bar - Only show when session is active (checked in)
                  if (hasActiveSession)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress bar with animation
                        Container(
                          height: 6,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: (workingHours / 8).clamp(0.0, 1.0)),
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      width: constraints.maxWidth * value,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${totalHoursDisplay}h / 8h',
                              style: TextStyle(
                                color: AppColors.textPrimary.withOpacity(0.6),
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              workingHours >= 8 ? 'Completed!' : '${(8 - workingHours).toStringAsFixed(1)}h left',
                              style: TextStyle(
                                color: AppColors.textPrimary.withOpacity(0.6),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),

                  if (!hasActiveSession)
                    const SizedBox(height: 4),

                  // Stats row - like reference (3 columns)
                  Row(
                    children: [
                      // Check In / Check Out Time - Shows check out time when user has checked out
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasCheckedOut ? 'Check Out' : 'Check In',
                              style: TextStyle(
                                color: AppColors.textPrimary.withOpacity(0.6),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hasCheckedOut ? checkOutTime : checkInTime,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Hours Today
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hours',
                              style: TextStyle(
                                color: AppColors.textPrimary.withOpacity(0.6),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${totalHoursDisplay}h',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status',
                              style: TextStyle(
                                color: AppColors.textPrimary.withOpacity(0.6),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hasActiveSession ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // BOTTOM SECTION - Black bar with message (like reference)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              color: AppColors.textPrimary,
              child: Row(
                children: [
                  Icon(
                    hasActiveSession ? Icons.info_outline : Icons.touch_app_rounded,
                    color: AppColors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      hasActiveSession
                          ? 'Tap to check out and end your session'
                          : 'Tap to check in and start your day',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.white,
                    size: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Team Attendance Card - Grid of 4 simple cards (like reference)
  Widget _buildTeamAttendanceCard(
    BuildContext context,
    int present,
    int absent,
    int checkedOut,
    bool isDark,
  ) {
    final total = present + absent;
    final attendanceRate = total > 0 ? (present / total * 100).round() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Attendance",
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AttendanceSummaryScreen()),
              ),
              child: Text(
                'See All >',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Grid of 4 cards (2x2) like reference
        Row(
          children: [
            Expanded(
              child: _buildStatCard('Present', '$present', isDark),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard('Absent', '$absent', isDark),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard('Check out', '$checkedOut', isDark),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard('Rate', '$attendanceRate%', isDark),
            ),
          ],
        ),
      ],
    );
  }

  /// Build simple stat card like reference (light gray bg, label on top, value below)
  Widget _buildStatCard(String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Helper Methods
  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  bool _isManagerFromProfile(dynamic profile) {
    if (profile == null) return false;
    final position = profile.position?.toString().toLowerCase() ?? '';
    final department = profile.department?.toString().toLowerCase() ?? '';
    return position.contains('مدير') ||
        position.contains('manager') ||
        position.contains('supervisor') ||
        position.contains('رئيس') ||
        position.contains('head') ||
        department.contains('hr') ||
        department.contains('human') ||
        department.contains('موارد') ||
        department.contains('إدارة') ||
        department.contains('الإدارة');
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message, {bool showRetry = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(fontSize: 14))),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: showRetry
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () => context.read<DashboardCubit>().fetchDashboardStats(),
              )
            : null,
      ),
    );
  }
}
