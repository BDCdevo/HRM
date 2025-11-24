import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/certificate_repo.dart';
import 'certificate_state.dart';

/// Certificate Cubit
///
/// Manages business logic for certificate requests
class CertificateCubit extends Cubit<CertificateState> {
  final CertificateRepo _repo;

  CertificateCubit(this._repo) : super(const CertificateInitial());

  /// Submit a certificate request
  Future<void> submitCertificateRequest({
    required String certificateType,
    required String certificatePurpose,
    required String certificateLanguage,
    required int certificateCopies,
    String? certificateDeliveryMethod,
    String? certificateNeededDate,
    required String reason,
  }) async {
    emit(const SubmittingCertificateRequest());

    try {
      final response = await _repo.submitCertificateRequest(
        certificateType: certificateType,
        certificatePurpose: certificatePurpose,
        certificateLanguage: certificateLanguage,
        certificateCopies: certificateCopies,
        certificateDeliveryMethod: certificateDeliveryMethod,
        certificateNeededDate: certificateNeededDate,
        reason: reason,
      );

      final message = response['message'] ?? 'تم تقديم الطلب بنجاح';
      emit(CertificateRequestSubmitted(message));

      // Auto-fetch history after successful submission
      await fetchCertificateHistory();
    } catch (e) {
      emit(CertificateError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Fetch certificate request history
  Future<void> fetchCertificateHistory() async {
    emit(const LoadingCertificateHistory());

    try {
      final requests = await _repo.getCertificateHistory();
      emit(CertificateHistoryLoaded(requests));
    } catch (e) {
      emit(CertificateError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Reset to initial state
  void reset() {
    emit(const CertificateInitial());
  }
}
