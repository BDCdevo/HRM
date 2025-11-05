import '../../../../core/networking/dio_client.dart';
import '../../../../core/config/api_config.dart';
import '../models/notifications_response_model.dart';

/// Notifications Repository
///
/// Handles all notification-related API calls
class NotificationsRepo {
  final DioClient _dioClient = DioClient.getInstance();

  /// Get Notifications
  ///
  /// Fetches paginated notifications for the authenticated user
  /// GET /api/v1/notifications?page=1&per_page=15
  Future<NotificationsResponseModel> getNotifications({
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiConfig.notifications,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      print('📬 Notifications Response: ${response.data}');

      return NotificationsResponseModel.fromJson(response.data);
    } catch (e) {
      print('❌ Get Notifications Error: $e');
      rethrow;
    }
  }

  /// Mark Notification as Read
  ///
  /// Marks a specific notification as read
  /// POST /api/v1/notifications/{id}/read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _dioClient.post(
        ApiConfig.markNotificationAsRead(notificationId),
      );

      print('✅ Notification $notificationId marked as read');
    } catch (e) {
      print('❌ Mark as Read Error: $e');
      rethrow;
    }
  }

  /// Mark All Notifications as Read
  ///
  /// Marks all user notifications as read
  /// POST /api/v1/notifications/read-all
  Future<void> markAllAsRead() async {
    try {
      await _dioClient.post(
        ApiConfig.markAllNotificationsAsRead,
      );

      print('✅ All notifications marked as read');
    } catch (e) {
      print('❌ Mark All as Read Error: $e');
      rethrow;
    }
  }

  /// Delete Notification
  ///
  /// Deletes a specific notification
  /// DELETE /api/v1/notifications/{id}
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _dioClient.delete(
        ApiConfig.deleteNotification(notificationId),
      );

      print('✅ Notification $notificationId deleted');
    } catch (e) {
      print('❌ Delete Notification Error: $e');
      rethrow;
    }
  }
}
