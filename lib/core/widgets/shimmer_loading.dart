import 'package:flutter/material.dart';
import '../styles/app_colors.dart';

/// Shimmer Loading Effect
///
/// Reusable shimmer loading widgets for skeleton screens
class ShimmerLoading extends StatefulWidget {
  final Widget child;

  const ShimmerLoading({
    super.key,
    required this.child,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
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

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
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
    final baseColor = isDark ? AppColors.darkSkeleton : const Color(0xFFE0E0E0);
    final highlightColor = isDark ? AppColors.darkSkeletonHighlight : const Color(0xFFF5F5F5);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(slidePercent: _animation.value),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

/// Skeleton Box
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final skeletonColor = isDark ? AppColors.darkSkeleton : const Color(0xFFE0E0E0);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: skeletonColor,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }
}

/// Skeleton Line
class SkeletonLine extends StatelessWidget {
  final double? width;
  final double height;

  const SkeletonLine({
    super.key,
    this.width,
    this.height = 16,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(height / 2),
    );
  }
}

/// Skeleton Circle
class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({
    super.key,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final skeletonColor = isDark ? AppColors.darkSkeleton : const Color(0xFFE0E0E0);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: skeletonColor,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Dashboard Skeleton
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const SkeletonCircle(size: 48),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLine(width: 100, height: 20),
                    const SizedBox(height: 8),
                    SkeletonLine(width: 150, height: 14),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Main Card
            SkeletonBox(
              width: double.infinity,
              height: 200,
              borderRadius: BorderRadius.circular(20),
            ),

            const SizedBox(height: 24),

            // Stats Card
            SkeletonBox(
              width: double.infinity,
              height: 150,
              borderRadius: BorderRadius.circular(20),
            ),

            const SizedBox(height: 24),

            // Grid Items
            Row(
              children: [
                Expanded(
                  child: SkeletonBox(
                    height: 120,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SkeletonBox(
                    height: 120,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SkeletonBox(
                    height: 120,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Card Skeleton
class CardSkeleton extends StatelessWidget {
  final double height;

  const CardSkeleton({
    super.key,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonLine(width: 120, height: 18),
            const SizedBox(height: 12),
            const SkeletonLine(width: double.infinity, height: 14),
            const SizedBox(height: 8),
            const SkeletonLine(width: 200, height: 14),
          ],
        ),
      ),
    );
  }
}

/// List Item Skeleton
class ListItemSkeleton extends StatelessWidget {
  const ListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const SkeletonCircle(size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLine(width: double.infinity, height: 16),
                  const SizedBox(height: 8),
                  SkeletonLine(width: 150, height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
