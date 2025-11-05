import 'package:hrm/core/config/api_config.dart';
import 'package:hrm/core/networking/dio_client.dart';
import 'package:hrm/features/branches/data/models/branch_model.dart';

class BranchRepo {
  final _dioClient = DioClient.getInstance();

  /// Get all active branches
  Future<List<BranchModel>> getBranches() async {
    try {
      final response = await _dioClient.get(ApiConfig.branches);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as List;
        return data.map((json) => BranchModel.fromJson(json)).toList();
      }

      throw Exception(response.data['message'] ?? 'Failed to fetch branches');
    } catch (e) {
      throw Exception('Error fetching branches: ${e.toString()}');
    }
  }

  /// Get branch details by ID
  Future<BranchModel> getBranchDetails(int id) async {
    try {
      final response = await _dioClient.get(ApiConfig.branchDetails(id));

      if (response.statusCode == 200 && response.data['success'] == true) {
        return BranchModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Failed to fetch branch details');
    } catch (e) {
      throw Exception('Error fetching branch details: ${e.toString()}');
    }
  }
}
