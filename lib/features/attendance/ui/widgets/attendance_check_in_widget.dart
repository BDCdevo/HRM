import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/services/location_service.dart';
import '../../logic/cubit/attendance_cubit.dart';
import '../../logic/cubit/attendance_state.dart';
import '../../data/models/attendance_model.dart';
import 'sessions_list_widget.dart';
import 'late_reason_bottom_sheet.dart';

/// Attendance Check-in Widget
///
/// Allows users to check in and check out
class AttendanceCheckInWidget extends StatefulWidget {
  AttendanceCheckInWidget({super.key});

  @override
  State<AttendanceCheckInWidget> createState() => _AttendanceCheckInWidgetState();
}

class _AttendanceCheckInWidgetState extends State<AttendanceCheckInWidget> {
  // Keep track of the last status loaded
  AttendanceStatusModel? _lastStatus;

  @override
  void initState() {
    super.initState();
    // Fetch today's status and sessions when widget loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AttendanceCubit>().fetchTodayStatus();
        context.read<AttendanceCubit>().fetchTodaySessions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get current date and time
    final now = DateTime.now();
    final String currentTime = DateFormat('hh:mm a').format(now);
    final String currentDate = DateFormat('EEEE, MMMM d, yyyy').format(now);

    return BlocConsumer<AttendanceCubit, AttendanceState>(
      listener: (context, state) {
        // Show success/error messages
        if (state is CheckInSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Checked in successfully at ${state.attendance.checkInTime ?? currentTime}'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );
          // Refresh status and sessions after successful check-in
          context.read<AttendanceCubit>().fetchTodayStatus();
          context.read<AttendanceCubit>().fetchTodaySessions();
        } else if (state is CheckOutSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Checked out successfully at ${state.attendance.checkOutTime ?? currentTime}'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );
          // Refresh status and sessions after successful check-out
          context.read<AttendanceCubit>().fetchTodayStatus();
          context.read<AttendanceCubit>().fetchTodaySessions();
        } else if (state is AttendanceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${state.displayMessage}'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      builder: (context, state) {
        // Save the last status when loaded
        if (state is AttendanceStatusLoaded) {
          _lastStatus = state.status;
          print('✅ Status loaded: hasActiveSession=${state.status.hasActiveSession}');
          print('✅ Has Late Reason: ${state.status.hasLateReason}');
          print('✅ Work Plan in status: ${state.status.workPlan != null ? "YES" : "NO"}');
          if (state.status.workPlan != null) {
            print('✅ Work Plan Details:');
            print('   - Name: ${state.status.workPlan!.name}');
            print('   - Start Time: ${state.status.workPlan!.startTime}');
            print('   - End Time: ${state.status.workPlan!.endTime}');
            print('   - Schedule: ${state.status.workPlan!.schedule}');
            print('   - Permission Minutes: ${state.status.workPlan!.permissionMinutes}');
          }
        }

        // Use last status if available, otherwise try to extract from current state
        final status = _lastStatus ?? (state is AttendanceStatusLoaded ? state.status : null);

        // Extract data from status
        final bool hasActiveSession = status?.hasActiveSession ?? false;
        final bool isCheckedIn = status?.hasCheckedIn ?? false;
        final bool isCheckedOut = status?.hasCheckedOut ?? false;
        final String? checkInTime = status?.dailySummary?.checkInTime ?? status?.checkInTime;
        final String? checkOutTime = status?.dailySummary?.checkOutTime ?? status?.checkOutTime;
        // FIXED: Use totalHours which sums all sessions, not just current session
        final double workingHours = status?.totalHours ?? 0.0;
        final int lateMinutes = status?.dailySummary?.lateMinutes ?? status?.lateMinutes ?? 0;
        final bool isLoading = state is AttendanceLoading;

        print('🎨 UI Building:');
        print('   State Type: ${state.runtimeType}');
        print('   _lastStatus exists: ${_lastStatus != null}');
        if (_lastStatus != null) {
          print('   _lastStatus.hasActiveSession: ${_lastStatus!.hasActiveSession}');
        }
        print('   Computed hasActiveSession: $hasActiveSession');
        print('   Computed isCheckedIn: $isCheckedIn');
        print('   Button will show: ${hasActiveSession ? "Check Out" : "Check In"}');

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      hasActiveSession ? AppColors.success : AppColors.primary,
                      (hasActiveSession ? AppColors.success : AppColors.primary)
                          .withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (hasActiveSession ? AppColors.success : AppColors.primary)
                          .withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        hasActiveSession ? Icons.check_circle : Icons.access_time,
                        color: AppColors.white,
                        size: 48,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Status
                    Text(
                      hasActiveSession
                          ? 'Active Session'
                          : isCheckedOut
                              ? 'Checked Out'
                              : 'No Active Session',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Time
                    Text(
                      currentTime,
                      style: AppTextStyles.displaySmall.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Date
                    Text(
                      currentDate,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Check-in/out Button
              CustomButton(
                text: isLoading
                    ? 'Processing...'
                    : hasActiveSession
                        ? 'Check Out'
                        : 'Check In',
                onPressed: isLoading || _lastStatus == null // ✅ Disable if status not loaded
                    ? null
                    : () async {
                        print('🔴 BUTTON PRESSED!');
                        print('🔴 hasActiveSession: $hasActiveSession');
                        print('🔴 isCheckedIn: $isCheckedIn');
                        print('🔴 isLoading: $isLoading');

                        if (hasActiveSession) {
                          print('🔴 Taking CHECK OUT path - Active session found');
                          // Check out (end current session)
                          context.read<AttendanceCubit>().checkOut();
                        } else {
                          print('🔴 Taking CHECK IN path - No active session');
                          // Check in (start new session) with GPS location
                          await _handleCheckIn(context);
                          print('🔴 Returned from _handleCheckIn');
                        }
                      },
                type: hasActiveSession ? ButtonType.error : ButtonType.secondary,
                size: ButtonSize.large,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        hasActiveSession ? Icons.logout : Icons.login,
                        color: AppColors.white,
                      ),
              ),

              const SizedBox(height: 32),

              // Today's Summary
              Text(
                'Today\'s Summary',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.login,
                      label: 'Check In',
                      value: checkInTime != null
                          ? _formatTime(checkInTime)
                          : '--:--',
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.logout,
                      label: 'Check Out',
                      value: checkOutTime != null
                          ? _formatTime(checkOutTime)
                          : '--:--',
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.timer,
                      label: 'Working Hours',
                      value: '${workingHours.toStringAsFixed(1)} hrs',
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.schedule,
                      label: 'Late Minutes',
                      value: '$lateMinutes min',
                      color: lateMinutes > 0 ? AppColors.warning : AppColors.success,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Location Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.info,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Make sure you are at your work location to check in/out.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Today's Sessions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today\'s Sessions',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Refresh button
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    color: AppColors.primary,
                    onPressed: () {
                      context.read<AttendanceCubit>().fetchTodaySessions();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Sessions List Widget
              const SessionsListWidget(),
            ],
          ),
        );
      },
    );
  }

  /// Handle Check In with GPS Location and Late Reason
  Future<void> _handleCheckIn(BuildContext context) async {
    print('🟣🟣🟣 _handleCheckIn METHOD STARTED 🟣🟣🟣');

    // ✅ CRITICAL: Check if status is loaded before proceeding
    if (_lastStatus == null) {
      print('❌ _lastStatus is NULL - cannot proceed with check-in');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⏳ Please wait for status to load...'),
          backgroundColor: AppColors.warning,
          duration: Duration(seconds: 2),
        ),
      );

      // Trigger status fetch
      context.read<AttendanceCubit>().fetchTodayStatus();
      return;
    }

    // IMPORTANT: Save current status BEFORE any dialogs or async operations
    // Now guaranteed to be non-null
    final AttendanceStatusModel savedStatus = _lastStatus!;
    print('💾 Saved status at start: YES');
    print('💾 Saved status - hasLateReason: ${savedStatus.hasLateReason}');
    print('💾 Saved status - workPlan: ${savedStatus.workPlan != null ? savedStatus.workPlan!.name : "NULL"}');

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
      if (!mounted) {
        print('⚠️ Widget not mounted after getting location');
        return;
      }

      Navigator.of(context).pop();

      // IMPORTANT: Use savedStatus (saved before any dialogs) instead of _lastStatus
      // This prevents issues with widget rebuilds
      print('🔍 ========== DEBUG: Checking if late ==========');
      print('🔍 savedStatus is null? ${savedStatus == null}');
      if (savedStatus != null) {
        print('🔍 Work Plan exists? ${savedStatus.workPlan != null}');
        if (savedStatus.workPlan != null) {
          print('🔍 Work Plan Name: ${savedStatus.workPlan!.name}');
          print('🔍 Work Plan Start Time: ${savedStatus.workPlan!.startTime}');
          print('🔍 Work Plan End Time: ${savedStatus.workPlan!.endTime}');
          print('🔍 Work Plan Permission Minutes: ${savedStatus.workPlan!.permissionMinutes}');
        }
        print('🔍 savedStatus.hasLateReason: ${savedStatus.hasLateReason}');
      }
      print('🔍 ==========================================');

      String? lateReason;

      // ✅ Check if this is the first session today
      final int totalSessions = savedStatus.sessionsSummary?.totalSessions ?? 0;
      final bool isFirstSession = totalSessions == 0;

      // ✅ Check if employee is late (client-side calculation)
      final bool isLate = _checkIfLate(savedStatus);

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
        print('⏰ Not first session (already checked in today) - proceeding without bottom sheet');
      } else if (!isLate) {
        print('⏰ Employee is NOT late - proceeding without bottom sheet');
      }

