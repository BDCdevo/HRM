import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';

/// Voice Recording Widget - WhatsApp Style
///
/// Features:
/// - Long press to start recording
/// - Slide to cancel
/// - Release to send
/// - Timer display
/// - Waveform animation
class VoiceRecordingWidget extends StatefulWidget {
  final Future<void> Function() onRecordingComplete;
  final Future<void> Function(String path) onSendRecording;
  final VoidCallback onCancel;

  const VoiceRecordingWidget({
    super.key,
    required this.onRecordingComplete,
    required this.onSendRecording,
    required this.onCancel,
  });

  @override
  State<VoiceRecordingWidget> createState() => _VoiceRecordingWidgetState();
}

class _VoiceRecordingWidgetState extends State<VoiceRecordingWidget>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  int _recordDuration = 0;
  late AnimationController _animationController;
  bool _isCanceled = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordDuration++;
      });
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Delete/Cancel button
          IconButton(
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
            icon: Icon(
              Icons.delete_outline,
              color: const Color(0xFFEF4444), // Red
              size: 26,
            ),
            onPressed: () {
              _isCanceled = true;
              widget.onCancel();
            },
          ),

          const SizedBox(width: 8),

          // Recording indicator and timer
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkInput : AppColors.background,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  // Animated waveform
                  Row(
                    children: List.generate(5, (index) {
                      return AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          final delay = index * 0.1;
                          final animValue = (_animationController.value - delay).clamp(0.0, 1.0);
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: 3,
                            height: 12 + (animValue * 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF25D366), // WhatsApp green
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        },
                      );
                    }),
                  ),

                  const SizedBox(width: 12),

                  // Timer
                  Text(
                    _formatDuration(_recordDuration),
                    style: AppTextStyles.voiceTimer.copyWith(
                      fontSize: 16,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),

                  const Spacer(),

                  // Slide to cancel hint
                  Row(
                    children: [
                      Icon(
                        Icons.chevron_left,
                        size: 20,
                        color: isDark
                            ? const Color(0xFF8696A0)
                            : const Color(0xFF54656F),
                      ),
                      Text(
                        'Slide to cancel',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.whatsappGrayLight
                              : AppColors.whatsappGrayMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Send button
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF25D366), // WhatsApp green
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.send, color: AppColors.white, size: 22),
              onPressed: () async {
                if (!_isCanceled) {
                  await widget.onRecordingComplete();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
