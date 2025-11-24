import 'package:flutter/material.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../attendance/ui/screens/attendance_main_screen.dart';
import '../../../leaves/ui/screens/leaves_main_screen.dart';
import '../../../holidays/ui/screens/holidays_screen.dart';
import '../../../requests/ui/screens/requests_main_screen.dart';

/// Services Grid Widget
///
/// Displays a grid of service shortcuts with responsive design
class ServicesGridWidget extends StatelessWidget {
  const ServicesGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive: 2 columns on small screens, 3 on normal/large
    final crossAxisCount = screenWidth < 360 ? 2 : 3;
    final childAspectRatio = screenWidth < 360 ? 0.9 : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Text(
                'Quick Services',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              );
            }
          ),
        ),

        // Responsive Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
          children: [
            _ServiceCard(
              icon: Icons.event_available,
              label: 'Attendance',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AttendanceMainScreen(),
                  ),
                );
              },
            ),
            _ServiceCard(
              icon: Icons.event_busy,
              label: 'Leaves',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LeavesMainScreen(),
                  ),
                );
              },
            ),
            _ServiceCard(
              icon: Icons.assignment,
              label: 'Requests',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const RequestsMainScreen(),
                  ),
                );
              },
            ),
            _ServiceCard(
              icon: Icons.campaign,
              label: 'Notice Board',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notice Board feature coming soon!'),
                  ),
                );
              },
            ),
            _ServiceCard(
              icon: Icons.flight_takeoff,
              label: 'Holidays',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const HolidaysScreen(),
                  ),
                );
              },
            ),
            _ServiceCard(
              icon: Icons.bar_chart,
              label: 'Reports',
              onTap: () {
                Navigator.pushNamed(context, '/reports');
              },
            ),
          ],
        ),
      ],
    );
  }
}

/// Service Card - Minimal Design
///
/// Simple card with subtle styling
class _ServiceCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AppColors.darkBorder
                  : AppColors.black.withOpacity(0.06),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(isDark ? 0.4 : 0.04),
                blurRadius: isDark ? 12 : 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: AppColors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon with background
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkPrimary.withOpacity(0.2)
                            : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.icon,
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                        size: 28,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Label
                    Text(
                      widget.label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        height: 1.2,
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
        ),
      ),
    );
  }
}