      if (!mounted) {
        print('⚠️ Widget not mounted after late reason input');
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
      if (mounted) {
        // Try to pop the dialog, but catch any errors
        try {
          Navigator.of(context).pop();
        } catch (popError) {
          print('⚠️ Could not pop dialog: $popError');
        }
      }

      // Show error
      if (mounted) {
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
  /// FIXED: Calculate late status based on CURRENT TIME vs work plan start time
  /// This runs BEFORE check-in, so we can't rely on backend's late_minutes
  /// (which is only calculated AFTER check-in)
  ///
  /// Returns true if employee is checking in after work start time + grace period
  bool _checkIfLate(AttendanceStatusModel? status) {
    print('🕐 ========== CHECKING IF LATE (CLIENT-SIDE CALCULATION) ==========');

    if (status == null) {
      print('⏰ ❌ Status is null - cannot determine if late');
      print('🕐 =========================================================');
      return false;
    }

    if (status.workPlan == null) {
      print('⏰ ❌ Work plan is null - cannot determine if late');
      print('🕐 =========================================================');
      return false;
    }

    final workPlan = status.workPlan!;
    print('⏰ ✅ Work Plan Found:');
    print('   - Name: ${workPlan.name}');
    print('   - Start Time: ${workPlan.startTime}');
    print('   - End Time: ${workPlan.endTime}');
    print('   - Permission Minutes (Grace Period): ${workPlan.permissionMinutes}');

    // Check if work plan has start time
    if (workPlan.startTime == null || workPlan.startTime!.isEmpty) {
      print('⏰ ❌ Start time is empty - cannot determine if late');
      print('🕐 =========================================================');
      return false;
    }

    try {
      // ✅ Calculate based on CURRENT TIME (before check-in happens)
      final now = DateTime.now();
      final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);

      // Parse work start time (format: "HH:MM:SS" or "HH:MM")
      final startTimeParts = workPlan.startTime!.split(':');
      if (startTimeParts.length < 2) {
        print('⏰ ❌ Invalid start time format: ${workPlan.startTime}');
        print('🕐 =========================================================');
        return false;
      }

      final startHour = int.parse(startTimeParts[0]);
      final startMinute = int.parse(startTimeParts[1]);
      final workStartTime = TimeOfDay(hour: startHour, minute: startMinute);

      // Convert to minutes since midnight for comparison
      final currentMinutes = currentTime.hour * 60 + currentTime.minute;
      final startMinutes = workStartTime.hour * 60 + workStartTime.minute;
      final gracePeriod = workPlan.permissionMinutes;
      final allowedStartMinutes = startMinutes + gracePeriod;

      print('⏰ Time Calculation:');
      print('   - Current Time: ${currentTime.hour}:${currentTime.minute.toString().padLeft(2, '0')} (${currentMinutes} minutes since midnight)');
      print('   - Work Start Time: ${workStartTime.hour}:${workStartTime.minute.toString().padLeft(2, '0')} (${startMinutes} minutes since midnight)');
      print('   - Grace Period: $gracePeriod minutes');
      print('   - Allowed Start Time: ${_minutesToTimeString(allowedStartMinutes)} (${allowedStartMinutes} minutes since midnight)');

      // Employee is late if current time > start time + grace period
      final bool isLate = currentMinutes > allowedStartMinutes;
      final int minutesLate = isLate ? (currentMinutes - allowedStartMinutes) : 0;

      print('⏰ Comparison Result:');
      print('   - Current: $currentMinutes > Allowed: $allowedStartMinutes?');
      print('   - Is Late? $isLate');

      if (isLate) {
        print('   - Minutes Late (after grace period): $minutesLate minutes');
        print('   - Hours Late: ${(minutesLate / 60).toStringAsFixed(1)} hours');
      } else if (currentMinutes > startMinutes) {
        final minutesWithinGrace = currentMinutes - startMinutes;
        print('   - Within Grace Period ✓ (late by $minutesWithinGrace min but < $gracePeriod grace)');
      } else {
        print('   - On Time ✓ (arrived before ${workStartTime.hour}:${workStartTime.minute.toString().padLeft(2, '0')})');
      }

      print('🕐 =========================================================');

      return isLate;
    } catch (e, stackTrace) {
      print('❌ Error in _checkIfLate: $e');
      print('❌ Stack trace: $stackTrace');
      print('🕐 =========================================================');
      return false;
    }
  }

  /// Convert minutes since midnight to time string (HH:MM)
  String _minutesToTimeString(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }

  /// Format time string (HH:MM:SS) to (HH:MM AM/PM)
  String _formatTime(String time) {
    try {
      // Try parsing different time formats
      DateTime? dateTime;

      // Format: "HH:MM:SS" or "HH:MM"
      if (time.contains(':')) {
        final parts = time.split(':');
        if (parts.length >= 2) {
          final hour = int.tryParse(parts[0]) ?? 0;
          final minute = int.tryParse(parts[1]) ?? 0;
          dateTime = DateTime(2000, 1, 1, hour, minute);
        }
      }

      if (dateTime != null) {
        return DateFormat('hh:mm a').format(dateTime);
      }

      return time;
    } catch (e) {
      return time;
    }
  }
}

/// Summary Card
class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
