import 'package:flutter/material.dart';
import '../../../../core/styles/app_colors.dart';

/// Leave Types Skeleton
///
/// Loading skeleton for vacation types selection
class LeaveTypesSkeleton extends StatefulWidget {
  const LeaveTypesSkeleton({super.key});

  @override
  State<LeaveTypesSkeleton> createState() => _LeaveTypesSkeletonState();
}

class _LeaveTypesSkeletonState extends State<LeaveTypesSkeleton>
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _LeaveTypeCardSkeleton(
            animation: _animation,
            isDark: isDark,
          ),
        ),
      ),
    );
  }
}

/// Leave Type Card Skeleton
class _LeaveTypeCardSkeleton extends StatelessWidget {
  final Animation<double> animation;
  final bool isDark;

  const _LeaveTypeCardSkeleton({
    required this.animation,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 1,
            ),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
              Row(
                children: [
                  // Icon skeleton
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSkeleton : AppColors.border,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title skeleton
                        Container(
                          height: 18,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSkeleton : AppColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Subtitle skeleton
                        Row(
                          children: [
                            Container(
                              height: 14,
                              width: 100,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSkeleton : AppColors.border,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              height: 14,
                              width: 60,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSkeleton : AppColors.border,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Radio button skeleton
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSkeleton : AppColors.border,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
