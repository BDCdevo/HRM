import 'package:flutter/material.dart';
import '../../../../core/styles/app_colors.dart';

/// Chat Messages Skeleton
///
/// Loading skeleton for chat messages
class ChatMessagesSkeleton extends StatefulWidget {
  const ChatMessagesSkeleton({super.key});

  @override
  State<ChatMessagesSkeleton> createState() => _ChatMessagesSkeletonState();
}

class _ChatMessagesSkeletonState extends State<ChatMessagesSkeleton>
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
      reverse: true,
      padding: const EdgeInsets.all(8),
      itemCount: 8,
      itemBuilder: (context, index) {
        // Alternate between sent and received messages
        final isSent = index % 3 == 0;
        return _MessageBubbleSkeleton(
          animation: _animation,
          isDark: isDark,
          isSent: isSent,
        );
      },
    );
  }
}

/// Message Bubble Skeleton
class _MessageBubbleSkeleton extends StatelessWidget {
  final Animation<double> animation;
  final bool isDark;
  final bool isSent;

  const _MessageBubbleSkeleton({
    required this.animation,
    required this.isDark,
    required this.isSent,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Align(
          alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.only(
              left: isSent ? 60 : 12,
              right: isSent ? 12 : 60,
              top: 4,
              bottom: 4,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSent
                  ? (isDark
                      ? const Color(0xFF005C4B).withOpacity(0.3)
                      : const Color(0xFFDCF8C6).withOpacity(0.3))
                  : (isDark
                      ? const Color(0xFF1F2C34).withOpacity(0.3)
                      : Colors.white.withOpacity(0.3)),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(8),
                topRight: const Radius.circular(8),
                bottomLeft: isSent
                    ? const Radius.circular(8)
                    : const Radius.circular(0),
                bottomRight: isSent
                    ? const Radius.circular(0)
                    : const Radius.circular(8),
              ),
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
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(8),
                      topRight: const Radius.circular(8),
                      bottomLeft: isSent
                          ? const Radius.circular(8)
                          : const Radius.circular(0),
                      bottomRight: isSent
                          ? const Radius.circular(0)
                          : const Radius.circular(8),
                    ),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Message text skeleton
                    Container(
                      height: 14,
                      width: isSent ? 180 : 200,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSkeleton : AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 14,
                      width: isSent ? 120 : 160,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSkeleton : AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Time skeleton
                    Container(
                      height: 11,
                      width: 50,
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
        );
      },
    );
  }
}
