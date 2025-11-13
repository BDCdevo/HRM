import 'package:flutter/material.dart';

/// Success Animation Widget
///
/// Animated checkmark for success states
class SuccessAnimation extends StatefulWidget {
  final VoidCallback? onComplete;
  final double size;
  final Color color;

  const SuccessAnimation({
    super.key,
    this.onComplete,
    this.size = 120,
    this.color = const Color(0xFF10B981),
  });

  @override
  State<SuccessAnimation> createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<SuccessAnimation>
    with TickerProviderStateMixin {
  late AnimationController _circleController;
  late AnimationController _checkController;
  late Animation<double> _circleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();

    // Circle animation
    _circleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _circleAnimation = CurvedAnimation(
      parent: _circleController,
      curve: Curves.easeInOut,
    );

    // Check animation
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeInOut,
    );

    // Start animations
    _circleController.forward().then((_) {
      _checkController.forward().then((_) {
        if (widget.onComplete != null) {
          Future.delayed(const Duration(milliseconds: 500), () {
            widget.onComplete!();
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _circleController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circle
          AnimatedBuilder(
            animation: _circleAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _CirclePainter(
                  progress: _circleAnimation.value,
                  color: widget.color,
                ),
              );
            },
          ),

          // Checkmark
          AnimatedBuilder(
            animation: _checkAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size * 0.5, widget.size * 0.5),
                painter: _CheckPainter(
                  progress: _checkAnimation.value,
                  color: widget.color,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double progress;
  final Color color;

  _CirclePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) * progress;

    canvas.drawCircle(center, radius, paint);

    // Border
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(_CirclePainter oldDelegate) => oldDelegate.progress != progress;
}

class _CheckPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CheckPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Start point
    final startX = size.width * 0.2;
    final startY = size.height * 0.5;

    // Middle point
    final midX = size.width * 0.4;
    final midY = size.height * 0.7;

    // End point
    final endX = size.width * 0.9;
    final endY = size.height * 0.2;

    if (progress < 0.5) {
      // First part of checkmark
      final currentProgress = progress * 2;
      path.moveTo(startX, startY);
      path.lineTo(
        startX + (midX - startX) * currentProgress,
        startY + (midY - startY) * currentProgress,
      );
    } else {
      // Complete first part and draw second part
      final currentProgress = (progress - 0.5) * 2;
      path.moveTo(startX, startY);
      path.lineTo(midX, midY);
      path.lineTo(
        midX + (endX - midX) * currentProgress,
        midY + (endY - midY) * currentProgress,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) => oldDelegate.progress != progress;
}

/// Success Dialog
void showSuccessDialog(
  BuildContext context, {
  required String title,
  String? message,
  VoidCallback? onComplete,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SuccessAnimation(
              onComplete: () {
                Navigator.of(context).pop();
                if (onComplete != null) {
                  onComplete();
                }
              },
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color,
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

/// Success Snackbar
void showSuccessSnackbar(
  BuildContext context, {
  required String message,
  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF10B981),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      duration: duration,
    ),
  );
}
