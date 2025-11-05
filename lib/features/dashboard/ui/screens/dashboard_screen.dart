import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../auth/logic/cubit/auth_cubit.dart';
import '../../../auth/logic/cubit/auth_state.dart';
import '../../../auth/ui/screens/login_screen.dart';
import '../../../attendance/logic/cubit/attendance_cubit.dart';
import '../../../attendance/logic/cubit/attendance_state.dart';
import '../../../attendance/ui/screens/attendance_history_screen.dart';
import '../../../notifications/ui/screens/notifications_screen.dart';
import '../../../profile/ui/screens/profile_screen.dart';
import '../../../leave/ui/screens/apply_leave_screen.dart';
import '../../../leave/ui/screens/leave_history_screen.dart';
import '../../../leave/ui/screens/leave_balance_screen.dart';
import '../../../work_schedule/ui/screens/work_schedule_screen.dart';
import '../../../reports/ui/screens/monthly_report_screen.dart';
import '../../../settings/ui/screens/settings_screen.dart';
import '../../../about/ui/screens/about_screen.dart';
import '../../logic/cubit/dashboard_cubit.dart';
import '../../logic/cubit/dashboard_state.dart';

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

  @override
  void initState() {
    super.initState();
    _dashboardCubit = DashboardCubit();
    _attendanceCubit = AttendanceCubit();
    // Fetch dashboard stats and attendance status when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _dashboardCubit.fetchDashboardStats();
        _attendanceCubit.fetchTodayStatus();
      }
    });
  }

  @override
  void dispose() {
    _dashboardCubit.close();
    _attendanceCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _dashboardCubit),
        BlocProvider.value(value: _attendanceCubit),
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
              } else if (attendanceState is CheckOutSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(attendanceState.attendance.message ?? 'Checked out successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
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
              // Show loading state
              if (dashboardState is DashboardLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // Show error state
              if (dashboardState is DashboardError) {
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
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dashboardState.displayMessage,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
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

              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<DashboardCubit>().refresh();
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Overview Stats - Responsive Grid
                          _buildOverviewSection(stats, constraints),

                          const SizedBox(height: 24),

                          // Attendance Status Card
                          BlocBuilder<AttendanceCubit, AttendanceState>(
                            builder: (context, attendanceState) {
                              final status = attendanceState is AttendanceStatusLoaded
                                  ? attendanceState.status
                                  : null;
                              return _buildAttendanceStatusCard(context, status);
                            },
                          ),

                          const SizedBox(height: 24),

                          // Performance Metrics
                          _buildPerformanceSection(stats),

                          const SizedBox(height: 24),

                          // Recent Activity
                          _buildRecentActivitySection(stats),

                          const SizedBox(height: 24),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
            ),
          );
        },
      ),
    );
  }

  // Overview Section
  Widget _buildOverviewSection(stats, BoxConstraints constraints) {
    final isWide = constraints.maxWidth > 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Responsive grid
        isWide
            ? Row(
                children: [
                  Expanded(child: _buildStatCard(Icons.calendar_today, 'Attendance', stats?.attendance.percentageFormatted ?? '-', AppColors.success, '📊')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(Icons.beach_access, 'Leave Balance', stats?.leaveBalance.daysFormatted ?? '-', AppColors.info, '🏖️')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(Icons.access_time, 'Hours', stats?.hoursThisMonth.hoursFormatted ?? '-', AppColors.warning, '⏱️')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(Icons.task_alt, 'Tasks', stats?.pendingTasks.countFormatted ?? '-', AppColors.error, '✅')),
                ],
              )
            : Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildStatCard(Icons.calendar_today, 'Attendance', stats?.attendance.percentageFormatted ?? '-', AppColors.success, '📊')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard(Icons.beach_access, 'Leave Balance', stats?.leaveBalance.daysFormatted ?? '-', AppColors.info, '🏖️')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard(Icons.access_time, 'Hours', stats?.hoursThisMonth.hoursFormatted ?? '-', AppColors.warning, '⏱️')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard(Icons.task_alt, 'Tasks', stats?.pendingTasks.countFormatted ?? '-', AppColors.error, '✅')),
                    ],
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value, Color color, String emoji) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.15),
                      color.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 18)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                value,
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Attendance Status Card
  Widget _buildAttendanceStatusCard(BuildContext context, status) {
    final hasCheckedIn = status?.hasCheckedIn ?? false;
    final hasCheckedOut = status?.hasCheckedOut ?? false;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: hasCheckedIn
              ? [AppColors.success, AppColors.success.withOpacity(0.8)]
              : [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (hasCheckedIn ? AppColors.success : AppColors.primary).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Attendance',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hasCheckedIn
                          ? (hasCheckedOut ? 'Checked Out' : 'Checked In')
                          : 'Not Checked In',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                hasCheckedIn
                    ? (hasCheckedOut ? Icons.check_circle : Icons.access_time)
                    : Icons.radio_button_unchecked,
                color: AppColors.white,
                size: 48,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: hasCheckedIn
                      ? null
                      : () => context.read<AttendanceCubit>().checkIn(),
                  icon: Icon(
                    Icons.login,
                    size: 20,
                    color: hasCheckedIn
                        ? AppColors.textDisabled
                        : AppColors.success,
                  ),
                  label: Text(
                    'Check In',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: hasCheckedIn
                          ? AppColors.textDisabled
                          : AppColors.success,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasCheckedIn
                        ? AppColors.border.withOpacity(0.3)
                        : AppColors.white,
                    foregroundColor: hasCheckedIn
                        ? AppColors.textDisabled
                        : AppColors.success,
                    disabledBackgroundColor: AppColors.border.withOpacity(0.3),
                    disabledForegroundColor: AppColors.textDisabled,
                    elevation: hasCheckedIn ? 0 : 2,
                    shadowColor: AppColors.success.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: hasCheckedIn
                            ? AppColors.border
                            : AppColors.success.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (hasCheckedIn && !hasCheckedOut)
                      ? () => context.read<AttendanceCubit>().checkOut()
                      : null,
                  icon: Icon(
                    Icons.logout,
                    size: 20,
                    color: (hasCheckedIn && !hasCheckedOut)
                        ? AppColors.error
                        : AppColors.textSecondary,
                  ),
                  label: Text(
                    'Check Out',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: (hasCheckedIn && !hasCheckedOut)
                          ? AppColors.error
                          : AppColors.textSecondary,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (hasCheckedIn && !hasCheckedOut)
                        ? AppColors.white
                        : AppColors.backgroundAlt,
                    foregroundColor: (hasCheckedIn && !hasCheckedOut)
                        ? AppColors.error
                        : AppColors.textSecondary,
                    disabledBackgroundColor: AppColors.backgroundAlt,
                    disabledForegroundColor: AppColors.textSecondary,
                    elevation: (hasCheckedIn && !hasCheckedOut) ? 2 : 0,
                    shadowColor: AppColors.error.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: (hasCheckedIn && !hasCheckedOut)
                            ? AppColors.error.withOpacity(0.3)
                            : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Performance Section
  Widget _buildPerformanceSection(stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Metrics',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildProgressBar(
            'Attendance Rate',
            stats?.attendance.percentageFormatted ?? '0%',
            AppColors.success,
            (stats?.attendance.percentage ?? 0) / 100,
          ),
          const SizedBox(height: 16),
          _buildProgressBar(
            'Task Completion',
            '${stats?.performance.taskCompletion.percentage ?? 0}%',
            AppColors.info,
            stats?.performance.taskCompletion.value ?? 0.0,
          ),
          const SizedBox(height: 16),
          _buildProgressBar(
            'Monthly Goals',
            '${stats?.performance.monthlyGoals.percentage ?? 0}%',
            AppColors.warning,
            stats?.performance.monthlyGoals.value ?? 0.0,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, String value, Color color, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // Recent Activity Section
  Widget _buildRecentActivitySection(stats) {
    final recentActivities = stats?.charts.attendanceTrend.take(5).toList() ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (recentActivities.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No recent activity',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            ...recentActivities.asMap().entries.map((entry) {
              final index = entry.key;
              final activity = entry.value;

              // Map status to icon and color
              IconData icon;
              Color color;
              String statusText;

              switch (activity.status.toLowerCase()) {
                case 'present':
                  icon = Icons.check_circle;
                  color = AppColors.success;
                  statusText = 'Present - ${activity.hours.toStringAsFixed(1)}h';
                  break;
                case 'absent':
                  icon = Icons.cancel;
                  color = AppColors.error;
                  statusText = 'Absent';
                  break;
                case 'late':
                  icon = Icons.schedule;
                  color = AppColors.warning;
                  statusText = 'Late - ${activity.hours.toStringAsFixed(1)}h';
                  break;
                case 'half_day':
                  icon = Icons.access_time;
                  color = AppColors.info;
                  statusText = 'Half Day - ${activity.hours.toStringAsFixed(1)}h';
                  break;
                default:
                  icon = Icons.circle;
                  color = AppColors.textSecondary;
                  statusText = activity.status;
              }

              return Column(
                children: [
                  if (index > 0) const SizedBox(height: 12),
                  _buildActivityItem(
                    icon,
                    statusText,
                    '${activity.day} - ${activity.date}',
                    color,
                  ),
                ],
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildActivityItem(IconData icon, String title, String time, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                time,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
}
