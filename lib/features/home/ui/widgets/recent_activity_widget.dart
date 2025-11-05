import 'package:flutter/material.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';

/// Recent Activity Widget
///
/// Displays recent user activities and notifications
class RecentActivityWidget extends StatelessWidget {
  const RecentActivityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Section Title
        Text(
          'Recent Activity',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        // Today Section
        _DateSection(
          date: 'Today',
          activities: [
            _ActivityItem(
              icon: Icons.login,
              title: 'Checked In',
              subtitle: 'Morning check-in recorded',
              time: '09:15 AM',
              color: AppColors.success,
            ),
            _ActivityItem(
              icon: Icons.notifications,
              title: 'New Announcement',
              subtitle: 'Team meeting scheduled for tomorrow',
              time: '10:30 AM',
              color: AppColors.info,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Yesterday Section
        _DateSection(
          date: 'Yesterday',
          activities: [
            _ActivityItem(
              icon: Icons.logout,
              title: 'Checked Out',
              subtitle: 'Evening check-out recorded',
              time: '05:45 PM',
              color: AppColors.error,
            ),
            _ActivityItem(
              icon: Icons.event_available,
              title: 'Leave Request Approved',
              subtitle: 'Your leave request has been approved',
              time: '02:20 PM',
              color: AppColors.success,
            ),
            _ActivityItem(
              icon: Icons.assessment,
              title: 'Monthly Report Generated',
              subtitle: 'October report is now available',
              time: '11:00 AM',
              color: AppColors.primary,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // This Week Section
        _DateSection(
          date: 'This Week',
          activities: [
            _ActivityItem(
              icon: Icons.event_note,
              title: 'Leave Applied',
              subtitle: 'Casual leave for 2 days',
              time: 'Nov 28',
              color: AppColors.warning,
            ),
            _ActivityItem(
              icon: Icons.update,
              title: 'Profile Updated',
              subtitle: 'Contact information changed',
              time: 'Nov 27',
              color: AppColors.secondary,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // View All Button
        Center(
          child: TextButton.icon(
            onPressed: () {
              // TODO: Navigate to full activity history
            },
            icon: const Icon(Icons.history),
            label: const Text('View All Activities'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Date Section
class _DateSection extends StatelessWidget {
  final String date;
  final List<Widget> activities;

  const _DateSection({
    required this.date,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Header
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            date,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),

        // Activities
        ...activities,
      ],
    );
  }
}

/// Activity Item
class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
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
          // TODO: Navigate to activity details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Time
              Text(
                time,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
