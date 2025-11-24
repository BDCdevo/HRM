import 'package:equatable/equatable.dart';
import '../../data/models/training_request_model.dart';

abstract class TrainingState extends Equatable {
  const TrainingState();

  @override
  List<Object?> get props => [];
}

class TrainingInitial extends TrainingState {}

class TrainingSubmitting extends TrainingState {}

class TrainingSubmitted extends TrainingState {
  final TrainingRequestModel request;

  const TrainingSubmitted(this.request);

  @override
  List<Object?> get props => [request];
}

class TrainingLoadingHistory extends TrainingState {}

class TrainingHistoryLoaded extends TrainingState {
  final List<TrainingRequestModel> requests;

  const TrainingHistoryLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

class TrainingError extends TrainingState {
  final String message;

  const TrainingError(this.message);

  @override
  List<Object?> get props => [message];
}
