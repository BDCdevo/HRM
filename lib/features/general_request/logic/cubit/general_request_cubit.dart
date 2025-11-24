import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/general_request_repo.dart';
import 'general_request_state.dart';

class GeneralRequestCubit extends Cubit<GeneralRequestState> {
  final GeneralRequestRepo _generalRequestRepo;

  GeneralRequestCubit(this._generalRequestRepo)
      : super(GeneralRequestInitial());

  /// Submit a general request
  Future<void> submitGeneralRequest({
    required String generalCategory,
    required String generalSubject,
    required String generalDescription,
    String generalPriority = 'medium',
    required String reason,
  }) async {
    emit(GeneralRequestSubmitting());
    try {
      final request = await _generalRequestRepo.submitGeneralRequest(
        generalCategory: generalCategory,
        generalSubject: generalSubject,
        generalDescription: generalDescription,
        generalPriority: generalPriority,
        reason: reason,
      );
      emit(GeneralRequestSubmitted(request));
    } catch (e) {
      emit(GeneralRequestError(e.toString()));
    }
  }

  /// Fetch general request history
  Future<void> fetchGeneralRequestHistory() async {
    emit(GeneralRequestLoadingHistory());
    try {
      final requests = await _generalRequestRepo.getGeneralRequestHistory();
      emit(GeneralRequestHistoryLoaded(requests));
    } catch (e) {
      emit(GeneralRequestError(e.toString()));
    }
  }

  /// Reset state
  void reset() {
    emit(GeneralRequestInitial());
  }
}
