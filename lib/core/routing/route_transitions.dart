import 'package:flutter/material.dart';

/// Route Transition Types
enum RouteTransitionType {
  /// Standard Material transition
  material,

  /// Fade transition
  fade,

  /// Slide from right
  slideFromRight,

  /// Slide from left
  slideFromLeft,

  /// Slide from bottom
  slideFromBottom,

  /// Slide from top
  slideFromTop,

  /// Scale transition
  scale,

  /// Rotation transition
  rotation,

  /// Slide and fade combined
  slideAndFade,
}

/// Custom Page Route
///
/// Provides custom page transitions for navigation
class CustomPageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;
  final RouteTransitionType transitionType;
  final Duration duration;

  CustomPageRoute({
    required this.builder,
    RouteSettings? settings,
    this.transitionType = RouteTransitionType.material,
    this.duration = const Duration(milliseconds: 300),
  }) : super(settings: settings);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    switch (transitionType) {
      case RouteTransitionType.material:
        return _buildMaterialTransition(animation, secondaryAnimation, child);

      case RouteTransitionType.fade:
        return _buildFadeTransition(animation, child);

      case RouteTransitionType.slideFromRight:
        return _buildSlideTransition(
          animation,
          child,
          begin: const Offset(1.0, 0.0),
        );

      case RouteTransitionType.slideFromLeft:
        return _buildSlideTransition(
          animation,
          child,
          begin: const Offset(-1.0, 0.0),
        );

      case RouteTransitionType.slideFromBottom:
        return _buildSlideTransition(
          animation,
          child,
          begin: const Offset(0.0, 1.0),
        );

      case RouteTransitionType.slideFromTop:
        return _buildSlideTransition(
          animation,
          child,
          begin: const Offset(0.0, -1.0),
        );

      case RouteTransitionType.scale:
        return _buildScaleTransition(animation, child);

      case RouteTransitionType.rotation:
        return _buildRotationTransition(animation, child);

      case RouteTransitionType.slideAndFade:
        return _buildSlideAndFadeTransition(animation, child);

      default:
        return child;
    }
  }

  /// Material Transition
  Widget _buildMaterialTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
      ),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  /// Fade Transition
  Widget _buildFadeTransition(Animation<double> animation, Widget child) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      ),
      child: child,
    );
  }

  /// Slide Transition
  Widget _buildSlideTransition(
    Animation<double> animation,
    Widget child, {
    required Offset begin,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ),
      ),
      child: child,
    );
  }

  /// Scale Transition
  Widget _buildScaleTransition(Animation<double> animation, Widget child) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.8,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ),
      ),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  /// Rotation Transition
  Widget _buildRotationTransition(Animation<double> animation, Widget child) {
    return RotationTransition(
      turns: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
      ),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  /// Slide and Fade Transition
  Widget _buildSlideAndFadeTransition(
    Animation<double> animation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ),
      ),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeIn,
        ),
        child: child,
      ),
    );
  }
}

/// Page Transition Extensions
///
/// Extension methods for easier page transitions
extension PageTransitionExtension on Widget {
  /// Create a route with custom transition
  Route<T> toRoute<T>({
    RouteTransitionType transition = RouteTransitionType.material,
    Duration duration = const Duration(milliseconds: 300),
    RouteSettings? settings,
  }) {
    return CustomPageRoute<T>(
      builder: (context) => this,
      transitionType: transition,
      duration: duration,
      settings: settings,
    );
  }

  /// Navigate to this widget with transition
  Future<T?> navigate<T>(
    BuildContext context, {
    RouteTransitionType transition = RouteTransitionType.material,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Navigator.push<T>(
      context,
      CustomPageRoute<T>(
        builder: (context) => this,
        transitionType: transition,
        duration: duration,
      ),
    );
  }

  /// Replace current route with this widget
  Future<T?> replaceWith<T>(
    BuildContext context, {
    RouteTransitionType transition = RouteTransitionType.material,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Navigator.pushReplacement<T, void>(
      context,
      CustomPageRoute<T>(
        builder: (context) => this,
        transitionType: transition,
        duration: duration,
      ),
    );
  }
}
