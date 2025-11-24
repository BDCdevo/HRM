import 'package:flutter/material.dart';
import '../../../../core/styles/app_colors.dart';

/// Leaves Balance Skeleton
///
/// Loading skeleton for leave balance cards
class LeavesBalanceSkeleton extends StatefulWidget {
  const LeavesBalanceSkeleton({super.key});

  @override
  State<LeavesBalanceSkeleton> createState() => _LeavesBalanceSkeletonState();
}

class _LeavesBalanceSkeletonState extends State<LeavesBalanceSkeleton>
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _BalanceCardSkeleton(animation: _animation),
          ),
        ),
      ),
    );
  }
}

/// Balance Card Skeleton
class _BalanceCardSkeleton extends StatelessWidget {
  final Animation<double> animation;

  const _BalanceCardSkeleton({required this.animation});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          height: 120,
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
                    // Leave type skeleton
                    Container(
                      height: 18,
                      width: 120,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSkeleton : AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Progress indicator skeleton
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Progress bar
                              Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkSkeleton : AppColors.border,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Stats row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Used skeleton
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 12,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          color: isDark ? AppColors.darkSkeleton : AppColors.border,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        height: 16,
                                        width: 30,
                                        decoration: BoxDecoration(
                                          color: isDark ? AppColors.darkSkeleton : AppColors.border,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Remaining skeleton
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        height: 12,
                                        width: 60,
                                        decoration: BoxDecoration(
                                          color: isDark ? AppColors.darkSkeleton : AppColors.border,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        height: 16,
                                        width: 30,
                                        decoration: BoxDecoration(
                                          color: isDark ? AppColors.darkSkeleton : AppColors.border,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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
