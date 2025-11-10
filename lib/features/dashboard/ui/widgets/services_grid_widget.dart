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
                color: AppColors.info, // Blue-gray from AppColors
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
                color: AppColors.error, // Red from AppColors
                onTap: () {
                  Navigator.pushNamed(context, '/leaves');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ServiceCard(
                icon: Icons.description,
                label: 'Claims',
                color: AppColors.warning, // Orange from AppColors
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
                color: AppColors.accentPurple, // Purple from AppColors
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
                color: AppColors.success, // Green from AppColors
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
                color: AppColors.primary, // Dark navy from AppColors
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon (larger size)
                Icon(
                  icon,
                  color: color,
                  size: 40,
                ),

                const SizedBox(height: 12),

                // Label
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
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
