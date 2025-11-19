import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/repo/attendance_repo.dart';
import '../../../../core/services/location_service.dart';
import 'attendance_state.dart';
import '../../../../core/constants/error_messages.dart';

/// Attendance Cubit
///
/// Manages attendance state and handles check-in/check-out operations
class AttendanceCubit extends Cubit<AttendanceState> {
  final AttendanceRepo _attendanceRepo = AttendanceRepo();

  AttendanceCubit() : super(const AttendanceInitial());

  /// Fetch Today's Attendance Status
  ///
  /// Gets the current attendance status for today
  /// Emits:
  /// - [AttendanceLoading] while fetching
  /// - [AttendanceStatusLoaded] on success
  /// - [AttendanceError] on failure
  Future<void> fetchTodayStatus() async {
    try {
      print('🔵 Cubit: fetchTodayStatus called');
      emit(const AttendanceLoading());

      final status = await _attendanceRepo.getTodayStatus();

      print('✅ Cubit: Status fetched successfully');
      print('📊 Cubit: hasActiveSession = ${status.hasActiveSession}');
      print('📊 Cubit: hasCheckedIn = ${status.hasCheckedIn}');

      emit(AttendanceStatusLoaded(status: status));

      print('✅ Cubit: Emitted AttendanceStatusLoaded');
    } on DioException catch (e) {
      print('❌ Cubit: DioException in fetchTodayStatus - ${e.message}');
      _handleDioException(e);
    } catch (e) {
      print('❌ Cubit: Exception in fetchTodayStatus - $e');
      emit(const AttendanceError(message: ErrorMessages.unexpectedError));
    }
  }

  /// Check In
  ///
  /// Records check-in time for today
  /// Requires GPS location (latitude, longitude) for branch validation
  /// Optionally includes late reason if employee is checking in late
  /// Emits:
  /// - [AttendanceLoading] while processing
  /// - [CheckInSuccess] on success
  /// - [AttendanceError] on failure
  Future<void> checkIn({
    required double latitude,  // ✅ Now required
    required double longitude, // ✅ Now required
    String? notes,
    String? lateReason,
  }) async {
    try {
      print('🟢 AttendanceCubit.checkIn called');
      print('📍 Cubit - Received Latitude: $latitude');
      print('📍 Cubit - Received Longitude: $longitude');
      print('📝 Cubit - Notes: $notes');
      print('⏰ Cubit - Late Reason: $lateReason');

      emit(const AttendanceLoading());

      // ✅ REMOVED: Duplicate GPS logic
      // Widget is now responsible for getting GPS location
      // This simplifies the Cubit and avoids duplicate GPS calls

      final attendance = await _attendanceRepo.checkIn(
        latitude: latitude,
        longitude: longitude,
        notes: notes,
        lateReason: lateReason,
      );

      print('✅ Cubit - Check-in successful');

      emit(CheckInSuccess(attendance: attendance));

      // Note: Status and sessions will be refreshed by the widget listener
    } on DioException catch (e) {
      print('❌ Cubit - DioException: ${e.message}');
      _handleDioException(e);
    } catch (e) {
      print('❌ Cubit - Unexpected error: $e');
      emit(const AttendanceError(message: ErrorMessages.checkInFailed));
    }
  }

  /// Check Out
  ///
  /// Records check-out time for today
  /// Emits:
  /// - [AttendanceLoading] while processing
  /// - [CheckOutSuccess] on success
  /// - [AttendanceError] on failure
  Future<void> checkOut() async {
    try {
      emit(const AttendanceLoading());

      final attendance = await _attendanceRepo.checkOut();

      emit(CheckOutSuccess(attendance: attendance));

      // Note: Status and sessions will be refreshed by the widget listener
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      emit(const AttendanceError(message: ErrorMessages.checkOutFailed));
    }
  }

  /// Fetch Today's Sessions
  ///
  /// Gets all check-in/check-out sessions for today
  /// Supports multiple sessions per day
  /// Emits:
  /// - [SessionsLoading] while fetching
  /// - [SessionsLoaded] on success
  /// - [AttendanceError] on failure
  Future<void> fetchTodaySessions() async {
    try {
      emit(const SessionsLoading());

      final sessionsData = await _attendanceRepo.getTodaySessions();

      emit(SessionsLoaded(sessionsData: sessionsData));
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      emit(const AttendanceError(message: ErrorMessages.unexpectedError));
    }
  }

  /// Handle Dio Exception with user-friendly error messages
  void _handleDioException(DioException e) {
    if (e.response != null) {
      // Server responded with error
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;
      String errorMessage = data?['message'] ?? ErrorMessages.operationFailed;

      // Parse API message and provide localized errors
      String apiMessage = errorMessage.toLowerCase();

      if (apiMessage.contains('no branch') || apiMessage.contains('branch not assigned')) {
        errorMessage = ErrorMessages.noBranchAssigned;
      } else if (apiMessage.contains('outside') || apiMessage.contains('distance') || apiMessage.contains('geofence')) {
        // Special handling for geofencing errors (distance info)
        if (statusCode == 400 && data?['errors'] != null) {
          final errors = data['errors'];
          final distanceMeters = errors['distance_meters'];
          final allowedRadius = errors['allowed_radius'];

          if (distanceMeters != null && allowedRadius != null) {
            // Enhanced error message with distance info
            errorMessage = 'أنت بعيد عن موقع الفرع\n'
                'المسافة الحالية: ${distanceMeters}م\n'
                'المسافة المسموحة: ${allowedRadius}م\n'
                'يرجى الاقتراب من الفرع للتسجيل';
          } else {
            errorMessage = ErrorMessages.outsideBranchArea;
          }
        } else {
          errorMessage = ErrorMessages.outsideBranchArea;
        }
      } else if (apiMessage.contains('already') && apiMessage.contains('checked in')) {
        errorMessage = ErrorMessages.alreadyCheckedIn;
      } else if (apiMessage.contains('no active session') || apiMessage.contains('not checked in')) {
        errorMessage = ErrorMessages.noActiveSession;
      } else if (apiMessage.contains('location') && apiMessage.contains('permission')) {
        errorMessage = ErrorMessages.locationPermissionDenied;
      }

      emit(AttendanceError(
        message: errorMessage,
        errorDetails: data?.toString(),
      ));
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      emit(const AttendanceError(message: ErrorMessages.connectionTimeout));
    } else if (e.type == DioExceptionType.connectionError) {
      emit(const AttendanceError(message: ErrorMessages.noInternetConnection));
    } else {
      emit(AttendanceError(
        message: ErrorMessages.getDioErrorMessage(e.message),
      ));
    }
  }
}
