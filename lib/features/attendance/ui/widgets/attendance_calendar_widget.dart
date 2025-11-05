import 'package:flutter/material.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';

/// Attendance Calendar Widget
///
/// Displays attendance in calendar view
class AttendanceCalendarWidget extends StatefulWidget {
  const AttendanceCalendarWidget({super.key});

  @override
  State<AttendanceCalendarWidget> createState() =>
      _AttendanceCalendarWidgetState();
}

class _AttendanceCalendarWidgetState extends State<AttendanceCalendarWidget> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Month Selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: AppColors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(
                      _focusedMonth.year,
                      _focusedMonth.month - 1,
                    );
                  });
                },
              ),
              Text(
                _getMonthYearString(_focusedMonth),
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(
                      _focusedMonth.year,
                      _focusedMonth.month + 1,
                    );
                  });
                },
              ),
            ],
          ),
        ),

        // Calendar
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Week Days Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                        .map((day) => SizedBox(
                              width: 40,
                              child: Text(
                                day,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ))
                        .toList(),
                  ),
                ),

                // Calendar Grid
                _buildCalendarGrid(),

                const SizedBox(height: 24),

                // Legend
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
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
                        'Legend',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _LegendItem(
                        color: AppColors.success,
                        label: 'Present',
                      ),
                      const SizedBox(height: 8),
                      _LegendItem(
                        color: AppColors.error,
                        label: 'Absent',
                      ),
                      const SizedBox(height: 8),
                      _LegendItem(
                        color: AppColors.warning,
                        label: 'Late',
                      ),
                      const SizedBox(height: 8),
                      _LegendItem(
                        color: AppColors.info,
                        label: 'Leave',
                      ),
                      const SizedBox(height: 8),
                      _LegendItem(
                        color: AppColors.border,
                        label: 'Weekend/Holiday',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build Calendar Grid
  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startingWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    final List<Widget> dayWidgets = [];

    // Add empty cells for days before the first day of month
    for (int i = 1; i < startingWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 40, height: 40));
    }

    // Add cells for each day of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final isWeekend = date.weekday == 6 || date.weekday == 7;

      // Mock attendance status - replace with actual data
      final AttendanceStatus status = _getMockStatus(day, isWeekend);

      dayWidgets.add(_CalendarDay(
        day: day,
        status: status,
        isSelected: _isSameDay(date, _selectedDate),
        onTap: () {
          setState(() {
            _selectedDate = date;
          });
        },
      ));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: dayWidgets,
    );
  }

  /// Get Mock Status
  AttendanceStatus _getMockStatus(int day, bool isWeekend) {
    if (isWeekend) return AttendanceStatus.weekend;
    if (day % 7 == 0) return AttendanceStatus.absent;
    if (day % 5 == 0) return AttendanceStatus.late;
    if (day % 9 == 0) return AttendanceStatus.leave;
    return AttendanceStatus.present;
  }

  /// Check if Same Day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Get Month Year String
  String _getMonthYearString(DateTime date) {
    const months = [
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
    return '${months[date.month - 1]} ${date.year}';
  }
}

/// Attendance Status Enum
enum AttendanceStatus {
  present,
  absent,
  late,
  leave,
  weekend,
}

/// Calendar Day
class _CalendarDay extends StatelessWidget {
  final int day;
  final AttendanceStatus status;
  final bool isSelected;
  final VoidCallback onTap;

  const _CalendarDay({
    required this.day,
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  Color _getColor() {
    switch (status) {
      case AttendanceStatus.present:
        return AppColors.success;
      case AttendanceStatus.absent:
        return AppColors.error;
      case AttendanceStatus.late:
        return AppColors.warning;
      case AttendanceStatus.leave:
        return AppColors.info;
      case AttendanceStatus.weekend:
        return AppColors.border;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: color, width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            '$day',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? AppColors.white : color,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

/// Legend Item
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
