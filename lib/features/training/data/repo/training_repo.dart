import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/networking/dio_client.dart';
import '../models/training_request_model.dart';

class TrainingRepo {
  final DioClient _dioClient = DioClient.getInstance();

  /// Submit a training request
  Future<TrainingRequestModel> submitTrainingRequest({
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
    try {
      final requestData = {
        'request_type': 'training',
        'training_type': trainingType,
        'training_name': trainingName,
        'reason': reason,
      };

      // Add optional fields
      if (trainingProvider != null && trainingProvider.isNotEmpty) {
        requestData['training_provider'] = trainingProvider;
      }
      if (trainingLocation != null && trainingLocation.isNotEmpty) {
        requestData['training_location'] = trainingLocation;
      }
      if (trainingStartDate != null && trainingStartDate.isNotEmpty) {
        requestData['training_start_date'] = trainingStartDate;
      }
      if (trainingEndDate != null && trainingEndDate.isNotEmpty) {
        requestData['training_end_date'] = trainingEndDate;
      }
      if (trainingCost != null) {
        requestData['training_cost'] = trainingCost.toString();
      }
      if (trainingCostCoverage != null && trainingCostCoverage.isNotEmpty) {
        requestData['training_cost_coverage'] = trainingCostCoverage;
      }
      if (trainingJustification != null && trainingJustification.isNotEmpty) {
        requestData['training_justification'] = trainingJustification;
      }
      if (trainingExpectedBenefit != null &&
          trainingExpectedBenefit.isNotEmpty) {
        requestData['training_expected_benefit'] = trainingExpectedBenefit;
      }

      final response = await _dioClient.post(
        ApiConfig.requests,
        data: requestData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return TrainingRequestModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to submit request');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response!.data['message'] ?? 'Failed to submit training request',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get training request history
  Future<List<TrainingRequestModel>> getTrainingHistory() async {
    try {
      final response = await _dioClient.get(
        '${ApiConfig.requests}?type=training',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => TrainingRequestModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch history');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response!.data['message'] ?? 'Failed to fetch training history',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get a specific training request by ID
  Future<TrainingRequestModel> getTrainingRequestById(int id) async {
    try {
      final response = await _dioClient.get('${ApiConfig.requests}/$id');

      if (response.statusCode == 200) {
        return TrainingRequestModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch request');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response!.data['message'] ?? 'Failed to fetch training request',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }
}
