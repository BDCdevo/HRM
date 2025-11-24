import 'package:flutter/material.dart';
import '../../../../core/styles/app_colors.dart';

/// Chat List Skeleton
///
/// Loading skeleton for chat conversations list
class ChatListSkeleton extends StatefulWidget {
  const ChatListSkeleton({super.key});

  @override
  State<ChatListSkeleton> createState() => _ChatListSkeletonState();
}

class _ChatListSkeletonState extends State<ChatListSkeleton>
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
      itemCount: 8, // Show 8 skeleton items
      itemBuilder: (context, index) {
        return _ChatItemSkeleton(animation: _animation);
      },
    );
  }
}

/// Chat Item Skeleton
class _ChatItemSkeleton extends StatelessWidget {
  final Animation<double> animation;

  const _ChatItemSkeleton({required this.animation});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1E2B) : AppColors.white,
            borderRadius: BorderRadius.circular(0),
          ),
          child: Stack(
            children: [
              // Shimmer overlay
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0),
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
                                AppColors.darkSkeletonHighlight.withOpacity(0.2),
                                Colors.transparent,
                              ]
                            : [
                                Colors.transparent,
                                AppColors.borderLight.withOpacity(0.3),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Avatar skeleton
                    Container(
                      width: 56,
                      height: 56,
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
                          // Name and time row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Name skeleton
                              Container(
                                height: 16,
                                width: 140,
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkSkeleton : AppColors.border,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),

                              // Time skeleton
                              Container(
                                height: 12,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkSkeleton : AppColors.border,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Message preview and badge row
                          Row(
                            children: [
                              // Message preview skeleton
                              Expanded(
                                child: Container(
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkSkeleton : AppColors.border,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Unread badge skeleton
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
