import 'package:equatable/equatable.dart';
import '../../data/models/weekly_stats_model.dart';

/// Weekly Stats State
abstract class WeeklyStatsState extends Equatable {
  const WeeklyStatsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class WeeklyStatsInitial extends WeeklyStatsState {
  const WeeklyStatsInitial();
}

/// Loading state
class WeeklyStatsLoading extends WeeklyStatsState {
  const WeeklyStatsLoading();
}

/// Loaded state with data
class WeeklyStatsLoaded extends WeeklyStatsState {
  final WeeklyStatsModel stats;

  const WeeklyStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

/// Error state
class WeeklyStatsError extends WeeklyStatsState {
  final String message;

  const WeeklyStatsError(this.message);

  @override
  List<Object?> get props => [message];
}
