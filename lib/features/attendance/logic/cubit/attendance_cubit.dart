import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/repo/attendance_repo.dart';
import '../../../../core/services/location_service.dart';
import 'attendance_state.dart';

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
      emit(AttendanceError(
        message: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }

  /// Check In
  ///
  /// Records check-in time for today
  /// Automatically gets GPS location for branch validation
  /// Emits:
  /// - [AttendanceLoading] while processing
  /// - [CheckInSuccess] on success
  /// - [AttendanceError] on failure
  Future<void> checkIn({
    double? latitude,
    double? longitude,
    String? notes,
  }) async {
    try {
      print('🟢 AttendanceCubit.checkIn called');
      print('📍 Cubit - Received Latitude: $latitude');
      print('📍 Cubit - Received Longitude: $longitude');
      print('📝 Cubit - Notes: $notes');

      emit(const AttendanceLoading());

      // If location not provided, get it automatically
      if (latitude == null || longitude == null) {
        print('📍 No location provided, getting GPS location...');
        try {
          final Position position = await LocationService.getCurrentPosition();
          latitude = position.latitude;
          longitude = position.longitude;
          print('✅ Got GPS location: $latitude, $longitude');
        } catch (locationError) {
          print('❌ Location error: $locationError');
          emit(AttendanceError(
            message: locationError.toString().replaceAll('Exception: ', ''),
          ));
          return;
        }
      }

      final attendance = await _attendanceRepo.checkIn(
        latitude: latitude,
        longitude: longitude,
        notes: notes,
      );

      print('✅ Cubit - Check-in successful');

      emit(CheckInSuccess(attendance: attendance));

      // Fetch updated status and sessions
      await fetchTodayStatus();
      await fetchTodaySessions();
    } on DioException catch (e) {
      print('❌ Cubit - DioException: ${e.message}');
      _handleDioException(e);
    } catch (e) {
      print('❌ Cubit - Unexpected error: $e');
      emit(AttendanceError(
        message: 'An unexpected error occurred: ${e.toString()}',
      ));
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

      // Fetch updated status and sessions
      await fetchTodayStatus();
      await fetchTodaySessions();
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      emit(AttendanceError(
        message: 'An unexpected error occurred: ${e.toString()}',
      ));
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
      emit(AttendanceError(
        message: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }

  /// Handle Dio Exception
  void _handleDioException(DioException e) {
    if (e.response != null) {
      // Server responded with error
      final statusCode = e.response?.statusCode;
      final errorMessage = e.response?.data?['message'] ?? 'Operation failed';

      emit(AttendanceError(
        message: '[$statusCode] $errorMessage',
        errorDetails: e.response?.data?.toString(),
      ));
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      // Timeout error
      emit(const AttendanceError(
        message: 'Request timeout. Please try again.',
      ));
    } else if (e.type == DioExceptionType.unknown) {
      // Network error (no internet connection)
      emit(const AttendanceError(
        message: 'Network error. Please check your internet connection.',
      ));
    } else {
      // Other Dio errors
      emit(AttendanceError(
        message: e.message ?? 'An unexpected error occurred',
      ));
    }
  }
}
