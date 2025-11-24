import 'package:equatable/equatable.dart';
import '../../data/models/holiday_model.dart';

abstract class HolidayState extends Equatable {
  const HolidayState();

  @override
  List<Object?> get props => [];
}

class HolidayInitial extends HolidayState {}

class HolidayLoading extends HolidayState {}

class HolidayLoaded extends HolidayState {
  final List<HolidayModel> holidays;
  final String filter;
  final int year;

  const HolidayLoaded({
    required this.holidays,
    this.filter = 'all',
    required this.year,
  });

  @override
  List<Object?> get props => [holidays, filter, year];

  HolidayLoaded copyWith({
    List<HolidayModel>? holidays,
    String? filter,
    int? year,
  }) {
    return HolidayLoaded(
      holidays: holidays ?? this.holidays,
      filter: filter ?? this.filter,
      year: year ?? this.year,
    );
  }
}

class HolidayError extends HolidayState {
  final String message;

  const HolidayError(this.message);

  @override
  List<Object?> get props => [message];
}
