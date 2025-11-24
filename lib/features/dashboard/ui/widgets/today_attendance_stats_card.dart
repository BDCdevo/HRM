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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
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
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    today,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
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
                  color: const Color(0xFF6B7280),
                  context: context,
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
                  color: const Color(0xFF6B7280), // Gray
                  context: context,
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
                  color: AppColors.accent,
                  context: context,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build individual stat item - Clean professional design
  Widget _buildStatItem({
    required String label,
    required int count,
    required Color color,
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Count in colored container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? color.withOpacity(0.25) : color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            count.toString(),
            style: AppTextStyles.headlineLarge.copyWith(
              color: isDark ? AppColors.darkTextPrimary : color,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),

        // Label
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
