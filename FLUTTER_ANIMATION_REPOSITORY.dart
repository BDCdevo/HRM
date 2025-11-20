import 'package:dio/dio.dart';
import '../../../../core/networking/dio_client.dart';
import '../../../../core/config/api_config.dart';

/// Repository for handling custom user animations
///
/// Provides methods to:
/// - Upload Lottie animation files
/// - Get user's current animation
/// - Delete custom animation
/// - Validate animation before upload
class AnimationRepository {
  final _dioClient = DioClient.getInstance();

  /// Upload custom Lottie animation
  ///
  /// [filePath] - Local file path to the JSON animation file
  /// Returns animation URL and metadata
  /// Throws Exception on failure
  Future<Map<String, dynamic>> uploadAnimation(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'animation': await MultipartFile.fromFile(
          filePath,
          filename: 'animation.json',
        ),
      });

      final response = await _dioClient.post(
        '${ApiConfig.baseUrl}/employee/animation/upload',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }

      throw Exception(response.data['message'] ?? 'فشل رفع الملف');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'حدث خطأ أثناء رفع الملف');
      }
      throw Exception('فشل الاتصال بالسيرفر');
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }

  /// Get employee's custom animation
  ///
  /// Returns animation URL and metadata if exists
  /// Returns null if no custom animation
  /// Throws Exception on failure
  Future<Map<String, dynamic>> getAnimation() async {
    try {
      final response = await _dioClient.get(
        '${ApiConfig.baseUrl}/employee/animation',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }

      throw Exception(response.data['message'] ?? 'فشل جلب البيانات');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'حدث خطأ أثناء جلب البيانات');
      }
      throw Exception('فشل الاتصال بالسيرفر');
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }

  /// Delete custom animation (revert to default)
  ///
  /// Throws Exception on failure
  Future<void> deleteAnimation() async {
    try {
      final response = await _dioClient.delete(
        '${ApiConfig.baseUrl}/employee/animation',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return;
      }

      throw Exception(response.data['message'] ?? 'فشل حذف الملف');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'حدث خطأ أثناء الحذف');
      }
      throw Exception('فشل الاتصال بالسيرفر');
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }

  /// Validate animation before upload
  ///
  /// [filePath] - Local file path to validate
  /// Returns animation metadata if valid
  /// Throws Exception if invalid
  Future<Map<String, dynamic>> validateAnimation(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'animation': await MultipartFile.fromFile(
          filePath,
          filename: 'animation.json',
        ),
      });

      final response = await _dioClient.post(
        '${ApiConfig.baseUrl}/employee/animation/validate',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }

      throw Exception(response.data['message'] ?? 'الملف غير صالح');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'حدث خطأ أثناء التحقق من الملف');
      }
      throw Exception('فشل الاتصال بالسيرفر');
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }

  /// Get all employees with custom animations (Admin only)
  ///
  /// Returns list of employees with their animations
  /// Throws Exception on failure or if not authorized
  Future<List<Map<String, dynamic>>> getAllCustomAnimations() async {
    try {
      final response = await _dioClient.get(
        '${ApiConfig.baseUrl}/employee/animation/all',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['employees'] ?? []);
      }

      throw Exception(response.data['message'] ?? 'فشل جلب البيانات');
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 403) {
          throw Exception('غير مصرح لك بالوصول');
        }
        throw Exception(e.response!.data['message'] ?? 'حدث خطأ أثناء جلب البيانات');
      }
      throw Exception('فشل الاتصال بالسيرفر');
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }
}
