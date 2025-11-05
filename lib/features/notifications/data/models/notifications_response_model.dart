import 'package:equatable/equatable.dart';
import 'notification_model.dart';

/// Notifications Response Model
///
/// Represents paginated notifications response from API
class NotificationsResponseModel extends Equatable {
  final List<NotificationModel> notifications;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int unreadCount;

  const NotificationsResponseModel({
    required this.notifications,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.unreadCount,
  });

  /// Has more pages
  bool get hasMore => currentPage < lastPage;

  /// Is first page
  bool get isFirstPage => currentPage == 1;

  /// Is last page
  bool get isLastPage => currentPage >= lastPage;

  /// Total pages
  int get totalPages => lastPage;

  factory NotificationsResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return NotificationsResponseModel(
      notifications: (data['data'] as List)
          .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      currentPage: data['current_page'] as int,
      lastPage: data['last_page'] as int,
      perPage: data['per_page'] as int,
      total: data['total'] as int,
      unreadCount: data['unread_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'data': notifications.map((n) => n.toJson()).toList(),
        'current_page': currentPage,
        'last_page': lastPage,
        'per_page': perPage,
        'total': total,
        'unread_count': unreadCount,
      },
    };
  }

  @override
  List<Object?> get props => [
        notifications,
        currentPage,
        lastPage,
        perPage,
        total,
        unreadCount,
      ];
}
