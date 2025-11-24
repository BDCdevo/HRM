import 'package:flutter/material.dart';
import '../../../../core/styles/app_colors.dart';

/// Holidays Screen Skeleton
///
/// Loading skeleton for holidays list
class HolidaysSkeleton extends StatefulWidget {
  const HolidaysSkeleton({super.key});

  @override
  State<HolidaysSkeleton> createState() => _HolidaysSkeletonState();
}

class _HolidaysSkeletonState extends State<HolidaysSkeleton>
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5, // Show 5 skeleton cards
      itemBuilder: (context, index) {
        return _HolidayCardSkeleton(
          isDark: isDark,
          animation: _animation,
        );
      },
    );
  }
}

/// Holiday Card Skeleton
class _HolidayCardSkeleton extends StatelessWidget {
  final bool isDark;
  final Animation<double> animation;

  const _HolidayCardSkeleton({
    required this.isDark,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: isDark ? 4 : 2,
          color: isDark ? AppColors.darkCard : AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              // Shimmer overlay
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
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
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Color indicator
                    Container(
                      width: 4,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSkeleton.withOpacity(0.8)
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Holiday name skeleton
                          Container(
                            height: 18,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkSkeleton.withOpacity(0.8)
                                  : AppColors.border,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Date range skeleton
                          Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkSkeleton.withOpacity(0.8)
                                      : AppColors.border,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                height: 14,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkSkeleton.withOpacity(0.8)
                                      : AppColors.border,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Tags skeleton
                          Row(
                            children: [
                              Container(
                                height: 24,
                                width: 60,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkSkeleton.withOpacity(0.8)
                                      : AppColors.border,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                height: 24,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkSkeleton.withOpacity(0.8)
                                      : AppColors.border,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Status icon skeleton
                    const SizedBox(width: 8),
                    Container(
                      width: 24,
                      height: 24,
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
