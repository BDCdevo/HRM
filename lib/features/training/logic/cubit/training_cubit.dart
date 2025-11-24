import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/training_repo.dart';
import 'training_state.dart';

class TrainingCubit extends Cubit<TrainingState> {
  final TrainingRepo _trainingRepo;

  TrainingCubit(this._trainingRepo) : super(TrainingInitial());

  /// Submit a training request
  Future<void> submitTrainingRequest({
    required String trainingType,
    required String trainingName,
    String? trainingProvider,
    String? trainingLocation,
    String? trainingStartDate,
    String? trainingEndDate,
    double? trainingCost,
    String? trainingCostCoverage,
    String? trainingJustification,
    String? trainingExpectedBenefit,
    required String reason,
  }) async {
    emit(TrainingSubmitting());
    try {
      final request = await _trainingRepo.submitTrainingRequest(
        trainingType: trainingType,
        trainingName: trainingName,
        trainingProvider: trainingProvider,
        trainingLocation: trainingLocation,
        trainingStartDate: trainingStartDate,
        trainingEndDate: trainingEndDate,
        trainingCost: trainingCost,
        trainingCostCoverage: trainingCostCoverage,
        trainingJustification: trainingJustification,
        trainingExpectedBenefit: trainingExpectedBenefit,
        reason: reason,
      );
      emit(TrainingSubmitted(request));
    } catch (e) {
      emit(TrainingError(e.toString()));
    }
  }

  /// Fetch training request history
  Future<void> fetchTrainingHistory() async {
    emit(TrainingLoadingHistory());
    try {
      final requests = await _trainingRepo.getTrainingHistory();
      emit(TrainingHistoryLoaded(requests));
    } catch (e) {
      emit(TrainingError(e.toString()));
    }
  }

  /// Reset state
  void reset() {
    emit(TrainingInitial());
  }
}
