import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../attendance/ui/screens/attendance_main_screen.dart';
import '../../../leaves/ui/screens/leaves_main_screen.dart';
import '../../../certificate/ui/screens/certificate_request_screen.dart';
import '../../../training/ui/screens/training_request_screen.dart';
import '../../../general_request/ui/screens/general_request_screen.dart';

/// Requests Main Screen
///
/// Displays all available request types for the employee
class RequestsMainScreen extends StatelessWidget {
  const RequestsMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.darkBackground
        : AppColors.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkAppBar : AppColors.primary,
        elevation: 0,
        title: Text(
          'Requests',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Animated Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [AppColors.darkCard, AppColors.darkCardElevated]
                        : [AppColors.primary, AppColors.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                ),
                child: Column(
                  children: [
                    // Requests Animation (Larger)
                    SizedBox(
                      width: double.infinity,
                      height: 180,
                      child: Lottie.asset(
                        'assets/animations/leaves.json',
                        fit: BoxFit.contain,
                        repeat: true,
                        animate: true,
                        // Performance optimizations
                        frameRate: FrameRate(30),
                        renderCache: RenderCache.raster,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.assignment,
                            color: AppColors.white,
                            size: 80,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Requests',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose the type of request you want to submit',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Request Types Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: [
                  // 1. Vacation Request (Active)
                  _RequestTypeCard(
                    icon: Icons.event_busy,
                    iconColor: AppColors.accent,
                    label: 'Leave Request',
                    description: 'Submit a leave request',
                    isActive: true,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LeavesMainScreen(),
                        ),
                      );
                    },
                  ),

                  // 2. Attendance Request (Active)
                  _RequestTypeCard(
                    icon: Icons.access_time,
                    iconColor: AppColors.info,
                    label: 'Attendance',
                    description: 'Modify or justify attendance',
                    isActive: true,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AttendanceMainScreen(),
                        ),
                      );
                    },
                  ),

                  // 3. Certificate Request (Active)
                  _RequestTypeCard(
                    icon: Icons.description,
                    iconColor: AppColors.success,
                    label: 'Certificate',
                    description: 'Salary, experience certificate, etc.',
                    isActive: true,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const CertificateRequestScreen(),
                        ),
                      );
                    },
                  ),

                  // 4. Training Request (Active)
                  _RequestTypeCard(
                    icon: Icons.school,
                    iconColor: AppColors.warning,
                    label: 'Training',
                    description: 'Apply for a training course',
                    isActive: true,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TrainingRequestScreen(),
                        ),
                      );
                    },
                  ),

                  // 5. General Request (Active)
                  _RequestTypeCard(
                    icon: Icons.article,
                    iconColor: AppColors.primary,
                    label: 'General',
                    description: 'Other miscellaneous requests',
                    isActive: true,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const GeneralRequestScreen(),
                        ),
                      );
                    },
                  ),

                  // Placeholder for future expansion
                  _RequestTypeCard(
                    icon: Icons.more_horiz,
                    iconColor: AppColors.textSecondary,
                    label: 'Coming Soon',
                    description: 'New features',
                    isActive: false,
                    onTap: () {
                      _showComingSoonDialog(context, 'New Features');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show Coming Soon Dialog
  void _showComingSoonDialog(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.schedule, color: AppColors.warning, size: 28),
            const SizedBox(width: 12),
            const Text('Coming Soon'),
          ],
        ),
        content: Text(
          '"$featureName" will be available soon.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

/// Request Type Card Widget
class _RequestTypeCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String description;
  final bool isActive;
  final VoidCallback onTap;

  const _RequestTypeCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.description,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_RequestTypeCard> createState() => _RequestTypeCardState();
}

class _RequestTypeCardState extends State<_RequestTypeCard>
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
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.isActive) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isActive) {
      _controller.reverse();
    }
    widget.onTap();
  }

  void _handleTapCancel() {
    if (widget.isActive) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isInactive = !widget.isActive;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Opacity(
          opacity: isInactive ? 0.5 : 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? AppColors.darkBorder
                    : AppColors.black.withValues(alpha: 0.08),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: isDark ? 12 : 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: AppColors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon with background
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: widget.iconColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.iconColor,
                          size: 36,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Label
                      Text(
                        widget.label,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 6),

                      // Description
                      Text(
                        widget.description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                          fontSize: 11,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Status Badge (if inactive)
                      if (isInactive) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Soon',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.warning,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
