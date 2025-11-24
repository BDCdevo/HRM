import 'package:equatable/equatable.dart';
import '../../data/models/certificate_request_model.dart';

/// Certificate State
///
/// Represents all possible states for certificate requests
abstract class CertificateState extends Equatable {
  const CertificateState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CertificateInitial extends CertificateState {
  const CertificateInitial();
}

/// Loading state when submitting certificate request
class SubmittingCertificateRequest extends CertificateState {
  const SubmittingCertificateRequest();
}

/// Success state after submitting certificate request
class CertificateRequestSubmitted extends CertificateState {
  final String message;

  const CertificateRequestSubmitted(this.message);

  @override
  List<Object?> get props => [message];
}

/// Loading state when fetching history
class LoadingCertificateHistory extends CertificateState {
  const LoadingCertificateHistory();
}

/// Success state with certificate history
class CertificateHistoryLoaded extends CertificateState {
  final List<CertificateRequestModel> requests;

  const CertificateHistoryLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

/// Error state
class CertificateError extends CertificateState {
  final String message;

  const CertificateError(this.message);

  @override
  List<Object?> get props => [message];
}
