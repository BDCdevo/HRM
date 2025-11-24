import 'package:dio/dio.dart';
import '../../../../core/networking/dio_client.dart';
import '../../../../core/config/api_config.dart';
import '../models/certificate_request_model.dart';

/// Certificate Repository
///
/// Handles all API calls related to certificate requests
class CertificateRepo {
  final DioClient _dioClient = DioClient.getInstance();

  /// Submit a certificate request
  Future<Map<String, dynamic>> submitCertificateRequest({
    required String certificateType,
    required String certificatePurpose,
    required String certificateLanguage,
    required int certificateCopies,
    String? certificateDeliveryMethod,
    String? certificateNeededDate,
    required String reason,
  }) async {
    try {
      final response = await _dioClient.post(
        '${ApiConfig.baseUrl}/requests',
        data: {
          'request_type': 'certificate',
          'reason': reason,
          'certificate_type': certificateType,
          'certificate_purpose': certificatePurpose,
          'certificate_language': certificateLanguage,
          'certificate_copies': certificateCopies,
          if (certificateDeliveryMethod != null)
            'certificate_delivery_method': certificateDeliveryMethod,
          if (certificateNeededDate != null)
            'certificate_needed_date': certificateNeededDate,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to submit request');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to submit certificate request',
        );
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Get certificate request history
  Future<List<CertificateRequestModel>> getCertificateHistory() async {
    try {
      final response = await _dioClient.get(
        '${ApiConfig.baseUrl}/requests?type=certificate',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List;
        return data
            .map((json) => CertificateRequestModel.fromJson(json))
            .toList();
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch certificate history',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch certificate history',
        );
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Get certificate request by ID
  Future<CertificateRequestModel> getCertificateRequestById(int id) async {
    try {
      final response = await _dioClient.get(
        '${ApiConfig.baseUrl}/requests/$id',
      );

      if (response.statusCode == 200) {
        return CertificateRequestModel.fromJson(response.data['data']);
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch certificate request',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch certificate request',
        );
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
