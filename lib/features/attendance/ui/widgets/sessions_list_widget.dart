import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../logic/cubit/attendance_cubit.dart';
import '../../logic/cubit/attendance_state.dart';
import '../../data/models/attendance_session_model.dart';

/// Sessions List Widget
///
/// Displays all check-in/check-out sessions for today
/// Supports multiple sessions per day
class SessionsListWidget extends StatelessWidget {
  const SessionsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendanceCubit, AttendanceState>(
      builder: (context, state) {
        if (state is SessionsLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is SessionsLoaded) {
          final sessions = state.sessionsData.sessions;

          if (sessions.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              // Summary Card
              _buildSummaryCard(state.sessionsData),

              const SizedBox(height: 16),

              // Sessions List
              ...sessions.map((session) => _buildSessionCard(session)).toList(),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// Build Empty State
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.access_time,
            size: 48,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No Sessions Today',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your first session by checking in',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build Summary Card
  Widget _buildSummaryCard(TodaySessionsDataModel sessionsData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.success.withOpacity(0.1),
            AppColors.info.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Work Duration
          Expanded(
            child: _buildSummaryItem(
              icon: Icons.work_outline,
              label: 'Total Work',
              value: sessionsData.summary.totalDuration,
              color: AppColors.success,
            ),
          ),

          Container(
            width: 1,
            height: 40,
            color: AppColors.border,
          ),

          // Total Hours
          Expanded(
            child: _buildSummaryItem(
              icon: Icons.access_time,
              label: 'Total Hours',
              value: sessionsData.summary.formattedHours,
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  /// Build Summary Item
  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Build Session Card
  Widget _buildSessionCard(AttendanceSessionModel session) {
    final isActive = session.active;
    final color = _getSessionColor(session.sessionType ?? 'regular', isActive);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? color : AppColors.border,
          width: isActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? color.withOpacity(0.15)
                : AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getSessionIcon(session.sessionType ?? 'regular', isActive),
              color: color,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // Session Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      session.sessionTypeDisplay,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'ACTIVE',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(session.checkInTime) +
                      (session.checkOutTime != null
                          ? ' - ${_formatTime(session.checkOutTime!)}'
                          : ' - Active'),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Duration
          if (session.durationLabel != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                session.durationLabel!,
                style: AppTextStyles.labelMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Get Session Color
  Color _getSessionColor(String sessionType, bool isActive) {
    if (isActive) {
      return AppColors.success;
    }

    switch (sessionType) {
      case 'work':
        return AppColors.success;
      case 'break':
        return AppColors.warning;
      case 'permission':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Get Session Icon
  IconData _getSessionIcon(String sessionType, bool isActive) {
    if (isActive) {
      return Icons.play_circle_filled;
    }

    switch (sessionType) {
      case 'work':
        return Icons.work;
      case 'break':
        return Icons.coffee;
      case 'permission':
        return Icons.door_front_door;
      default:
        return Icons.access_time;
    }
  }

  /// Format Time
  String _formatTime(String time) {
    try {
      final dateTime = DateTime.parse('2000-01-01 $time');
      return DateFormat('h:mm a').format(dateTime);
    } catch (e) {
      return time;
    }
  }
}
