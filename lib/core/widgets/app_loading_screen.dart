import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import '../styles/app_colors.dart';

/// Unified App Loading Screen
///
/// Used for:
/// - App startup (checking auth status)
/// - Login process
/// - Any full-screen loading state
///
/// Customizable with message and optional logo animation
class AppLoadingScreen extends StatefulWidget {
  final String? message;
  final bool showLogo;
  final bool isDark;
  final LoadingAnimationType animationType;

  const AppLoadingScreen({
    super.key,
    this.message,
    this.showLogo = true,
    this.isDark = false,
    this.animationType = LoadingAnimationType.logo, // Default: logo
  });

  @override
  State<AppLoadingScreen> createState() => _AppLoadingScreenState();
}

class _AppLoadingScreenState extends State<AppLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Repeat animation for spinner and dots
    if (widget.animationType == LoadingAnimationType.spinner ||
        widget.animationType == LoadingAnimationType.dots) {
      _controller.repeat();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: widget.isDark
                ? [
                    AppColors.darkBackground,
                    AppColors.darkCard,
                    AppColors.darkBackground,
                  ]
                : [
                    AppColors.primaryDark,
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Loading Animation
              _buildLoadingAnimation(),

              // Loading Indicator (if using logo)
              if (widget.animationType == LoadingAnimationType.logo)
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.isDark ? AppColors.primary : AppColors.white,
                    ),
                  ),
                ),

              // Message (if provided)
              if (widget.message != null) ...[
                const SizedBox(height: 24),
                Text(
                  widget.message!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: widget.isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              // App Name (optional)
              if (widget.showLogo && widget.animationType == LoadingAnimationType.logo) ...[
                const SizedBox(height: 32),
                Text(
                  'HRM System',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: widget.isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build Loading Animation based on type
  Widget _buildLoadingAnimation() {
    switch (widget.animationType) {
      case LoadingAnimationType.lottie:
        return _buildLottieAnimation();
      case LoadingAnimationType.spinner:
        return _buildSpinnerAnimation();
      case LoadingAnimationType.dots:
        return _buildDotsAnimation();
      case LoadingAnimationType.logo:
      default:
        return _buildLogoAnimation();
    }
  }

  /// Logo Animation (Original)
  Widget _buildLogoAnimation() {
    if (!widget.showLogo) return const SizedBox.shrink();

    return Column(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.white.withValues(alpha: 0.3),
                        blurRadius: 40,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(22),
                  child: SvgPicture.asset(
                    'assets/images/logo/bdc_logo.svg',
                    colorFilter: const ColorFilter.mode(
                      AppColors.primaryDark,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  /// Lottie Animation
  Widget _buildLottieAnimation() {
    return Column(
      children: [
        // Try to load Lottie, fallback to logo if not found
        SizedBox(
          width: 300,
          height: 300,
          child: Lottie.asset(
            'assets/animations/load_login.json',
            fit: BoxFit.contain,
            repeat: true,
            animate: true,
            // Performance optimizations
            frameRate: FrameRate(30),
            renderCache: RenderCache.raster,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to logo if Lottie not found
              print('⚠️ Lottie file not found: $error');
              print('Stack trace: $stackTrace');
              return Container(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.isDark ? AppColors.primary : AppColors.white,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Custom Spinner Animation
  Widget _buildSpinnerAnimation() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * 3.14159,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.isDark ? AppColors.primary : AppColors.white,
                    width: 4,
                  ),
                  gradient: LinearGradient(
                    colors: [
                      widget.isDark ? AppColors.primary : AppColors.white,
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  /// Dots Animation
  Widget _buildDotsAnimation() {
    return Column(
      children: [
        SizedBox(
          width: 100,
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (index) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final delay = index * 0.2;
                  final value = (_controller.value + delay) % 1.0;
                  final scale = 0.5 + (0.5 * (1 - (value - 0.5).abs() * 2));

                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isDark
                            ? AppColors.primary
                            : AppColors.white,
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }
}

/// Loading Animation Types
enum LoadingAnimationType {
  logo,     // Original logo animation
  lottie,   // Lottie JSON animation
  spinner,  // Custom rotating spinner
  dots,     // Animated dots
}

/// Simple Loading Overlay
///
/// Shows loading indicator over current screen
/// Use for: Quick actions, API calls, etc.
class AppLoadingOverlay extends StatelessWidget {
  final String? message;
  final bool isDark;

  const AppLoadingOverlay({
    super.key,
    this.message,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? AppColors.primary : AppColors.primaryDark,
                  ),
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.primaryDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Show loading overlay as dialog
  static void show(BuildContext context, {String? message, bool isDark = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AppLoadingOverlay(
        message: message,
        isDark: isDark,
      ),
    );
  }

  /// Hide loading overlay
  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}
