import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../data/repo/notifications_repo.dart';
import '../../data/models/notification_model.dart';
import 'notifications_state.dart';

/// Notifications Cubit
///
/// Manages notifications state and handles pagination
class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepo _notificationsRepo = NotificationsRepo();

  NotificationsCubit() : super(const NotificationsInitial());

  int _currentPage = 1;
  final int _perPage = 15;
  List<NotificationModel> _allNotifications = [];

  /// Fetch Notifications (First Page)
  ///
  /// Loads the first page of notifications
  /// Emits:
  /// - [NotificationsLoading] while fetching
  /// - [NotificationsLoaded] on success
  /// - [NotificationsError] on failure
  Future<void> fetchNotifications() async {
    try {
      emit(const NotificationsLoading());

      _currentPage = 1;
      _allNotifications = [];

      final response = await _notificationsRepo.getNotifications(
        page: _currentPage,
        perPage: _perPage,
      );

      _allNotifications = response.notifications;

      emit(NotificationsLoaded(
        notifications: _allNotifications,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        total: response.total,
        unreadCount: response.unreadCount,
        hasMore: response.hasMore,
      ));
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      emit(NotificationsError(
        message: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }

  /// Load More (Pagination)
  ///
  /// Loads the next page of notifications
  /// Emits:
  /// - [NotificationsLoadingMore] while fetching
  /// - [NotificationsLoaded] on success with updated notifications
  /// - [NotificationsError] on failure
  Future<void> loadMore() async {
    final currentState = state;

    // Only load more if we have a loaded state and there are more pages
    if (currentState is! NotificationsLoaded || !currentState.hasMore) {
      return;
    }

    try {
      emit(NotificationsLoadingMore(currentNotifications: _allNotifications));

      _currentPage++;

      final response = await _notificationsRepo.getNotifications(
        page: _currentPage,
        perPage: _perPage,
      );

      _allNotifications.addAll(response.notifications);

      emit(NotificationsLoaded(
        notifications: _allNotifications,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        total: response.total,
        unreadCount: response.unreadCount,
        hasMore: response.hasMore,
      ));
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      emit(NotificationsError(
        message: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }

  /// Refresh
  ///
  /// Refreshes the notifications (pulls first page again)
  /// Emits:
  /// - [NotificationsRefreshing] while refreshing
  /// - [NotificationsLoaded] on success
  /// - [NotificationsError] on failure
  Future<void> refresh() async {
    final currentState = state;

    try {
      // Show refreshing state if we already have data
      if (currentState is NotificationsLoaded) {
        emit(NotificationsRefreshing(currentNotifications: _allNotifications));
      } else {
        emit(const NotificationsLoading());
      }

      _currentPage = 1;
      _allNotifications = [];

      final response = await _notificationsRepo.getNotifications(
        page: _currentPage,
        perPage: _perPage,
      );

      _allNotifications = response.notifications;

      emit(NotificationsLoaded(
        notifications: _allNotifications,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        total: response.total,
        unreadCount: response.unreadCount,
        hasMore: response.hasMore,
      ));
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      emit(NotificationsError(
        message: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }

  /// Mark as Read
  ///
  /// Marks a notification as read and updates the state
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationsRepo.markAsRead(notificationId);

      // Update local state
      final index = _allNotifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _allNotifications[index] = _allNotifications[index].copyWith(
          readAt: DateTime.now().toIso8601String(),
        );

        final currentState = state;
        if (currentState is NotificationsLoaded) {
          emit(NotificationsLoaded(
            notifications: List.from(_allNotifications),
            currentPage: currentState.currentPage,
            lastPage: currentState.lastPage,
            total: currentState.total,
            unreadCount: currentState.unreadCount - 1,
            hasMore: currentState.hasMore,
          ));
        }
      }
    } catch (e) {
      // Silent fail, don't disrupt the user experience
      print('Mark as read error: $e');
    }
  }

  /// Mark All as Read
  ///
  /// Marks all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _notificationsRepo.markAllAsRead();

      // Update local state
      final now = DateTime.now().toIso8601String();
      _allNotifications = _allNotifications
          .map((n) => n.isUnread ? n.copyWith(readAt: now) : n)
          .toList();

      final currentState = state;
      if (currentState is NotificationsLoaded) {
        emit(NotificationsLoaded(
          notifications: List.from(_allNotifications),
          currentPage: currentState.currentPage,
          lastPage: currentState.lastPage,
          total: currentState.total,
          unreadCount: 0,
          hasMore: currentState.hasMore,
        ));
      }
    } catch (e) {
      print('Mark all as read error: $e');
    }
  }

  /// Delete Notification
  ///
  /// Deletes a notification and updates the state
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationsRepo.deleteNotification(notificationId);

      // Remove from local state
      final wasUnread = _allNotifications
          .firstWhere((n) => n.id == notificationId)
          .isUnread;
      _allNotifications.removeWhere((n) => n.id == notificationId);

      final currentState = state;
      if (currentState is NotificationsLoaded) {
        emit(NotificationsLoaded(
          notifications: List.from(_allNotifications),
          currentPage: currentState.currentPage,
          lastPage: currentState.lastPage,
          total: currentState.total - 1,
          unreadCount: wasUnread
              ? currentState.unreadCount - 1
              : currentState.unreadCount,
          hasMore: currentState.hasMore,
        ));
      }
    } catch (e) {
      print('Delete notification error: $e');
    }
  }

  /// Handle Dio Exception
  void _handleDioException(DioException e) {
    if (e.response != null) {
      // Server responded with error
      final statusCode = e.response?.statusCode;
      final errorMessage = e.response?.data?['message'] ?? 'Operation failed';

      emit(NotificationsError(
        message: '[$statusCode] $errorMessage',
        errorDetails: e.response?.data?.toString(),
      ));
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      // Timeout error
      emit(const NotificationsError(
        message: 'Request timeout. Please try again.',
      ));
    } else if (e.type == DioExceptionType.unknown) {
      // Network error (no internet connection)
      emit(const NotificationsError(
        message: 'Network error. Please check your internet connection.',
      ));
    } else {
      // Other Dio errors
      emit(NotificationsError(
        message: e.message ?? 'An unexpected error occurred',
      ));
    }
  }
}
