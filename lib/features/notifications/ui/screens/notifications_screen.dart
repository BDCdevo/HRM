import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/widgets/error_widgets.dart';
import '../../logic/cubit/notifications_cubit.dart';
import '../../logic/cubit/notifications_state.dart';
import '../../data/models/notification_model.dart';
import '../widgets/notifications_skeleton.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Notifications Screen
///
/// Displays paginated list of user's notifications
/// Features:
/// - Pagination (load more on scroll)
/// - Pull to refresh
/// - Mark as read/unread
/// - Delete notifications
/// - Swipe actions
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final NotificationsCubit _notificationsCubit;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _notificationsCubit = NotificationsCubit();
    _scrollController = ScrollController();

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);

    // Fetch initial data
    _notificationsCubit.fetchNotifications();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _notificationsCubit.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      // When user scrolls to 90% of the list, load more
      _notificationsCubit.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _notificationsCubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppColors.white,
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Notifications',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.white,
            ),
          ),
          actions: [
            BlocBuilder<NotificationsCubit, NotificationsState>(
              builder: (context, state) {
                if (state is NotificationsLoaded && state.unreadCount > 0) {
                  return IconButton(
                    icon: const Icon(Icons.done_all),
                    color: AppColors.white,
                    tooltip: 'Mark all as read',
                    onPressed: () {
                      _notificationsCubit.markAllAsRead();
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            // Show loading state
            if (state is NotificationsLoading) {
              return const NotificationsSkeleton();
            }

            // Show error state
            if (state is NotificationsError &&
                state is! NotificationsLoaded) {
              return CompactErrorWidget(
                message: ErrorSnackBar.getArabicMessage(state.displayMessage),
                onRetry: () => _notificationsCubit.fetchNotifications(),
              );
            }

            // Get notifications from loaded state
            final notifications = state is NotificationsLoaded
                ? state.notifications
                : (state is NotificationsLoadingMore
                    ? state.currentNotifications
                    : (state is NotificationsRefreshing
                        ? state.currentNotifications
                        : <NotificationModel>[]));

            final unreadCount =
                state is NotificationsLoaded ? state.unreadCount : 0;
            final hasMore =
                state is NotificationsLoaded ? state.hasMore : false;
            final isLoadingMore = state is NotificationsLoadingMore;
            final isRefreshing = state is NotificationsRefreshing;

            // Show empty state
            if (notifications.isEmpty && !isRefreshing) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Notifications',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You\'re all caught up!',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: [
                // Unread count banner
                if (unreadCount > 0)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      '$unreadCount unread notification${unreadCount > 1 ? 's' : ''}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Notifications list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _notificationsCubit.refresh(),
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: notifications.length + (hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Show loading indicator at the end if there are more items
                        if (index >= notifications.length) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: isLoadingMore
                                  ? const CircularProgressIndicator()
                                  : const SizedBox.shrink(),
                            ),
                          );
                        }

                        final notification = notifications[index];
                        return _buildNotificationCard(notification);
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        child: Icon(
          Icons.delete,
          color: AppColors.white,
        ),
      ),
      onDismissed: (direction) {
        _notificationsCubit.deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: InkWell(
        onTap: () {
          if (notification.isUnread) {
            _notificationsCubit.markAsRead(notification.id);
          }
          // TODO: Handle notification action based on actionType
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isUnread
                ? AppColors.primary.withValues(alpha: 0.05)
                : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: notification.isUnread
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.border,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.textSecondary.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getNotificationIcon(notification),
                  color: AppColors.primary,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      notification.title,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: notification.isUnread
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    if (notification.message.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Time
                    Text(
                      _getFormattedTime(notification.createdAt),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Unread indicator
              if (notification.isUnread)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(left: 8, top: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationModel notification) {
    final icon = notification.icon;
    if (icon != null) {
      // Map icon names to IconData
      switch (icon.toLowerCase()) {
        case 'check_circle':
          return Icons.check_circle;
        case 'info':
          return Icons.info;
        case 'warning':
          return Icons.warning;
        case 'event':
          return Icons.event;
        case 'person':
          return Icons.person;
        default:
          return Icons.notifications;
      }
    }
    return Icons.notifications;
  }

  String _getFormattedTime(String dateTime) {
    try {
      final date = DateTime.parse(dateTime);
      return timeago.format(date);
    } catch (e) {
      return dateTime;
    }
  }
}
