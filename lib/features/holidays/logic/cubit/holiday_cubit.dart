import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/holiday_repo.dart';
import 'holiday_state.dart';

class HolidayCubit extends Cubit<HolidayState> {
  final HolidayRepo _holidayRepo;

  HolidayCubit(this._holidayRepo) : super(HolidayInitial());

  Future<void> fetchHolidays({
    String filter = 'all',
    int? year,
  }) async {
    try {
      emit(HolidayLoading());

      final currentYear = year ?? DateTime.now().year;
      final holidays = await _holidayRepo.getHolidays(
        filter: filter,
        year: currentYear,
      );

      emit(HolidayLoaded(
        holidays: holidays,
        filter: filter,
        year: currentYear,
      ));
    } catch (e) {
      emit(HolidayError(e.toString()));
    }
  }

  Future<void> changeFilter(String filter) async {
    if (state is HolidayLoaded) {
      final currentState = state as HolidayLoaded;
      await fetchHolidays(filter: filter, year: currentState.year);
    }
  }

  Future<void> changeYear(int year) async {
    if (state is HolidayLoaded) {
      final currentState = state as HolidayLoaded;
      await fetchHolidays(filter: currentState.filter, year: year);
    }
  }

  Future<void> refresh() async {
    if (state is HolidayLoaded) {
      final currentState = state as HolidayLoaded;
      await fetchHolidays(
        filter: currentState.filter,
        year: currentState.year,
      );
    } else {
      await fetchHolidays();
    }
  }
}
