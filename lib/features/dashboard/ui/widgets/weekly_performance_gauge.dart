import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/styles/app_colors.dart';

/// Weekly Performance Mountain Widget
///
/// A fun, engaging widget showing an employee climbing a mountain
/// to reach the 48-hour weekly target
class WeeklyPerformanceGauge extends StatefulWidget {
  /// Current hours worked this week
  final double hoursWorked;

  /// Target hours for the week (default 48)
  final double targetHours;

  /// Animation duration
  final Duration animationDuration;

  const WeeklyPerformanceGauge({
    super.key,
    required this.hoursWorked,
    this.targetHours = 48.0,
    this.animationDuration = const Duration(milliseconds: 2000),
  });

  @override
  State<WeeklyPerformanceGauge> createState() => _WeeklyPerformanceGaugeState();
}

class _WeeklyPerformanceGaugeState extends State<WeeklyPerformanceGauge>
    with TickerProviderStateMixin {
  late AnimationController _climbController;
  late AnimationController _bounceController;
  late Animation<double> _climbAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    // Main climb animation
    _climbController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _climbAnimation = Tween<double>(
      begin: 0.0,
      end: _calculateProgress(),
    ).animate(CurvedAnimation(
      parent: _climbController,
      curve: Curves.easeOutCubic,
    ));

    // Bounce animation for climber
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _climbController.forward();
        _bounceController.repeat(reverse: true);
      }
    });
  }

  @override
  void didUpdateWidget(WeeklyPerformanceGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hoursWorked != widget.hoursWorked ||
        oldWidget.targetHours != widget.targetHours) {
      _climbAnimation = Tween<double>(
        begin: _climbAnimation.value,
        end: _calculateProgress(),
      ).animate(CurvedAnimation(
        parent: _climbController,
        curve: Curves.easeOutCubic,
      ));
      _climbController.forward(from: 0);
    }
  }

  double _calculateProgress() {
    return (widget.hoursWorked / widget.targetHours).clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _climbController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.backgroundLight;

    final percentage = (_calculateProgress() * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Mountain illustration with climber
          SizedBox(
            height: 220,
            child: AnimatedBuilder(
              animation: Listenable.merge([_climbAnimation, _bounceAnimation]),
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(double.infinity, 220),
                  painter: _MountainPainter(
                    progress: _climbAnimation.value,
                    bounceValue: _bounceAnimation.value,
                    isDark: isDark,
                    hoursWorked: widget.hoursWorked,
                    targetHours: widget.targetHours,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Progress info row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Hours worked
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.hoursWorked.toStringAsFixed(1)}h',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    'worked',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),

              // Motivational message
              Expanded(
                child: Center(
                  child: Text(
                    _getMotivationalMessage(percentage),
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              // Target
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${widget.targetHours.toInt()}h',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    'target',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Progress bar with percentage badge above
          Column(
            children: [
              // Percentage badge row
              AnimatedBuilder(
                animation: _climbAnimation,
                builder: (context, child) {
                  return Align(
                    alignment: Alignment(
                      (_climbAnimation.value * 2) - 1,
                      0,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.white : AppColors.textPrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$percentage%',
                        style: TextStyle(
                          color: isDark ? AppColors.textPrimary : AppColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              // Progress bar
              Stack(
                children: [
                  // Background
                  Container(
                    height: 10,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.white.withValues(alpha: 0.1)
                          : AppColors.textPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  // Progress
                  AnimatedBuilder(
                    animation: _climbAnimation,
                    builder: (context, child) {
                      return FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _climbAnimation.value,
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.white : AppColors.textPrimary,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMotivationalMessage(int percentage) {
    if (percentage >= 100) return '🎉 Summit reached!';
    if (percentage >= 80) return '💪 Almost there!';
    if (percentage >= 60) return '🔥 Great progress!';
    if (percentage >= 40) return '⚡ Keep climbing!';
    if (percentage >= 20) return '🚀 Good start!';
    return '🏔️ Start climbing!';
  }
}

/// Custom Painter for Mountain with Climber
class _MountainPainter extends CustomPainter {
  final double progress;
  final double bounceValue;
  final bool isDark;
  final double hoursWorked;
  final double targetHours;

  _MountainPainter({
    required this.progress,
    required this.bounceValue,
    required this.isDark,
    required this.hoursWorked,
    required this.targetHours,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Colors
    final mountainColorBack = isDark
        ? AppColors.white.withValues(alpha: 0.08)
        : AppColors.textPrimary.withValues(alpha: 0.05);
    final mountainColorFront = isDark
        ? AppColors.white.withValues(alpha: 0.15)
        : AppColors.textPrimary.withValues(alpha: 0.1);
    final pathColor = isDark
        ? AppColors.white.withValues(alpha: 0.4)
        : AppColors.textPrimary.withValues(alpha: 0.25);
    final climberColor = isDark ? AppColors.white : AppColors.textPrimary;
    final flagColor = AppColors.primary;
    final snowColor = isDark
        ? AppColors.white.withValues(alpha: 0.3)
        : AppColors.white;

    // Draw background mountains
    _drawBackMountain(canvas, width, height, mountainColorBack);

    // Draw main mountain
    _drawMainMountain(canvas, width, height, mountainColorFront);

    // Draw snow cap
    _drawSnowCap(canvas, width, height, snowColor);

    // Draw climbing path
    final pathPoints = _getPathPoints(width, height);
    _drawClimbingPath(canvas, pathPoints, pathColor);

    // Draw checkpoints
    _drawCheckpoints(canvas, pathPoints, isDark);

    // Draw flag at peak
    _drawFlag(canvas, width, height, flagColor, climberColor);

    // Draw climber
    _drawClimber(canvas, pathPoints, climberColor, bounceValue);

    // Draw sun/moon
    _drawSunMoon(canvas, width, isDark);
  }

  void _drawBackMountain(Canvas canvas, double width, double height, Color color) {
    final path = Path();
    path.moveTo(width * 0.6, height);
    path.lineTo(width * 0.85, height * 0.35);
    path.lineTo(width * 1.1, height);
    path.close();

    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawMainMountain(Canvas canvas, double width, double height, Color color) {
    final path = Path();
    path.moveTo(0, height);
    path.lineTo(width * 0.1, height * 0.75);
    path.quadraticBezierTo(width * 0.15, height * 0.7, width * 0.2, height * 0.72);
    path.lineTo(width * 0.5, height * 0.12); // Peak
    path.lineTo(width * 0.8, height * 0.72);
    path.quadraticBezierTo(width * 0.85, height * 0.7, width * 0.9, height * 0.75);
    path.lineTo(width, height);
    path.close();

    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawSnowCap(Canvas canvas, double width, double height, Color color) {
    final path = Path();
    path.moveTo(width * 0.42, height * 0.28);
    path.lineTo(width * 0.5, height * 0.12);
    path.lineTo(width * 0.58, height * 0.28);
    path.quadraticBezierTo(width * 0.52, height * 0.32, width * 0.48, height * 0.30);
    path.quadraticBezierTo(width * 0.45, height * 0.32, width * 0.42, height * 0.28);
    path.close();

    canvas.drawPath(path, Paint()..color = color);
  }

  List<Offset> _getPathPoints(double width, double height) {
    return [
      Offset(width * 0.15, height * 0.85),
      Offset(width * 0.22, height * 0.72),
      Offset(width * 0.28, height * 0.62),
      Offset(width * 0.34, height * 0.52),
      Offset(width * 0.40, height * 0.42),
      Offset(width * 0.46, height * 0.30),
      Offset(width * 0.50, height * 0.15), // Peak
    ];
  }

  void _drawClimbingPath(Canvas canvas, List<Offset> points, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Draw smooth path
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      final midX = (p0.dx + p1.dx) / 2;
      final midY = (p0.dy + p1.dy) / 2;
      path.quadraticBezierTo(p0.dx, p0.dy, midX, midY);
    }
    path.lineTo(points.last.dx, points.last.dy);

    // Draw dashed
    final dashPath = Path();
    const dashLength = 8.0;
    const gapLength = 5.0;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final start = distance;
        final end = (distance + dashLength).clamp(0.0, metric.length);
        dashPath.addPath(
          metric.extractPath(start, end),
          Offset.zero,
        );
        distance += dashLength + gapLength;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  void _drawCheckpoints(Canvas canvas, List<Offset> points, bool isDark) {
    final dotPaint = Paint()
      ..color = isDark
          ? AppColors.white.withValues(alpha: 0.3)
          : AppColors.textPrimary.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    // Draw dots at checkpoints (skip first and last)
    for (int i = 1; i < points.length - 1; i++) {
      canvas.drawCircle(points[i], 4, dotPaint);
    }
  }

  void _drawFlag(Canvas canvas, double width, double height, Color flagColor, Color poleColor) {
    final peakX = width * 0.5;
    final peakY = height * 0.12;

    // Flag pole
    final polePaint = Paint()
      ..color = poleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(peakX, peakY),
      Offset(peakX, peakY - 30),
      polePaint,
    );

    // Flag (waving effect)
    final flagPath = Path();
    flagPath.moveTo(peakX + 2, peakY - 30);
    flagPath.quadraticBezierTo(
      peakX + 15,
      peakY - 28,
      peakX + 22,
      peakY - 24,
    );
    flagPath.quadraticBezierTo(
      peakX + 15,
      peakY - 20,
      peakX + 2,
      peakY - 18,
    );
    flagPath.close();

    canvas.drawPath(flagPath, Paint()..color = flagColor);

    // "48h" label
    final labelStyle = TextStyle(
      color: flagColor,
      fontSize: 11,
      fontWeight: FontWeight.bold,
    );
    final label = TextSpan(text: '${targetHours.toInt()}h', style: labelStyle);
    final painter = TextPainter(text: label, textDirection: TextDirection.ltr);
    painter.layout();
    painter.paint(canvas, Offset(peakX + 25, peakY - 30));
  }

  void _drawClimber(Canvas canvas, List<Offset> points, Color color, double bounce) {
    // Calculate position along path
    final pathLength = points.length - 1;
    final currentIndex = (progress * pathLength).floor();
    final t = (progress * pathLength) - currentIndex;

    Offset pos;
    if (currentIndex >= pathLength) {
      pos = points.last;
    } else {
      final start = points[currentIndex];
      final end = points[currentIndex + 1];
      pos = Offset(
        start.dx + (end.dx - start.dx) * t,
        start.dy + (end.dy - start.dy) * t,
      );
    }

    // Add bounce effect
    final bounceOffset = math.sin(bounce * math.pi) * 3;
    pos = Offset(pos.dx, pos.dy - bounceOffset);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Head with hat
    canvas.drawCircle(Offset(pos.dx, pos.dy - 20), 7, fillPaint);

    // Hat
    final hatPath = Path();
    hatPath.moveTo(pos.dx - 9, pos.dy - 25);
    hatPath.lineTo(pos.dx + 9, pos.dy - 25);
    hatPath.lineTo(pos.dx + 5, pos.dy - 32);
    hatPath.lineTo(pos.dx - 5, pos.dy - 32);
    hatPath.close();
    canvas.drawPath(hatPath, fillPaint);

    // Body
    canvas.drawLine(
      Offset(pos.dx, pos.dy - 13),
      Offset(pos.dx, pos.dy + 2),
      paint,
    );

    // Backpack
    final backpackRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(pos.dx + 6, pos.dy - 5), width: 8, height: 12),
      const Radius.circular(2),
    );
    canvas.drawRRect(backpackRect, Paint()..color = color.withValues(alpha: 0.6));

    // Arms (climbing pose)
    canvas.drawLine(
      Offset(pos.dx, pos.dy - 8),
      Offset(pos.dx - 10, pos.dy - 18),
      paint,
    );
    canvas.drawLine(
      Offset(pos.dx, pos.dy - 8),
      Offset(pos.dx + 10, pos.dy - 15),
      paint,
    );

    // Legs (walking)
    final legOffset = math.sin(bounce * math.pi * 2) * 4;
    canvas.drawLine(
      Offset(pos.dx, pos.dy + 2),
      Offset(pos.dx - 6 + legOffset, pos.dy + 14),
      paint,
    );
    canvas.drawLine(
      Offset(pos.dx, pos.dy + 2),
      Offset(pos.dx + 6 - legOffset, pos.dy + 14),
      paint,
    );

    // Hours bubble
    final bubbleColor = color;
    final bubbleRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(pos.dx, pos.dy - 48), width: 36, height: 20),
      const Radius.circular(10),
    );
    canvas.drawRRect(bubbleRect, Paint()..color = bubbleColor);

    // Bubble pointer
    final pointerPath = Path();
    pointerPath.moveTo(pos.dx - 5, pos.dy - 38);
    pointerPath.lineTo(pos.dx, pos.dy - 33);
    pointerPath.lineTo(pos.dx + 5, pos.dy - 38);
    canvas.drawPath(pointerPath, Paint()..color = bubbleColor);

    // Hours text
    final hoursStyle = TextStyle(
      color: isDark ? AppColors.textPrimary : AppColors.white,
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );
    final hoursLabel = TextSpan(text: '${hoursWorked.toStringAsFixed(0)}h', style: hoursStyle);
    final hoursPainter = TextPainter(text: hoursLabel, textDirection: TextDirection.ltr);
    hoursPainter.layout();
    hoursPainter.paint(
      canvas,
      Offset(pos.dx - hoursPainter.width / 2, pos.dy - 53),
    );
  }

  void _drawSunMoon(Canvas canvas, double width, bool isDark) {
    final centerX = width * 0.85;
    const centerY = 25.0;
    const radius = 15.0;

    if (isDark) {
      // Moon
      final moonPaint = Paint()
        ..color = AppColors.white.withValues(alpha: 0.8)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(centerX, centerY), radius, moonPaint);

      // Moon shadow
      canvas.drawCircle(
        Offset(centerX + 5, centerY - 3),
        radius - 2,
        Paint()..color = AppColors.darkCard,
      );
    } else {
      // Sun
      final sunPaint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.8)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(centerX, centerY), radius, sunPaint);

      // Sun rays
      final rayPaint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < 8; i++) {
        final angle = (i * math.pi / 4);
        final startR = radius + 4;
        final endR = radius + 10;
        canvas.drawLine(
          Offset(centerX + startR * math.cos(angle), centerY + startR * math.sin(angle)),
          Offset(centerX + endR * math.cos(angle), centerY + endR * math.sin(angle)),
          rayPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_MountainPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.bounceValue != bounceValue ||
        oldDelegate.isDark != isDark ||
        oldDelegate.hoursWorked != hoursWorked;
  }
}
