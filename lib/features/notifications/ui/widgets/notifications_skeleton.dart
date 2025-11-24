import 'package:flutter/material.dart';
import '../../../../core/styles/app_colors.dart';

/// Notifications Skeleton
///
/// Loading skeleton for notifications list
class NotificationsSkeleton extends StatefulWidget {
  const NotificationsSkeleton({super.key});

  @override
  State<NotificationsSkeleton> createState() => _NotificationsSkeletonState();
}

class _NotificationsSkeletonState extends State<NotificationsSkeleton>
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
      itemCount: 8,
      itemBuilder: (context, index) {
        return _NotificationItemSkeleton(animation: _animation);
      },
    );
  }
}

/// Notification Item Skeleton
class _NotificationItemSkeleton extends StatelessWidget {
  final Animation<double> animation;

  const _NotificationItemSkeleton({required this.animation});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon skeleton
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSkeleton : AppColors.border,
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title skeleton
                          Container(
                            height: 16,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSkeleton : AppColors.border,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Description skeleton
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
                            width: 180,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSkeleton : AppColors.border,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Time skeleton
                          Container(
                            height: 12,
                            width: 80,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSkeleton : AppColors.border,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Unread indicator skeleton
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSkeleton : AppColors.border,
                        shape: BoxShape.circle,
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
