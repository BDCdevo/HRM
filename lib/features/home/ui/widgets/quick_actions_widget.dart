import 'package:flutter/material.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';

/// Quick Actions Widget
///
/// Displays quick access buttons for common actions
class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            'Quick Actions',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // Attendance Actions
          _SectionCard(
            title: 'Attendance',
            icon: Icons.access_time,
            color: AppColors.primary,
            actions: [
              _QuickActionButton(
                icon: Icons.login,
                label: 'Check In',
                color: AppColors.success,
                onTap: () {
                  // TODO: Navigate to check-in
                },
              ),
              _QuickActionButton(
                icon: Icons.logout,
                label: 'Check Out',
                color: AppColors.error,
                onTap: () {
                  // TODO: Navigate to check-out
                },
              ),
              _QuickActionButton(
                icon: Icons.history,
                label: 'History',
                color: AppColors.primary,
                onTap: () {
                  // TODO: Navigate to attendance history
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Leave Actions
          _SectionCard(
            title: 'Leaves',
            icon: Icons.event_busy,
            color: AppColors.accentOrange,
            actions: [
              _QuickActionButton(
                icon: Icons.add_circle_outline,
                label: 'Apply Leave',
                color: AppColors.accentOrange,
                onTap: () {
                  // TODO: Navigate to apply leave
                },
              ),
              _QuickActionButton(
                icon: Icons.list_alt,
                label: 'My Leaves',
                color: AppColors.secondary,
                onTap: () {
                  // TODO: Navigate to leave history
                },
              ),
              _QuickActionButton(
                icon: Icons.account_balance_wallet,
                label: 'Balance',
                color: AppColors.info,
                onTap: () {
                  // TODO: Navigate to leave balance
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Reports & Info
          _SectionCard(
            title: 'Reports & Information',
            icon: Icons.insert_chart,
            color: AppColors.info,
            actions: [
              _QuickActionButton(
                icon: Icons.calendar_today,
                label: 'Work Schedule',
                color: AppColors.primary,
                onTap: () {
                  // TODO: Navigate to work schedule
                },
              ),
              _QuickActionButton(
                icon: Icons.assessment,
                label: 'Monthly Report',
                color: AppColors.info,
                onTap: () {
                  // TODO: Navigate to monthly report
                },
              ),
              _QuickActionButton(
                icon: Icons.person,
                label: 'My Profile',
                color: AppColors.secondary,
                onTap: () {
                  // TODO: Navigate to profile
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Settings
          _SectionCard(
            title: 'Settings',
            icon: Icons.settings,
            color: AppColors.textSecondary,
            actions: [
              _QuickActionButton(
                icon: Icons.notifications,
                label: 'Notifications',
                color: AppColors.primary,
                onTap: () {
                  // TODO: Navigate to notifications
                },
              ),
              _QuickActionButton(
                icon: Icons.help_outline,
                label: 'Help & Support',
                color: AppColors.info,
                onTap: () {
                  // TODO: Navigate to help
                },
              ),
              _QuickActionButton(
                icon: Icons.logout,
                label: 'Logout',
                color: AppColors.error,
                onTap: () {
                  // TODO: Show logout confirmation
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Section Card
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> actions;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Section Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
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
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            height: 1,
            color: AppColors.border.withOpacity(0.5),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: actions,
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick Action Button
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: (MediaQuery.of(context).size.width - 88) / 3,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
