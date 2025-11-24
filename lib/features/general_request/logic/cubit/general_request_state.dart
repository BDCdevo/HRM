import 'package:equatable/equatable.dart';
import '../../data/models/general_request_model.dart';

abstract class GeneralRequestState extends Equatable {
  const GeneralRequestState();

  @override
  List<Object?> get props => [];
}

class GeneralRequestInitial extends GeneralRequestState {}

class GeneralRequestSubmitting extends GeneralRequestState {}

class GeneralRequestSubmitted extends GeneralRequestState {
  final GeneralRequestModel request;

  const GeneralRequestSubmitted(this.request);

  @override
  List<Object?> get props => [request];
}

class GeneralRequestLoadingHistory extends GeneralRequestState {}

class GeneralRequestHistoryLoaded extends GeneralRequestState {
  final List<GeneralRequestModel> requests;

  const GeneralRequestHistoryLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

class GeneralRequestError extends GeneralRequestState {
  final String message;

  const GeneralRequestError(this.message);

  @override
  List<Object?> get props => [message];
}
