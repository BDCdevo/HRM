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
        }

        // Use last status if available, otherwise try to extract from current state
        final status = _lastStatus ?? (state is AttendanceStatusLoaded ? state.status : null);

        // Extract data from status
        final bool hasActiveSession = status?.hasActiveSession ?? false;
        final bool isCheckedIn = status?.hasCheckedIn ?? false;
        final bool isCheckedOut = status?.hasCheckedOut ?? false;
        final String? checkInTime = status?.dailySummary?.checkInTime ?? status?.checkInTime;
        final String? checkOutTime = status?.dailySummary?.checkOutTime ?? status?.checkOutTime;
        final double workingHours = status?.dailySummary?.workingHours ?? status?.workingHours ?? 0.0;
        final int lateMinutes = status?.dailySummary?.lateMinutes ?? status?.lateMinutes ?? 0;
        final bool isLoading = state is AttendanceLoading;

        print('🎨 UI Building - State: ${state.runtimeType}, hasActiveSession: $hasActiveSession, isCheckedIn: $isCheckedIn');

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
                onPressed: isLoading
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

  /// Handle Check In with GPS Location
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

      print('🚀 Calling checkIn with location...');

      // Perform check-in with location
      await context.read<AttendanceCubit>().checkIn(
        latitude: position.latitude,
        longitude: position.longitude,
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
