import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/networking/dio_client.dart';
import '../models/general_request_model.dart';

class GeneralRequestRepo {
  final DioClient _dioClient = DioClient.getInstance();

  /// Submit a general request
  Future<GeneralRequestModel> submitGeneralRequest({
    required String generalCategory,
    required String generalSubject,
    required String generalDescription,
    String generalPriority = 'medium',
    required String reason,
  }) async {
    try {
      final requestData = {
        'request_type': 'general',
        'general_category': generalCategory,
        'general_subject': generalSubject,
        'general_description': generalDescription,
        'general_priority': generalPriority,
        'reason': reason,
      };

      final response = await _dioClient.post(
        ApiConfig.requests,
        data: requestData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return GeneralRequestModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to submit request');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response!.data['message'] ?? 'Failed to submit general request',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get general request history
  Future<List<GeneralRequestModel>> getGeneralRequestHistory() async {
    try {
      final response = await _dioClient.get(
        '${ApiConfig.requests}?type=general',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data
            .map((json) => GeneralRequestModel.fromJson(json))
            .toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch history');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response!.data['message'] ?? 'Failed to fetch request history',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get a specific general request by ID
  Future<GeneralRequestModel> getGeneralRequestById(int id) async {
    try {
      final response = await _dioClient.get('${ApiConfig.requests}/$id');

      if (response.statusCode == 200) {
        return GeneralRequestModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch request');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response!.data['message'] ?? 'Failed to fetch general request',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }
}
