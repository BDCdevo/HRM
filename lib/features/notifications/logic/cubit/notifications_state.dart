import 'package:equatable/equatable.dart';
import '../../data/models/notification_model.dart';

/// Notifications State
///
/// Represents different states of notifications operations
abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];

  /// Display message for UI
  String get displayMessage {
    if (this is NotificationsError) {
      return (this as NotificationsError).message;
    }
    return '';
  }
}

/// Initial State
class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

/// Loading State (first page)
class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

/// Loading More State (pagination)
class NotificationsLoadingMore extends NotificationsState {
  final List<NotificationModel> currentNotifications;

  const NotificationsLoadingMore({required this.currentNotifications});

  @override
  List<Object?> get props => [currentNotifications];
}

/// Loaded State
class NotificationsLoaded extends NotificationsState {
  final List<NotificationModel> notifications;
  final int currentPage;
  final int lastPage;
  final int total;
  final int unreadCount;
  final bool hasMore;

  const NotificationsLoaded({
    required this.notifications,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.unreadCount,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [
        notifications,
        currentPage,
        lastPage,
        total,
        unreadCount,
        hasMore,
      ];
}

/// Refreshing State
class NotificationsRefreshing extends NotificationsState {
  final List<NotificationModel> currentNotifications;

  const NotificationsRefreshing({required this.currentNotifications});

  @override
  List<Object?> get props => [currentNotifications];
}

/// Error State
class NotificationsError extends NotificationsState {
  final String message;
  final String? errorDetails;

  const NotificationsError({
    required this.message,
    this.errorDetails,
  });

  @override
  List<Object?> get props => [message, errorDetails];
}
