import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../logic/cubit/attendance_history_cubit.dart';
import '../../logic/cubit/attendance_history_state.dart';

/// Attendance History Widget
///
/// Displays attendance history with filters
class AttendanceHistoryWidget extends StatefulWidget {
  const AttendanceHistoryWidget({super.key});

  @override
  State<AttendanceHistoryWidget> createState() => _AttendanceHistoryWidgetState();
}

class _AttendanceHistoryWidgetState extends State<AttendanceHistoryWidget> {
  late AttendanceHistoryCubit _historyCubit;

  @override
  void initState() {
    super.initState();
    _historyCubit = AttendanceHistoryCubit();
    _historyCubit.fetchHistory();
  }

  @override
  void dispose() {
    _historyCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _historyCubit,
      child: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.white,
            child: Row(
              children: [
                Expanded(
                  child: _FilterChip(
                    label: 'This Month',
                    isSelected: true,
                    onTap: () {
                      // TODO: Filter by this month
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FilterChip(
                    label: 'Last Month',
                    isSelected: false,
                    onTap: () {
                      // TODO: Filter by last month
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FilterChip(
                    label: 'Custom',
                    isSelected: false,
                    onTap: () {
                      // TODO: Show date picker
                    },
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: BlocBuilder<AttendanceHistoryCubit, AttendanceHistoryState>(
              builder: (context, state) {
                if (state is AttendanceHistoryLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is AttendanceHistoryError) {
                  return Center(
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
                          'Error loading history',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.displayMessage,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _historyCubit.fetchHistory(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is AttendanceHistoryLoaded) {
                  if (state.records.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No attendance records',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => _historyCubit.refresh(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: state.records.length,
                      itemBuilder: (context, index) {
                        final record = state.records[index];

                        // Parse date
                        DateTime date;
                        try {
                          date = DateTime.parse(record.date);
                        } catch (e) {
                          date = DateTime.now();
                        }

                        return _AttendanceHistoryItem(
                          date: date,
                          isPresent: record.checkInTime != null,
                          checkIn: record.checkInTime != null ? _formatTime(record.checkInTime!) : null,
                          checkOut: record.checkOutTime != null ? _formatTime(record.checkOutTime!) : null,
                          workingHours: record.workingHoursLabel,
                          lateMinutes: record.lateMinutes,
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Format time string (HH:MM:SS) to (HH:MM AM/PM)
  String _formatTime(String time) {
    try {
      // Try parsing different time formats
      DateTime? dateTime;

      // Format: "HH:MM:SS" or "HH:MM"
      if (time.contains(':')) {
        final parts = time.split(':');
        if (parts.length >= 2) {
          final hour = int.tryParse(parts[0]) ?? 0;
          final minute = int.tryParse(parts[1]) ?? 0;
          dateTime = DateTime(2000, 1, 1, hour, minute);
        }
      }

      if (dateTime != null) {
        return DateFormat('hh:mm a').format(dateTime);
      }

      return time;
    } catch (e) {
      return time;
    }
  }
}

/// Filter Chip
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.success
              : AppColors.border.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Attendance History Item
class _AttendanceHistoryItem extends StatelessWidget {
  final DateTime date;
  final bool isPresent;
  final String? checkIn;
  final String? checkOut;
  final String? workingHours;
  final int lateMinutes;

  const _AttendanceHistoryItem({
    required this.date,
    required this.isPresent,
    this.checkIn,
    this.checkOut,
    this.workingHours,
    this.lateMinutes = 0,
  });

  @override
  Widget build(BuildContext context) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPresent
              ? AppColors.border.withOpacity(0.3)
              : AppColors.error.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // TODO: Show attendance details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Date Badge
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isPresent
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      dayNames[date.weekday - 1],
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isPresent ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: isPresent ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      monthNames[date.month - 1],
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isPresent ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isPresent ? Icons.check_circle : Icons.cancel,
                          color: isPresent ? AppColors.success : AppColors.error,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isPresent ? 'Present' : 'Absent',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color:
                                isPresent ? AppColors.success : AppColors.error,
                          ),
                        ),
                        if (lateMinutes > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Late $lateMinutes min',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (isPresent) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.login,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            checkIn ?? '--:--',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.logout,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            checkOut ?? '--:--',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            workingHours ?? '--',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.chevron_right,
                color: AppColors.iconSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
