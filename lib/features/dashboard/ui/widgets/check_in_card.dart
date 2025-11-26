import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/services/location_service.dart';
import '../../../attendance/logic/cubit/attendance_cubit.dart';
import '../../../attendance/data/models/attendance_model.dart';
import '../../../attendance/ui/widgets/late_reason_bottom_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

/// Check In Card Widget
///
/// Card with fingerprint icon and Check In/Check Out buttons based on session status
class CheckInCard extends StatelessWidget {
  final AttendanceStatusModel? status;

  const CheckInCard({super.key, this.status});

  @override
  Widget build(BuildContext context) {
    // Use hasActiveSession to determine current state (supports multiple sessions)
    final hasActiveSession = status?.hasActiveSession ?? false;
    final lastCheckInTime = status?.currentSession?.checkInTime;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: AppColors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Lottie Animation Container
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: hasActiveSession
                  ? AppColors.accent.withOpacity(0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: hasActiveSession
                ? Icon(Icons.logout_rounded, size: 64, color: AppColors.accent)
                : Lottie.asset(
                    'assets/animations/welcome.json',
                    width: double.infinity,
                    fit: BoxFit.contain,
                    repeat: true,
                    animate: true,
                    // Performance optimizations
                    frameRate: FrameRate(30),
                    renderCache: RenderCache.raster,
                  ),
          ),
          // const SizedBox(height: 24),

          // Check In/Out Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: hasActiveSession
                  ? () => _handleCheckOut(context)
                  : () => _handleCheckIn(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasActiveSession
                    ? AppColors.accent
                    : AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
              child: Text(hasActiveSession ? 'Check Out' : 'Check In'),
            ),
          ),
        ],
      ),
    );
  }

  /// Handle Check Out
  void _handleCheckOut(BuildContext context) {
    context.read<AttendanceCubit>().checkOut();
  }

  /// Handle Check In with GPS Location and Late Reason
  Future<void> _handleCheckIn(BuildContext context) async {
    print('🟣🟣🟣 _handleCheckIn METHOD STARTED 🟣🟣🟣');
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Getting your location...'),
                ],
              ),
            ),
          ),
        ),
      );

      print('🔍 Starting to get location...');

      // Get current position
      Position position = await LocationService.getCurrentPosition();

      print('✅ Got location: ${position.latitude}, ${position.longitude}');
      print('📍 Accuracy: ${position.accuracy} meters');

      // Close loading dialog
      if (!context.mounted) {
        print('⚠️ Context not mounted after getting location');
        return;
      }

      Navigator.of(context).pop();

      // Check if employee is late
      print('🔍 ========== DEBUG: Checking if late ==========');
      print('🔍 status is null? ${status == null}');
      if (status != null) {
        print('🔍 Work Plan exists? ${status!.workPlan != null}');
        if (status!.workPlan != null) {
          print('🔍 Work Plan Name: ${status!.workPlan!.name}');
          print('🔍 Work Plan Start Time: ${status!.workPlan!.startTime}');
          print('🔍 Work Plan End Time: ${status!.workPlan!.endTime}');
          print(
            '🔍 Work Plan Permission Minutes: ${status!.workPlan!.permissionMinutes}',
          );
        }
      }
      print('🔍 ==========================================');

      String? lateReason;

      // ✅ Check if this is the first session today
      final int totalSessions = status?.sessionsSummary?.totalSessions ?? 0;
      final bool isFirstSession = totalSessions == 0;

      // ✅ Check if employee is late (client-side calculation)
      final bool isLate = _checkIfLate(status);

      print('📊 Total sessions today: $totalSessions');
      print('🎯 Is first session? $isFirstSession');
      print('⏰ Is late? $isLate');
      print('⏰⏰⏰ Will show bottom sheet? ${isFirstSession && isLate} ⏰⏰⏰');

      // Show bottom sheet only if:
      // 1. This is the FIRST SESSION of the day
      // 2. AND employee is LATE
      if (isFirstSession && isLate) {
        print('⏰ First session + Late → Showing late reason bottom sheet...');
        lateReason = await showLateReasonBottomSheet(context);
        print('⏰ Late reason from bottom sheet: $lateReason');

        // If user cancelled the bottom sheet, don't proceed with check-in
        if (lateReason == null) {
          print('⚠️ User cancelled late reason input');
          return;
        }
      } else if (!isFirstSession) {
        print(
          '⏰ Not first session (already checked in today) - proceeding without bottom sheet',
        );
      } else if (!isLate) {
        print('⏰ Employee is NOT late - proceeding without bottom sheet');
      }

      if (!context.mounted) {
        print('⚠️ Context not mounted after late reason input');
        return;
      }

      print('🚀 Calling checkIn with location and late reason...');

      // Perform check-in with location and late reason
      await context.read<AttendanceCubit>().checkIn(
        latitude: position.latitude,
        longitude: position.longitude,
        lateReason: lateReason,
      );

      print('✅ CheckIn method called');
    } catch (e) {
      print('❌ Error in _handleCheckIn: $e');
      print('❌ Error type: ${e.runtimeType}');

      // Close loading dialog if open
      if (context.mounted) {
        // Try to pop the dialog, but catch any errors
        try {
          Navigator.of(context).pop();
        } catch (popError) {
          print('⚠️ Could not pop dialog: $popError');
        }
      }

      // Show error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📍 ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
            action: e.toString().contains('settings')
                ? SnackBarAction(
                    label: 'Open Settings',
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

  /// Check if employee is late
  ///
  /// Compares current time with work plan start time
  /// Returns true if employee is checking in after work start time
  /// Supports both 12-hour (10:00 AM) and 24-hour (10:00:00) formats
  bool _checkIfLate(AttendanceStatusModel? status) {
    print('🕐 ========== CHECKING IF LATE ==========');

    if (status == null) {
      print('⏰ ❌ Status is null - cannot determine if late');
      print('🕐 ====================================');
      return false;
    }

    if (status.workPlan == null) {
      print('⏰ ❌ Work plan is null - cannot determine if late');
      print('🕐 ====================================');
      return false;
    }

    final workPlan = status.workPlan!;
    print('⏰ ✅ Work Plan Found:');
    print('   - Name: ${workPlan.name}');
    print('   - Start Time: ${workPlan.startTime}');
    print('   - End Time: ${workPlan.endTime}');

    // Check if work plan has start time
    if (workPlan.startTime == null || workPlan.startTime!.isEmpty) {
      print('⏰ ❌ Start time is empty - cannot determine if late');
      print('🕐 ====================================');
      return false;
    }

    try {
      final now = DateTime.now();
      DateTime? workStartTime;
      final startTimeStr = workPlan.startTime!.trim();

      print('⏰ Current Time: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(now)}');
      print('⏰ Current Time (formatted): ${DateFormat('hh:mm a').format(now)}');
      print('⏰ Work Start Time String: "$startTimeStr"');

      // Try to parse different time formats
      if (startTimeStr.contains('AM') ||
          startTimeStr.contains('PM') ||
          startTimeStr.toLowerCase().contains('am') ||
          startTimeStr.toLowerCase().contains('pm')) {
        // 12-hour format: "10:00 AM" or "06:00 PM"
        try {
          final parsedTime = DateFormat('hh:mm a').parse(startTimeStr);
          workStartTime = DateTime(
            now.year,
            now.month,
            now.day,
            parsedTime.hour,
            parsedTime.minute,
          );
          print('⏰ ✅ Parsed as 12-hour format');
        } catch (e) {
          print('⏰ ❌ Failed to parse 12-hour format: $e');
          // Try lowercase
          try {
            final parsedTime = DateFormat(
              'hh:mm a',
            ).parse(startTimeStr.toUpperCase());
            workStartTime = DateTime(
              now.year,
              now.month,
              now.day,
              parsedTime.hour,
              parsedTime.minute,
            );
            print('⏰ ✅ Parsed as 12-hour format (uppercase)');
          } catch (e2) {
            print('⏰ ❌ Failed to parse 12-hour format (uppercase): $e2');
          }
        }
      } else {
        // 24-hour format: "10:00:00" or "10:00"
        final startTimeParts = startTimeStr.split(':');
        if (startTimeParts.length >= 2) {
          final int startHour = int.tryParse(startTimeParts[0]) ?? 0;
          final int startMinute = int.tryParse(startTimeParts[1]) ?? 0;

          workStartTime = DateTime(
            now.year,
            now.month,
            now.day,
            startHour,
            startMinute,
          );
          print('⏰ ✅ Parsed as 24-hour format ($startHour:$startMinute)');
        } else {
          print('⏰ ❌ Invalid time parts: ${startTimeParts.length}');
        }
      }

      if (workStartTime == null) {
        print('⏰ ❌ Could not parse work start time');
        print('🕐 ====================================');
        return false;
      }

      print(
        '⏰ Work Start Time (parsed): ${DateFormat('yyyy-MM-dd HH:mm:ss').format(workStartTime)}',
      );
      print(
        '⏰ Work Start Time (formatted): ${DateFormat('hh:mm a').format(workStartTime)}',
      );

      // Calculate minutes difference
      final int minutesDifference = now.difference(workStartTime).inMinutes;
      final int gracePeriod = workPlan.permissionMinutes;

      print('⏰ Grace Period (Permission Minutes): $gracePeriod minutes');
      print('⏰ Minutes Difference: $minutesDifference minutes');

      // Employee is late if current time is after work start time + grace period
      final bool isLate = minutesDifference > gracePeriod;

      print('⏰ Comparison Result:');
      print('   - Current > Start Time? ${now.isAfter(workStartTime)}');
      if (now.isAfter(workStartTime)) {
        print('   - Minutes After Start: $minutesDifference minutes');
        print('   - Grace Period: $gracePeriod minutes');
        print('   - Is Late (after applying grace period)? $isLate');
        if (isLate) {
          print(
            '   - Minutes Late (after grace): ${minutesDifference - gracePeriod} minutes',
          );
        } else {
          print('   - Within Grace Period ✓');
        }
      } else {
        final minutesEarly = workStartTime.difference(now).inMinutes;
        print('   - Minutes Early: $minutesEarly minutes');
        print('   - Is Late: false (arrived early)');
      }
      print('🕐 ====================================');

      return isLate;
    } catch (e, stackTrace) {
      print('❌ Error in _checkIfLate: $e');
      print('❌ Stack trace: $stackTrace');
      print('🕐 ====================================');
      return false;
    }
  }
}
