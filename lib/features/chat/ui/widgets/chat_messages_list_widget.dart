import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/widgets/error_widgets.dart';
import '../../data/models/message_model.dart';
import '../../logic/cubit/messages_state.dart';
import 'message_bubble.dart';
import 'chat_messages_skeleton.dart';

/// Chat Messages List Widget
///
/// Displays the list of messages with sticky date headers
class ChatMessagesListWidget extends StatelessWidget {
  final MessagesState state;
  final ScrollController scrollController;
  final bool isDark;
  final int conversationId;
  final int companyId;
  final bool isGroupChat;
  final VoidCallback onRefresh;
  final Function(MessageModel)? onReply;
  final Function(MessageModel)? onDelete;

  const ChatMessagesListWidget({
    super.key,
    required this.state,
    required this.scrollController,
    required this.isDark,
    required this.conversationId,
    required this.companyId,
    this.isGroupChat = false,
    required this.onRefresh,
    this.onReply,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (state is MessagesLoading) {
      return _buildLoadingState();
    }

    // Error state (with no cached messages)
    if (state is MessagesError && (state as MessagesError).messages == null) {
      return _buildErrorState(context, (state as MessagesError).message);
    }

    // Get messages from state
    final messages = _getMessagesFromState(state);

    // Empty state
    if (messages.isEmpty) {
      return _buildEmptyState();
    }

    // Group messages by date
    final groupedMessages = _groupMessagesByDate(messages);

    // Messages list with sticky headers
    return RefreshIndicator(
      color: isDark ? AppColors.darkAccent : AppColors.accent,
      onRefresh: () async {
        onRefresh();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: CustomScrollView(
        controller: scrollController,
        reverse: true, // Start from bottom (latest messages)
        slivers: _buildSlivers(groupedMessages),
      ),
    );
  }

  /// Build slivers for CustomScrollView
  List<Widget> _buildSlivers(Map<String, List<MessageModel>> groupedMessages) {
    final slivers = <Widget>[];

    // Get dates in reverse order (newest first because of reverse: true)
    final dates = groupedMessages.keys.toList().reversed.toList();

    for (final date in dates) {
      final messagesForDate = groupedMessages[date]!;

      // Reverse messages within each date group so they appear oldest to newest
      final reversedMessages = messagesForDate.reversed.toList();

      // Messages for this date (added FIRST)
      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final message = reversedMessages[index];
              final isLastMessage = index == reversedMessages.length - 1;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: _SwipeableMessageBubble(
                      message: message,
                      isSentByMe: message.isMine,
                      isGroupChat: isGroupChat,
                      isDark: isDark,
                      onReply: onReply,
                      onDelete: onDelete,
                    ),
                  ),
                  // Add divider between messages (except last one)
                  if (!isLastMessage)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Divider(
                        height: 1,
                        thickness: 0.5,
                        color: isDark
                          ? AppColors.darkBorder.withOpacity(0.3)
                          : AppColors.border.withOpacity(0.5),
                      ),
                    ),
                ],
              );
            },
            childCount: reversedMessages.length,
          ),
        ),
      );

      // Sticky Header for date (added AFTER messages)
      // Because of reverse: true, this will appear ABOVE the messages
      slivers.add(
        SliverPersistentHeader(
          pinned: true, // Makes it sticky!
          delegate: _DateHeaderDelegate(
            date: date,
            isDark: isDark,
          ),
        ),
      );
    }

    // Add padding at the top (will be at bottom due to reverse)
    slivers.add(
      const SliverToBoxAdapter(
        child: SizedBox(height: 8),
      ),
    );

    return slivers;
  }

  /// Group messages by date
  /// Returns LinkedHashMap to preserve insertion order
  Map<String, List<MessageModel>> _groupMessagesByDate(List<MessageModel> messages) {
    final Map<String, List<MessageModel>> grouped = <String, List<MessageModel>>{};

    // Process messages in order (oldest to newest)
    for (final message in messages) {
      final dateKey = _getDateKey(message.createdAt);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(message);
    }

    return grouped;
  }

  /// Get date key for grouping
  String _getDateKey(String dateTimeString) {
    try {
      final messageDate = DateTime.parse(dateTimeString).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final messageDateOnly = DateTime(messageDate.year, messageDate.month, messageDate.day);

      if (messageDateOnly == today) {
        return 'Today';
      } else if (messageDateOnly == yesterday) {
        return 'Yesterday';
      } else {
        return DateFormat('MMM dd, yyyy').format(messageDate);
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Get messages from state
  List<MessageModel> _getMessagesFromState(MessagesState state) {
    if (state is MessagesLoaded) return state.messages;
    if (state is MessageSending) return state.messages;
    if (state is MessageSent) return state.messages;
    if (state is MessagesRefreshing) return state.messages;
    if (state is MessagesError) return state.messages ?? [];
    return [];
  }

  /// Build Loading State
  Widget _buildLoadingState() {
    return const ChatMessagesSkeleton();
  }

  /// Build Error State
  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return CompactErrorWidget(
      message: ErrorSnackBar.getArabicMessage(errorMessage),
      onRetry: onRefresh,
    );
  }

  /// Build Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? AppColors.darkAccent : AppColors.accent)
                    .withOpacity(0.1),
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: isDark ? AppColors.darkAccent : AppColors.accent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No messages yet',
              style: AppTextStyles.titleLarge.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start the conversation by sending a message',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Sticky Date Header Delegate
class _DateHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String date;
  final bool isDark;

  _DateHeaderDelegate({
    required this.date,
    required this.isDark,
  });

  @override
  double get minExtent => 44.0; // Minimum height when scrolled

  @override
  double get maxExtent => 44.0; // Maximum height

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
            ? [
                const Color(0xFF0B141A).withOpacity(0.95),
                const Color(0xFF0B141A).withOpacity(0.90),
              ]
            : [
                const Color(0xFFECE5DD).withOpacity(0.95),
                const Color(0xFFECE5DD).withOpacity(0.90),
              ],
        ),
        boxShadow: overlapsContent ? [
          BoxShadow(
            color: isDark
              ? Colors.black.withOpacity(0.3)
              : Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : [],
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1F2C34)
              : const Color(0xFFE1F5FE),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          date,
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_DateHeaderDelegate oldDelegate) {
    return date != oldDelegate.date || isDark != oldDelegate.isDark;
  }
}

