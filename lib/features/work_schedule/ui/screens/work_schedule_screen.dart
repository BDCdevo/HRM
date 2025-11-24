import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../logic/cubit/work_schedule_cubit.dart';
import '../../logic/cubit/work_schedule_state.dart';
import '../widgets/work_schedule_skeleton.dart';

/// Work Schedule Screen
///
/// Displays employee's work schedule and shift information
class WorkScheduleScreen extends StatefulWidget {
  const WorkScheduleScreen({super.key});

  @override
  State<WorkScheduleScreen> createState() => _WorkScheduleScreenState();
}

class _WorkScheduleScreenState extends State<WorkScheduleScreen> {
  late final WorkScheduleCubit _workScheduleCubit;

  @override
  void initState() {
    super.initState();
    _workScheduleCubit = WorkScheduleCubit();
    _workScheduleCubit.fetchWorkSchedule();
  }

  @override
  void dispose() {
    _workScheduleCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.white,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Work Schedule',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.white,
          ),
        ),
      ),
      body: BlocBuilder<WorkScheduleCubit, WorkScheduleState>(
        bloc: _workScheduleCubit,
        builder: (context, state) {
          if (state is WorkScheduleLoading) {
            return const WorkScheduleSkeleton();
          }

          if (state is WorkScheduleError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _workScheduleCubit.fetchWorkSchedule(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is! WorkScheduleLoaded) {
            return const SizedBox.shrink();
          }

          final workSchedule = state.workSchedule;

          return RefreshIndicator(
            onRefresh: () => _workScheduleCubit.fetchWorkSchedule(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Summary Card
                  _buildSummaryCard(workSchedule),

                  const SizedBox(height: 24),

                  // Weekly Schedule
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly Schedule',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...workSchedule.weeklySchedule.entries.map((entry) {
                          final daySchedule = entry.value;
                          return _buildDayCard(
                            entry.key,
                            daySchedule.start,
                            daySchedule.end,
                            daySchedule.hours,
                            _isToday(entry.key),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Shift Information
                  _buildShiftInfo(workSchedule),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(dynamic workSchedule) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.access_time,
            size: 48,
            color: AppColors.white,
          ),
          const SizedBox(height: 16),
          Text(
            workSchedule.schedule.shiftType,
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${workSchedule.workPlan.startTime} - ${workSchedule.workPlan.endTime}',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSummaryItem('Work Days', '${workSchedule.schedule.workDaysCount}', Icons.calendar_today),
              const SizedBox(width: 32),
              _buildSummaryItem('Weekly Hours', workSchedule.schedule.weeklyHours, Icons.schedule),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.white.withValues(alpha: 0.9), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildDayCard(
      String day, String startTime, String endTime, String hours, bool isToday) {
    final isDayOff = startTime == 'Day Off';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isToday
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday
              ? AppColors.primary
              : (isDayOff
                  ? AppColors.textSecondary.withValues(alpha: 0.3)
                  : AppColors.border),
          width: isToday ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Day indicator
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isDayOff
                  ? AppColors.textSecondary.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  day.substring(0, 3).toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isDayOff ? AppColors.textSecondary : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isToday)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Time details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                if (!isDayOff) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.login,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        startTime,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.logout,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        endTime,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Text(
                    startTime,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Hours
          if (!isDayOff)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                hours,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShiftInfo(dynamic workSchedule) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Shift Information',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Shift Type', workSchedule.schedule.shiftType),
            const SizedBox(height: 12),
            _buildInfoRow('Break Time', workSchedule.schedule.breakTime),
            const SizedBox(height: 12),
            _buildInfoRow('Grace Period', '${workSchedule.workPlan.permissionMinutes} minutes'),
            const SizedBox(height: 12),
            _buildInfoRow('Weekly Hours', workSchedule.schedule.weeklyHours),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  bool _isToday(String day) {
    final now = DateTime.now();
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return weekdays[now.weekday - 1] == day;
  }
}
