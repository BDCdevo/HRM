import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/weekly_stats_model.dart';
import '../../data/repo/weekly_stats_repo.dart';
import 'weekly_stats_state.dart';

/// Weekly Stats Cubit
///
/// Manages weekly attendance statistics state
class WeeklyStatsCubit extends Cubit<WeeklyStatsState> {
  final WeeklyStatsRepo _repo;

  WeeklyStatsCubit({WeeklyStatsRepo? repo})
      : _repo = repo ?? WeeklyStatsRepo(),
        super(const WeeklyStatsInitial());

  /// Fetch weekly stats from API
  Future<void> fetchWeeklyStats() async {
    emit(const WeeklyStatsLoading());

    try {
      final stats = await _repo.fetchWeeklyStats();
      emit(WeeklyStatsLoaded(stats));
    } catch (e) {
      // Emit empty stats on error (graceful fallback)
      emit(WeeklyStatsLoaded(WeeklyStatsModel.empty()));
    }
  }

  /// Refresh weekly stats
  Future<void> refresh() async {
    await fetchWeeklyStats();
  }
}