/// Swipeable Message Bubble with reply gesture
class _SwipeableMessageBubble extends StatefulWidget {
  final MessageModel message;
  final bool isSentByMe;
  final bool isGroupChat;
  final bool isDark;
  final Function(MessageModel)? onReply;
  final Function(MessageModel)? onDelete;

  const _SwipeableMessageBubble({
    required this.message,
    required this.isSentByMe,
    required this.isGroupChat,
    required this.isDark,
    this.onReply,
    this.onDelete,
  });

  @override
  State<_SwipeableMessageBubble> createState() => _SwipeableMessageBubbleState();
}

class _SwipeableMessageBubbleState extends State<_SwipeableMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  double _dragOffset = 0;
  bool _hasTriggeredReply = false;
  static const double _replyThreshold = 60.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (widget.onReply == null) return;

    setState(() {
      // Allow swipe from left to right (for all messages)
      _dragOffset += details.delta.dx;
      _dragOffset = _dragOffset.clamp(0.0, _replyThreshold * 1.5);

      // Check if reached threshold
      if (_dragOffset >= _replyThreshold && !_hasTriggeredReply) {
        _hasTriggeredReply = true;
        // Haptic feedback
        HapticFeedback.mediumImpact();
      } else if (_dragOffset < _replyThreshold) {
        _hasTriggeredReply = false;
      }
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (widget.onReply == null) return;

    if (_hasTriggeredReply) {
      widget.onReply?.call(widget.message);
    }

    // Animate back to original position
    _slideAnimation = Tween<Offset>(
      begin: Offset(_dragOffset / MediaQuery.of(context).size.width, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward(from: 0).then((_) {
      setState(() {
        _dragOffset = 0;
        _hasTriggeredReply = false;
      });
    });
  }

  void _showMessageOptions(BuildContext context) {
    final isDark = widget.isDark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2C34) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reply option
            ListTile(
              leading: Icon(
                Icons.reply,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              title: Text(
                'Reply',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                widget.onReply?.call(widget.message);
              },
            ),

            // Delete option (only for own messages)
            if (widget.isSentByMe)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context);
                },
              ),

            // Cancel
            ListTile(
              leading: Icon(
                Icons.close,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
              title: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
              onTap: () => Navigator.pop(context),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final isDark = widget.isDark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F2C34) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'حذف الرسالة؟',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'هل أنت متأكد من حذف هذه الرسالة؟ لا يمكن التراجع عن هذا الإجراء.',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete?.call(widget.message);
            },
            child: const Text(
              'حذف',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_dragOffset / _replyThreshold).clamp(0.0, 1.0);

    return GestureDetector(
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      onLongPress: () => _showMessageOptions(context),
      child: Stack(
        children: [
          // Reply icon (appears as you swipe)
          if (_dragOffset > 0)
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: Transform.scale(
                  scale: progress,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _hasTriggeredReply
                          ? (widget.isDark
                              ? AppColors.darkAccent
                              : AppColors.accent)
                          : (widget.isDark
                              ? Colors.grey[700]
                              : Colors.grey[300]),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.reply,
                      color: _hasTriggeredReply
                          ? Colors.white
                          : (widget.isDark ? Colors.grey[400] : Colors.grey[600]),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),

          // Message bubble
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: _controller.isAnimating
                    ? Offset(_slideAnimation.value.dx * MediaQuery.of(context).size.width, 0)
                    : Offset(_dragOffset, 0),
                child: MessageBubble(
                  message: widget.message,
                  isSentByMe: widget.isSentByMe,
                  isGroupChat: widget.isGroupChat,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
