import 'package:flutter/material.dart';
import '../../../../core/styles/app_colors.dart';

/// Leaves List Skeleton
///
/// Loading skeleton for leave requests list
class LeavesSkeleton extends StatefulWidget {
  const LeavesSkeleton({super.key});

  @override
  State<LeavesSkeleton> createState() => _LeavesSkeletonState();
}

class _LeavesSkeletonState extends State<LeavesSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5, // Show 5 skeleton cards
      itemBuilder: (context, index) {
        return _LeaveCardSkeleton(animation: _animation);
      },
    );
  }
}

/// Leave Card Skeleton
class _LeaveCardSkeleton extends StatelessWidget {
  final Animation<double> animation;

  const _LeaveCardSkeleton({required this.animation});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Shimmer overlay
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [
                          animation.value - 0.3,
                          animation.value,
                          animation.value + 0.3,
                        ],
                        colors: isDark
                            ? [
                                Colors.transparent,
                                AppColors.darkSkeletonHighlight.withOpacity(0.3),
                                Colors.transparent,
                              ]
                            : [
                                Colors.transparent,
                                AppColors.borderLight.withOpacity(0.5),
                                Colors.transparent,
                              ],
                      ).createShader(bounds);
                    },
                    child: Container(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row (leave type and status)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Leave type skeleton
                        Container(
                          height: 20,
                          width: 120,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSkeleton : AppColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),

                        // Status badge skeleton
                        Container(
                          height: 24,
                          width: 80,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSkeleton : AppColors.border,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Date range skeleton
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSkeleton : AppColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 14,
                          width: 180,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSkeleton : AppColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Duration skeleton
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSkeleton : AppColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 14,
                          width: 100,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSkeleton : AppColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Reason skeleton (optional)
                    Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSkeleton : AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Container(
                      height: 14,
                      width: 200,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSkeleton : AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
