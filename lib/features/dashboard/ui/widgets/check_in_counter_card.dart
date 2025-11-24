import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/services/location_service.dart';
import '../../../attendance/logic/cubit/attendance_cubit.dart';

/// Check In Counter Card Widget
///
/// Displays active check-in timer with Check Point and Check Out buttons
class CheckInCounterCard extends StatefulWidget {
  final dynamic status;

  const CheckInCounterCard({super.key, required this.status});

  @override
  State<CheckInCounterCard> createState() => _CheckInCounterCardState();
}

class _CheckInCounterCardState extends State<CheckInCounterCard> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateInitialElapsed();
    _startTimer();
  }

  @override
  void didUpdateWidget(CheckInCounterCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recalculate elapsed time if status changed
    if (oldWidget.status != widget.status) {
      _calculateInitialElapsed();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _calculateInitialElapsed() {
    try {
      print('🕐 ========== CALCULATING TOTAL ELAPSED TIME ==========');

      // Get total duration of all sessions (completed + active)
      Duration totalElapsed = Duration.zero;

      // Step 1: Get completed sessions duration
      if (widget.status?.sessionsSummary != null) {
        final totalDurationStr = widget.status!.sessionsSummary!.totalDuration;
        print('📊 Total Duration from API: $totalDurationStr');

        if (totalDurationStr.contains(':')) {
          final parts = totalDurationStr.split(':');
          final hours = int.parse(parts[0]);
          final minutes = int.parse(parts[1]);
          final seconds = parts.length > 2
              ? int.parse(parts[2].split('.')[0])
              : 0;

          // This totalDuration includes ALL sessions (completed + active at API call time)
          totalElapsed = Duration(
            hours: hours,
            minutes: minutes,
            seconds: seconds,
          );
          print('✅ Parsed total duration: $totalElapsed');
        }
      }

      // Step 2: If there's an active session, calculate its real-time duration
      if (widget.status?.currentSession != null) {
        final checkInTimeStr = widget.status!.currentSession!.checkInTime;
        final currentSessionDurationStr =
            widget.status!.currentSession!.duration;

        print('📍 Active session check-in time: $checkInTimeStr');
        print(
          '📍 Active session duration from API: $currentSessionDurationStr',
        );

        if (checkInTimeStr != null && checkInTimeStr.contains(':')) {
          final now = DateTime.now();

          // Parse check-in time
          final parts = checkInTimeStr.split(':');
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          final second = parts.length > 2
              ? int.parse(parts[2].split('.')[0])
              : 0;

          DateTime checkInTime = DateTime(
            now.year,
            now.month,
            now.day,
            hour,
            minute,
            second,
          );

          // If check-in time is in the future, it was yesterday
          if (checkInTime.isAfter(now)) {
            checkInTime = checkInTime.subtract(const Duration(days: 1));
          }

          // Calculate real-time active session duration
          final activeSessionDuration = now.difference(checkInTime);

          // Parse current session duration from API
          Duration apiSessionDuration = Duration.zero;
          if (currentSessionDurationStr != null &&
              currentSessionDurationStr.contains(':')) {
            final parts = currentSessionDurationStr.split(':');
            final hours = int.parse(parts[0]);
            final minutes = int.parse(parts[1]);
            final seconds = parts.length > 2
                ? int.parse(parts[2].split('.')[0])
                : 0;
            apiSessionDuration = Duration(
              hours: hours,
              minutes: minutes,
              seconds: seconds,
            );
          }

          // Calculate completed sessions duration (total - active session from API)
          final completedSessionsDuration = totalElapsed - apiSessionDuration;

          // Total = completed + real-time active
          totalElapsed = completedSessionsDuration + activeSessionDuration;

          print('✅ Completed sessions duration: $completedSessionsDuration');
          print('✅ Active session real-time duration: $activeSessionDuration');
          print('✅ Total elapsed (completed + active): $totalElapsed');
        }
      } else {
        print(
          'ℹ️ No active session, using total duration from API: $totalElapsed',
        );
      }

      _elapsed = totalElapsed;
      if (_elapsed.isNegative) {
        _elapsed = Duration.zero;
      }

      print('🕐 ====================================');
    } catch (e, stackTrace) {
      print('❌ Error calculating total elapsed time: $e');
      print('❌ Stack trace: $stackTrace');
      _elapsed = Duration.zero;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsed = Duration(seconds: _elapsed.inSeconds + 1);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Working Animation
          SizedBox(
            width: double.infinity,
            height: 180,
            child: _buildWorkingAnimation(),
          ),

          const SizedBox(height: 16),

          // Message
          Text(
            'Together We Grow Up',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              // Check Point Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Check Point - Coming Soon'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.location_on_outlined, size: 16),
                  label: const Text('Check Point'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B7280), // Gray
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Check Out Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleCheckOut(context),
                  icon: const Icon(Icons.logout, size: 16),
                  label: const Text('Check Out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Handle Check Out
  Future<void> _handleCheckOut(BuildContext context) async {
    try {
      // Get location for check-out (optional, but good to have)
      await LocationService.getCurrentPosition();

      if (context.mounted) {
        await context.read<AttendanceCubit>().checkOut();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Checked out successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
            action: e.toString().contains('permanently')
                ? SnackBarAction(
                    label: 'Settings',
                    textColor: AppColors.white,
                    onPressed: () async {
                      if (e.toString().contains('permanently')) {
                        await LocationService.openAppSettings();
                      } else {
                        await LocationService.openLocationSettings();
                      }
                    },
                  )
                : null,
          ),
        );
      }
    }
  }

  /// Build Working Animation
  Widget _buildWorkingAnimation() {
    return Lottie.asset(
      'assets/animations/working_online.json',
      width: double.infinity,
      fit: BoxFit.contain,
      repeat: true,
      animate: true,
      errorBuilder: (context, error, stackTrace) {
        // If animation fails to load, show icon
        return Center(
          child: Icon(Icons.work_outline, size: 80, color: AppColors.success),
        );
      },
    );
  }
}
