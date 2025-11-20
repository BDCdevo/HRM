import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../styles/app_colors.dart';

/// Custom widget to display user's Lottie animation
///
/// Features:
/// - Loads custom animation from network URL
/// - Falls back to default animation from assets
/// - Falls back to placeholder icon on error
/// - Supports customization (width, height, repeat)
///
/// Usage:
/// ```dart
/// CustomUserAnimation(
///   customAnimationUrl: user.customAnimationUrl,
///   defaultAnimationAsset: 'assets/animations/loading.json',
///   width: 100,
///   height: 100,
/// )
/// ```
class CustomUserAnimation extends StatelessWidget {
  /// URL of custom animation from server (nullable)
  final String? customAnimationUrl;

  /// Path to default animation in assets
  final String defaultAnimationAsset;

  /// Width of the animation
  final double? width;

  /// Height of the animation
  final double? height;

  /// Whether to repeat the animation
  final bool repeat;

  /// Animation fit mode
  final BoxFit fit;

  /// Fallback icon when all animations fail
  final IconData fallbackIcon;

  /// Fallback icon color
  final Color? fallbackIconColor;

  const CustomUserAnimation({
    Key? key,
    this.customAnimationUrl,
    this.defaultAnimationAsset = 'assets/animations/loading.json',
    this.width,
    this.height,
    this.repeat = true,
    this.fit = BoxFit.contain,
    this.fallbackIcon = Icons.person,
    this.fallbackIconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If user has custom animation, load from network
    if (customAnimationUrl != null && customAnimationUrl!.isNotEmpty) {
      return _buildNetworkAnimation(context);
    }

    // Otherwise, use default animation from assets
    return _buildDefaultAnimation(context);
  }

  /// Build animation from network URL
  Widget _buildNetworkAnimation(BuildContext context) {
    return Lottie.network(
      customAnimationUrl!,
      width: width,
      height: height,
      repeat: repeat,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to default animation on error
        return _buildDefaultAnimation(context);
      },
      frameBuilder: (context, child, composition) {
        if (composition != null) {
          return child;
        }
        // Show loading indicator while loading
        return SizedBox(
          width: width,
          height: height,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  /// Build default animation from assets
  Widget _buildDefaultAnimation(BuildContext context) {
    return Lottie.asset(
      defaultAnimationAsset,
      width: width,
      height: height,
      repeat: repeat,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // Final fallback: placeholder icon
        return _buildFallbackIcon(context);
      },
    );
  }

  /// Build fallback icon when all animations fail
  Widget _buildFallbackIcon(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Center(
        child: Icon(
          fallbackIcon,
          size: (width ?? 100) * 0.6,
          color: fallbackIconColor ?? AppColors.primary,
        ),
      ),
    );
  }
}

/// Extended version with caching and more features
class CachedCustomUserAnimation extends StatefulWidget {
  final String? customAnimationUrl;
  final String defaultAnimationAsset;
  final double? width;
  final double? height;
  final bool repeat;
  final BoxFit fit;

  const CachedCustomUserAnimation({
    Key? key,
    this.customAnimationUrl,
    this.defaultAnimationAsset = 'assets/animations/loading.json',
    this.width,
    this.height,
    this.repeat = true,
    this.fit = BoxFit.contain,
  }) : super(key: key);

  @override
  State<CachedCustomUserAnimation> createState() =>
      _CachedCustomUserAnimationState();
}

class _CachedCustomUserAnimationState extends State<CachedCustomUserAnimation> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    // If there was an error or no custom URL, show default
    if (_hasError ||
        widget.customAnimationUrl == null ||
        widget.customAnimationUrl!.isEmpty) {
      return _buildDefaultAnimation();
    }

    return _buildNetworkAnimation();
  }

  Widget _buildNetworkAnimation() {
    return Lottie.network(
      widget.customAnimationUrl!,
      width: widget.width,
      height: widget.height,
      repeat: widget.repeat,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        // Set error flag and rebuild with default
        if (!_hasError) {
          setState(() {
            _hasError = true;
          });
        }
        return _buildDefaultAnimation();
      },
    );
  }

  Widget _buildDefaultAnimation() {
    return Lottie.asset(
      widget.defaultAnimationAsset,
      width: widget.width,
      height: widget.height,
      repeat: widget.repeat,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.person,
          size: (widget.width ?? 100) * 0.6,
          color: AppColors.primary,
        );
      },
    );
  }
}

/// Simple animation preview widget for file selection
class AnimationPreview extends StatelessWidget {
  final String animationPath;
  final double size;
  final bool isAsset;

  const AnimationPreview({
    Key? key,
    required this.animationPath,
    this.size = 200,
    this.isAsset = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: isAsset
            ? Lottie.asset(
                animationPath,
                fit: BoxFit.contain,
              )
            : Lottie.network(
                animationPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.error_outline,
                      size: 50,
                      color: AppColors.error,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
