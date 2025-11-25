import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_colors_extension.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/theme/cubit/theme_cubit.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/error_widgets.dart';
import '../../../../core/widgets/success_animation.dart';
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
  State<AttendanceCheckInWidget> createState() =>
      _AttendanceCheckInWidgetState();
}

class _AttendanceCheckInWidgetState extends State<AttendanceCheckInWidget>
    with WidgetsBindingObserver {
  // Keep track of the last status loaded
  AttendanceStatusModel? _lastStatus;

  // Auto-refresh timer
  Timer? _refreshTimer;

  // PageView controller for swipeable status card
  late PageController _pageController;
  int _currentPage = 0;

  // Timer for live counter in timer view
  Timer? _timerUpdateTimer;

  // Global key for timer card to preserve state
  final GlobalKey<_SimpleTimerCardState> _timerCardKey =
      GlobalKey<_SimpleTimerCardState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize PageController
    _pageController = PageController(initialPage: 0);

    // Fetch today's status and sessions when widget loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _refreshData();
      }
    });

    // Setup auto-refresh every 30 seconds for real-time updates
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        print('🔄 Auto-refreshing attendance data...');
        _refreshData();
      }
    });

    // Setup timer for live counter (updates every second when on timer page)
    _timerUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _currentPage == 1) {
        // Force rebuild to update live timer
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _timerUpdateTimer?.cancel();
    _pageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh when app comes to foreground
    if (state == AppLifecycleState.resumed && mounted) {
      print('🔄 App resumed - refreshing attendance data...');
      _refreshData();
    }
  }

  void _refreshData() {
    context.read<AttendanceCubit>().fetchTodayStatus();
    context.read<AttendanceCubit>().fetchTodaySessions();
  }

  @override
  Widget build(BuildContext context) {
    // Theme colors
    final isDark = context.watch<ThemeCubit>().isDarkMode;
    final cardColor = isDark ? AppColors.darkCard : AppColors.surface;
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final secondaryTextColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    // Get current date and time
    final now = DateTime.now();
    final String currentTime = DateFormat('hh:mm a').format(now);
    final String currentDate = DateFormat('EEEE, MMMM d, yyyy').format(now);

    return BlocConsumer<AttendanceCubit, AttendanceState>(
      listener: (context, state) {
        // Show success/error messages
        if (state is CheckInSuccess) {
          // Show success animation dialog
          showSuccessDialog(
            context,
            title: 'Check-In Successful!',
            message:
                'Checked in at ${state.attendance.checkInTime ?? currentTime}',
            onComplete: () {
              // Refresh status and sessions after dialog closes
              context.read<AttendanceCubit>().fetchTodayStatus();
              context.read<AttendanceCubit>().fetchTodaySessions();
            },
          );
        } else if (state is CheckOutSuccess) {
          // Show success animation dialog
          showSuccessDialog(
            context,
            title: 'Check-Out Successful!',
            message:
                'Checked out at ${state.attendance.checkOutTime ?? currentTime}',
            onComplete: () {
              // Refresh status and sessions after dialog closes
              context.read<AttendanceCubit>().fetchTodayStatus();
              context.read<AttendanceCubit>().fetchTodaySessions();
            },
          );
        } else if (state is AttendanceError) {
          ErrorSnackBar.show(
            context: context,
            message: ErrorSnackBar.getArabicMessage(state.displayMessage),
            isNetworkError: ErrorSnackBar.isNetworkRelated(state.displayMessage),
          );
        }
      },
      builder: (context, state) {
        // Save the last status when loaded
        if (state is AttendanceStatusLoaded) {
          _lastStatus = state.status;
          print(
            '✅ Status loaded: hasActiveSession=${state.status.hasActiveSession}',
          );
          print('✅ Has Late Reason: ${state.status.hasLateReason}');
          print(
            '✅ Work Plan in status: ${state.status.workPlan != null ? "YES" : "NO"}',
          );
          if (state.status.workPlan != null) {
            print('✅ Work Plan Details:');
            print('   - Name: ${state.status.workPlan!.name}');
            print('   - Start Time: ${state.status.workPlan!.startTime}');
            print('   - End Time: ${state.status.workPlan!.endTime}');
            print('   - Schedule: ${state.status.workPlan!.schedule}');
            print(
              '   - Permission Minutes: ${state.status.workPlan!.permissionMinutes}',
            );
          }
        }

        // Use last status if available, otherwise try to extract from current state
        final status =
            _lastStatus ??
            (state is AttendanceStatusLoaded ? state.status : null);

        // Extract data from status
        final bool hasActiveSession = status?.hasActiveSession ?? false;
        final bool isCheckedIn = status?.hasCheckedIn ?? false;
        final bool isCheckedOut = status?.hasCheckedOut ?? false;
        final String? checkInTime =
            status?.dailySummary?.checkInTime ?? status?.checkInTime;
        final String? checkOutTime =
            status?.dailySummary?.checkOutTime ?? status?.checkOutTime;
        // FIXED: Use totalHours which sums all sessions, not just current session
        final double workingHours = status?.totalHours ?? 0.0;
        final int lateMinutes =
            status?.dailySummary?.lateMinutes ?? status?.lateMinutes ?? 0;
        final bool isLoading = state is AttendanceLoading;

        print('🎨 UI Building:');
        print('   State Type: ${state.runtimeType}');
        print('   _lastStatus exists: ${_lastStatus != null}');
        if (_lastStatus != null) {
          print(
            '   _lastStatus.hasActiveSession: ${_lastStatus!.hasActiveSession}',
          );
        }
        print('   Computed hasActiveSession: $hasActiveSession');
        print('   Computed isCheckedIn: $isCheckedIn');
        print(
          '   Button will show: ${hasActiveSession ? "Check Out" : "Check In"}',
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Swipeable Status Card
              Column(
                children: [
                  SizedBox(
                    height: 280,
                    child: PageView(
                      controller: _pageController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      children: [
                        // Page 1: Animation View (Dashboard-style with work_now.json)
                        _buildAnimationCard(
                          hasActiveSession: hasActiveSession,
                          isDark: isDark,
                          cardColor: cardColor,
                        ),

                        // Page 2: Simple Timer Card (without buttons)
                        hasActiveSession
                            ? _SimpleTimerCard(
                                key:
                                    _timerCardKey, // Use global key to preserve state
                                status: status,
                                isDark: isDark,
                                cardColor: cardColor,
                              )
                            : Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(24),
                                  border: isDark
                                      ? Border.all(
                                          color: AppColors.darkBorder,
                                          width: 1,
                                        )
                                      : null,
                                  boxShadow: isDark
                                      ? []
                                      : [
                                          BoxShadow(
                                            color: AppColors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 24,
                                            offset: const Offset(0, 8),
                                            spreadRadius: -4,
                                          ),
                                          BoxShadow(
                                            color: AppColors.black.withOpacity(
                                              0.06,
                                            ),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                            spreadRadius: 0,
                                          ),
                                        ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.timer_off_outlined,
                                      size: 64,
                                      color: isDark
                                          ? AppColors.darkTextTertiary
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No Active Timer',
                                      style: AppTextStyles.titleLarge.copyWith(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Check in to start tracking your time',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: secondaryTextColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(2, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.border),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 8),

                  // Swipe hint
                  Text(
                    _currentPage == 0 ? 'Swipe for timer →' : '← Swipe back',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Check-in/out Button
              CustomButton(
                text: isLoading
                    ? 'Processing...'
                    : hasActiveSession
                    ? 'Check Out'
                    : 'Check In',
                onPressed:
                    isLoading ||
                        _lastStatus ==
                            null // ✅ Disable if status not loaded
                    ? null
                    : () async {
                        print('🔴 BUTTON PRESSED!');
                        print('🔴 hasActiveSession: $hasActiveSession');
                        print('🔴 isCheckedIn: $isCheckedIn');
                        print('🔴 isLoading: $isLoading');

                        if (hasActiveSession) {
                          print(
                            '🔴 Taking CHECK OUT path - Active session found',
                          );
                          // Check out (end current session)
                          context.read<AttendanceCubit>().checkOut();
                        } else {
                          print('🔴 Taking CHECK IN path - No active session');
                          // Check in (start new session) with GPS location
                          await _handleCheckIn(context);
                          print('🔴 Returned from _handleCheckIn');
                        }
                      },
                type: hasActiveSession
                    ? ButtonType.error
                    : ButtonType.secondary,
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
                  color: textColor,
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
                      isDark: isDark,
                      cardColor: cardColor,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
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
                      isDark: isDark,
                      cardColor: cardColor,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
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
                      isDark: isDark,
                      cardColor: cardColor,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.schedule,
                      label: 'Late Minutes',
                      value: '$lateMinutes min',
                      color: lateMinutes > 0
                          ? AppColors.warning
                          : AppColors.success,
                      isDark: isDark,
                      cardColor: cardColor,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Location Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.info.withOpacity(isDark ? 0.4 : 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Make sure you are at your work location to check in/out.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Check-in Counter Card (Timer) - Removed
              // Timer now available in PageView Page 2 (swipeable)

              // Today's Sessions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today\'s Sessions',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  // Refresh button
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    color: isDark ? AppColors.white : AppColors.primary,
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

  /// Build Animation Card (Slide 2 - Dashboard style with work_now.json)
  Widget _buildAnimationCard({
    required bool hasActiveSession,
    required bool isDark,
    required Color cardColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: isDark
            ? Border.all(color: AppColors.darkBorder, width: 1)
            : null,
        boxShadow: isDark
            ? []
            : [
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animation/Icon Container
          SizedBox(
            width: double.infinity,
            height: 160,
            child: hasActiveSession
                ? _buildAnimationOrIcon(
                    assetPath: 'assets/animations/work_now.json',
                    fallbackIcon: Icons.work_outline,
                    iconColor: AppColors.success,
                  )
                : _buildAnimationOrIcon(
                    assetPath: 'assets/animations/welcome.json',
                    fallbackIcon: Icons.waving_hand,
                    iconColor: AppColors.primary,
                  ),
          ),

          const SizedBox(height: 16),

          // Message
          Text(
            hasActiveSession ? '🚀 You\'re working now!' : '👋 Ready to begin?',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build Animation or Icon (with error handling)
  Widget _buildAnimationOrIcon({
    required String assetPath,
    required IconData fallbackIcon,
    required Color iconColor,
  }) {
    return FutureBuilder(
      future: Future(() async {
        try {
          // Try to load the asset
          await rootBundle.loadString(assetPath);
          return true;
        } catch (e) {
          return false;
        }
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: iconColor));
        }

        // If asset exists and loaded successfully, show Lottie
        if (snapshot.hasData && snapshot.data == true) {
          return Lottie.asset(
            assetPath,
            width: double.infinity,
            fit: BoxFit.contain,
            repeat: true,
            animate: true,
            errorBuilder: (context, error, stackTrace) {
              // If Lottie fails to parse, show icon
              return Center(
                child: Icon(fallbackIcon, size: 80, color: iconColor),
              );
            },
          );
        }

        // If asset doesn't exist or failed to load, show icon
        return Center(child: Icon(fallbackIcon, size: 80, color: iconColor));
      },
    );
  }
}

/// Simple Timer Card Widget (Stateful for real-time updates)
class _SimpleTimerCard extends StatefulWidget {
  final dynamic status;
  final bool isDark;
  final Color cardColor;

  const _SimpleTimerCard({
    super.key,
    required this.status,
    required this.isDark,
    required this.cardColor,
  });

  @override
  State<_SimpleTimerCard> createState() => _SimpleTimerCardState();
}

class _SimpleTimerCardState extends State<_SimpleTimerCard> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateInitialElapsed();
    _startTimer();
  }

  @override
  void didUpdateWidget(_SimpleTimerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      _calculateInitialElapsed();

      // Restart timer based on new status
      final hasActiveSession = widget.status?.hasActiveSession ?? false;
      final hadActiveSession = oldWidget.status?.hasActiveSession ?? false;

      if (hasActiveSession != hadActiveSession) {
        print(
          '⏰ [TIMER] Active session status changed: $hadActiveSession -> $hasActiveSession',
        );
        _startTimer(); // Will start or stop based on hasActiveSession
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _calculateInitialElapsed() {
    try {
      Duration totalElapsed = Duration.zero;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      print(
        '⏰ [TIMER] Calculating elapsed time for TODAY: ${today.toString().split(' ')[0]}',
      );

      // CRITICAL: Check if there's an active session first
      final hasActiveSession = widget.status?.hasActiveSession ?? false;
      print('⏰ [TIMER] Has active session: $hasActiveSession');

      // If NO active session, reset timer to zero
      if (!hasActiveSession) {
        print('⏰ [TIMER] No active session - Timer reset to 00:00:00');
        _elapsed = Duration.zero;
        return;
      }

      // SIMPLIFIED: Just use the API's totalDuration directly
      // The API already calculates everything correctly including active sessions
      if (widget.status?.sessionsSummary != null) {
        final totalDurationStr = widget.status!.sessionsSummary!.totalDuration;
        print('⏰ [TIMER] Total duration from API: $totalDurationStr');

        if (totalDurationStr.contains(':')) {
          final parts = totalDurationStr.split(':');
          final hours = int.parse(parts[0]);
          final minutes = int.parse(parts[1]);
          final seconds = parts.length > 2
              ? int.parse(parts[2].split('.')[0])
              : 0;
          totalElapsed = Duration(
            hours: hours,
            minutes: minutes,
            seconds: seconds,
          );
          print('⏰ [TIMER] Using API duration directly: $totalElapsed');
        }
      }

      _elapsed = totalElapsed;
      if (_elapsed.isNegative) {
        print('⚠️ [TIMER] Elapsed is negative! Resetting to zero.');
        _elapsed = Duration.zero;
      }

      print('✅ [TIMER] Final elapsed set to: $_elapsed');
    } catch (e) {
      print('❌ [TIMER] Error calculating elapsed: $e');
      _elapsed = Duration.zero;
    }
  }

  void _startTimer() {
    _timer?.cancel(); // Cancel any existing timer first

    // Only start timer if there's an active session
    final hasActiveSession = widget.status?.hasActiveSession ?? false;

    if (!hasActiveSession) {
      print('⏰ [TIMER] No active session - Timer NOT started');
      // Make sure timer shows 00:00:00 when no active session
      if (mounted) {
        setState(() {
          _elapsed = Duration.zero;
        });
      }
      return;
    }

    print('⏰ [TIMER] Starting timer with initial elapsed: $_elapsed');
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
    final hours = _elapsed.inHours.toString().padLeft(2, '0');
    final minutes = (_elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: widget.isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.darkCard,
                  AppColors.darkInput.withOpacity(0.3),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.03),
                  AppColors.accent.withOpacity(0.05),
                ],
              ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.isDark
              ? AppColors.primary.withOpacity(0.25)
              : AppColors.primary.withOpacity(0.15),
          width: 2,
        ),
        boxShadow: widget.isDark
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
              ]
            : [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.08),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                  spreadRadius: 0,
                ),
              ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title only - simple
          Text(
            'Work Duration',
            style: AppTextStyles.titleMedium.copyWith(
              color: widget.isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 16),

          // Counter Display - Simplified
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: widget.isDark
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.darkInput.withOpacity(0.6),
                        AppColors.darkInput.withOpacity(0.4),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.white, AppColors.backgroundLight],
                    ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(
                  widget.isDark ? 0.35 : 0.2,
                ),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTimeBox(hours, 'HR'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    ':',
                    style: AppTextStyles.headlineLarge.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      height: 1.0,
                    ),
                  ),
                ),
                _buildTimeBox(minutes, 'MIN'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    ':',
                    style: AppTextStyles.headlineLarge.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      height: 1.0,
                    ),
                  ),
                ),
                _buildTimeBox(seconds, 'SEC'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build Time Box for Counter with label
  Widget _buildTimeBox(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Number box - smaller
        Container(
          width: 50,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isDark
                  ? [AppColors.darkCard, AppColors.darkInput]
                  : [Colors.white, AppColors.backgroundLight.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isDark
                  ? AppColors.primary.withOpacity(0.3)
                  : AppColors.primary.withOpacity(0.25),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(
                  widget.isDark ? 0.15 : 0.1,
                ),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                fontFeatures: const [FontFeature.tabularFigures()],
                letterSpacing: -1,
                height: 1.0,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Label
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: widget.isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

/// Extension on AttendanceCheckInWidget State for handling check-in/check-out actions
extension AttendanceCheckInActions on _AttendanceCheckInWidgetState {
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
    print(
      '💾 Saved status - workPlan: ${savedStatus.workPlan != null ? savedStatus.workPlan!.name : "NULL"}',
    );

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
          print(
            '🔍 Work Plan Permission Minutes: ${savedStatus.workPlan!.permissionMinutes}',
          );
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
        print(
          '⏰ Not first session (already checked in today) - proceeding without bottom sheet',
        );
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
    print(
      '🕐 ========== CHECKING IF LATE (CLIENT-SIDE CALCULATION) ==========',
    );

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
    print('   - Late Detection Enabled: ${workPlan.lateDetectionEnabled}');

    // Calculate actual grace period used (24h when late detection is OFF)
    final actualGracePeriod = workPlan.lateDetectionEnabled
        ? workPlan.permissionMinutes
        : 1440;
    print(
      '   - Permission Minutes (Grace Period): $actualGracePeriod minutes (${(actualGracePeriod / 60).toStringAsFixed(1)}h)',
    );

    // Check if late detection is disabled
    if (!workPlan.lateDetectionEnabled) {
      print('⏰ ℹ️  Late detection is DISABLED - employee is always on time');
      print('🕐 =========================================================');
      return false; // Always on time when disabled
    }

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

      // Use 24 hours (1440 minutes) as grace period when late detection is disabled
      final gracePeriod = workPlan.lateDetectionEnabled
          ? workPlan.permissionMinutes
          : 1440; // 24 hours
      final allowedStartMinutes = startMinutes + gracePeriod;

      print('⏰ Time Calculation:');
      print(
        '   - Current Time: ${currentTime.hour}:${currentTime.minute.toString().padLeft(2, '0')} (${currentMinutes} minutes since midnight)',
      );
      print(
        '   - Work Start Time: ${workStartTime.hour}:${workStartTime.minute.toString().padLeft(2, '0')} (${startMinutes} minutes since midnight)',
      );
      print(
        '   - Grace Period: $gracePeriod minutes (${(gracePeriod / 60).toStringAsFixed(1)}h) ${!workPlan.lateDetectionEnabled ? '← 24h because Late Detection is OFF' : ''}',
      );
      print(
        '   - Allowed Start Time: ${_minutesToTimeString(allowedStartMinutes)} (${allowedStartMinutes} minutes since midnight)',
      );

      // Employee is late if current time > start time + grace period
      final bool isLate = currentMinutes > allowedStartMinutes;
      final int minutesLate = isLate
          ? (currentMinutes - allowedStartMinutes)
          : 0;

      print('⏰ Comparison Result:');
      print('   - Current: $currentMinutes > Allowed: $allowedStartMinutes?');
      print('   - Is Late? $isLate');

      if (isLate) {
        print('   - Minutes Late (after grace period): $minutesLate minutes');
        print(
          '   - Hours Late: ${(minutesLate / 60).toStringAsFixed(1)} hours',
        );
      } else if (currentMinutes > startMinutes) {
        final minutesWithinGrace = currentMinutes - startMinutes;
        print(
          '   - Within Grace Period ✓ (late by $minutesWithinGrace min but < $gracePeriod grace)',
        );
      } else {
        print(
          '   - On Time ✓ (arrived before ${workStartTime.hour}:${workStartTime.minute.toString().padLeft(2, '0')})',
        );
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
  final bool isDark;
  final Color cardColor;
  final Color textColor;
  final Color secondaryTextColor;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
    required this.cardColor,
    required this.textColor,
    required this.secondaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark
            ? []
            : [
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: secondaryTextColor),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
