import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/attendance_summary_repo.dart';
import 'attendance_summary_state.dart';

/// Attendance Summary Cubit
///
/// Manages state for fetching and displaying all employees' attendance summary
class AttendanceSummaryCubit extends Cubit<AttendanceSummaryState> {
  final AttendanceSummaryRepo _repo;

  AttendanceSummaryCubit([AttendanceSummaryRepo? repo])
      : _repo = repo ?? AttendanceSummaryRepo(),
        super(const AttendanceSummaryInitial());

  /// Fetch Today's Summary
  Future<void> fetchTodaySummary() async {
    emit(const AttendanceSummaryLoading());

    try {
      final summary = await _repo.fetchTodaySummary();
      emit(AttendanceSummaryLoaded(summary));
    } catch (e) {
      emit(AttendanceSummaryError(e.toString()));
    }
  }

  /// Fetch Summary by Date
  Future<void> fetchSummaryByDate(DateTime date) async {
    emit(const AttendanceSummaryLoading());

    try {
      final summary = await _repo.fetchSummaryByDate(date);
      emit(AttendanceSummaryLoaded(summary));
    } catch (e) {
      emit(AttendanceSummaryError(e.toString()));
    }
  }

  /// Refresh
  Future<void> refresh() async {
    await fetchTodaySummary();
  }
}
