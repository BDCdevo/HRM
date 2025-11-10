import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../attendance/ui/screens/attendance_summary_screen.dart';

/// Today's Attendance Stats Card
///
/// Shows statistics for today's attendance:
/// - Present count
/// - Absent count
/// - Checked Out count
///
/// With "See All" button to navigate to full attendance history
class TodayAttendanceStatsCard extends StatelessWidget {
  final int presentCount;
  final int absentCount;
  final int checkedOutCount;

  const TodayAttendanceStatsCard({
    super.key,
    this.presentCount = 0,
    this.absentCount = 0,
    this.checkedOutCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Format today's date
    final today = DateFormat('E, MMM dd, yyyy').format(DateTime.now());
    final totalCount = presentCount + absentCount + checkedOutCount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row (Title + See All button)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title and Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Attendance",
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    today,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              // See All Button
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AttendanceSummaryScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'See All',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Stats Row (Present | Absent | Checked Out)
          Row(
            children: [
              // Present
              Expanded(
                child: _buildStatItem(
                  label: 'Present',
                  count: presentCount,
                  color: AppColors.success,
                ),
              ),

              // Divider
              Container(
                width: 1,
                height: 40,
                color: AppColors.divider,
              ),

              // Absent
              Expanded(
                child: _buildStatItem(
                  label: 'Absent',
                  count: absentCount,
                  color: AppColors.error,
                ),
              ),

              // Divider
              Container(
                width: 1,
                height: 40,
                color: AppColors.divider,
              ),

              // Checked Out
              Expanded(
                child: _buildStatItem(
                  label: 'Checked Out',
                  count: checkedOutCount,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build individual stat item - Simple design
  Widget _buildStatItem({
    required String label,
    required int count,
    required Color color,
  }) {
    return Column(
      children: [
        // Label
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Count
        Text(
          count.toString(),
          style: AppTextStyles.headlineLarge.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
