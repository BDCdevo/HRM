import 'package:flutter/material.dart';
import '../../../../core/styles/app_colors.dart';

/// Services Grid Skeleton
///
/// Loading skeleton for services grid
class ServicesGridSkeleton extends StatefulWidget {
  const ServicesGridSkeleton({super.key});

  @override
  State<ServicesGridSkeleton> createState() => _ServicesGridSkeletonState();
}

class _ServicesGridSkeletonState extends State<ServicesGridSkeleton>
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
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 360 ? 2 : 3;
    final childAspectRatio = screenWidth < 360 ? 0.9 : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Skeleton
        _buildShimmer(
          isDark: isDark,
          child: Container(
            height: 20,
            width: 120,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSkeleton : AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Grid Skeleton
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
          children: List.generate(
            6,
            (index) => _ServiceCardSkeleton(isDark: isDark, animation: _animation),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmer({
    required bool isDark,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
              colors: isDark
                  ? [
                      AppColors.darkSkeleton,
                      AppColors.darkSkeletonHighlight.withOpacity(0.8),
                      AppColors.darkSkeleton,
                    ]
                  : [
                      AppColors.border,
                      AppColors.borderLight,
                      AppColors.border,
                    ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Service Card Skeleton
class _ServiceCardSkeleton extends StatelessWidget {
  final bool isDark;
  final Animation<double> animation;

  const _ServiceCardSkeleton({
    required this.isDark,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
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
                                AppColors.darkSkeletonHighlight.withOpacity(0.5),
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
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon skeleton
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSkeleton.withOpacity(0.8)
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Label skeleton
                    Container(
                      height: 12,
                      width: 60,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSkeleton.withOpacity(0.8)
                            : AppColors.border,
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
