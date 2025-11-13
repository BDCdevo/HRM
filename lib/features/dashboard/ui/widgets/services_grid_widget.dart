import 'package:flutter/material.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../attendance/ui/screens/attendance_main_screen.dart';

/// Services Grid Widget
///
/// Displays a grid of service shortcuts (Attendance, Track Leave, Claims, etc.)
class ServicesGridWidget extends StatelessWidget {
  const ServicesGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row 1: Attendance, Track Leave, Claims
        Row(
          children: [
            Expanded(
              child: _ServiceCard(
                icon: Icons.event_available,
                label: 'Attendance',
                color: AppColors.primary,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AttendanceMainScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ServiceCard(
                icon: Icons.event_busy,
                label: 'Track Leave',
                color: AppColors.accent,
                onTap: () {
                  Navigator.pushNamed(context, '/leaves');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ServiceCard(
                icon: Icons.receipt_long,
                label: 'Claims',
                color: AppColors.servicesGray,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Claims feature coming soon!'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Row 2: Notice Board, Holidays, Reports
        Row(
          children: [
            Expanded(
              child: _ServiceCard(
                icon: Icons.campaign,
                label: 'Notice Board',
                color: AppColors.primary,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notice Board feature coming soon!'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ServiceCard(
                icon: Icons.flight_takeoff,
                label: 'Holidays',
                color: AppColors.servicesGray, // Gray
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Holidays feature coming soon!'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ServiceCard(
                icon: Icons.bar_chart,
                label: 'Reports',
                color: AppColors.accent,
                onTap: () {
                  Navigator.pushNamed(context, '/reports');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Service Card
///
/// Individual service card with icon and label
class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: AppColors.transparent,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
                spreadRadius: -3,
              ),
              BoxShadow(
                color: AppColors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon in colored container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 30,
                  ),
                ),

                const SizedBox(height: 14),

                // Label
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
