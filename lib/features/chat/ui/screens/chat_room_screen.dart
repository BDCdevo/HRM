import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/networking/dio_client.dart';
import '../../../../core/services/websocket_service.dart';
import '../../data/repo/chat_repository.dart';
import '../../data/models/message_model.dart';
import '../../logic/cubit/messages_cubit.dart';
import '../../logic/cubit/messages_state.dart';
import '../widgets/message_bubble.dart';

/// Chat Room Screen - WhatsApp Style
///
/// Displays messages between users (private or group)
class ChatRoomScreen extends StatelessWidget {
  final int conversationId;
  final String participantName;
  final String? participantAvatar;
  final int companyId;
  final int currentUserId;
  final bool isGroupChat;

  const ChatRoomScreen({
    super.key,
    required this.conversationId,
    required this.participantName,
    this.participantAvatar,
    required this.companyId,
    required this.currentUserId,
    this.isGroupChat = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MessagesCubit(ChatRepository())
            ..fetchMessages(
              conversationId: conversationId,
              companyId: companyId,
            ),
      child: _ChatRoomView(
        conversationId: conversationId,
        participantName: participantName,
        participantAvatar: participantAvatar,
        companyId: companyId,
        currentUserId: currentUserId,
        isGroupChat: isGroupChat,
      ),
    );
  }
}

class _ChatRoomView extends StatefulWidget {
  final int conversationId;
  final String participantName;
  final String? participantAvatar;
  final int companyId;
  final int currentUserId;
  final bool isGroupChat;

  const _ChatRoomView({
    required this.conversationId,
    required this.participantName,
    this.participantAvatar,
    required this.companyId,
    required this.currentUserId,
    this.isGroupChat = false,
  });

  @override
  State<_ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<_ChatRoomView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  final WebSocketService _websocket = WebSocketService.instance;
  Timer? _pollingTimer;
  int _lastMessageId = 0;

  @override
  void initState() {
    super.initState();
    _setupWebSocket();
    // Start polling as fallback for real-time updates
    _startPolling();
  }

  /// Setup WebSocket listener for real-time messages
  Future<void> _setupWebSocket() async {
    try {
      // Initialize WebSocket connection
      await _websocket.initialize();

      // Get channel name: chat.{companyId}.conversation.{conversationId}
      final channelName = WebSocketService.getChatChannelName(
        widget.companyId,
        widget.conversationId,
      );

      // Subscribe to private channel
      await _websocket.subscribeToPrivateChannel(
        channelName: channelName,
        onEvent: (PusherEvent event) {
          print('📨 Received real-time message: ${event.data}');

          // Handle incoming message
          if (event.eventName == 'message.sent') {
            _handleIncomingMessage(event.data);
          }
        },
      );

      print('✅ WebSocket listener setup complete for conversation ${widget.conversationId}');
    } catch (e) {
      print('❌ Failed to setup WebSocket: $e');
    }
  }

  /// Handle incoming real-time message
  void _handleIncomingMessage(dynamic data) {
    try {
      // Parse message data
      final messageData = data is Map ? data : {};

      // Create MessageModel from incoming data
      final message = MessageModel(
        id: messageData['id'] ?? 0,
        conversationId: widget.conversationId,
        senderId: messageData['user_id'] ?? 0,
        senderName: messageData['user_name'] ?? 'Unknown',
        senderAvatar: messageData['user_avatar'],
        message: messageData['body'] ?? '',
        messageType: messageData['attachment_type'] ?? 'text',
        isRead: messageData['read_at'] != null,
        isMine: messageData['is_mine'] ?? false,
        createdAt: messageData['created_at'] ?? DateTime.now().toIso8601String(),
        updatedAt: messageData['created_at'] ?? DateTime.now().toIso8601String(),
      );

      // Add message to cubit (which will update UI)
      context.read<MessagesCubit>().addOptimisticMessage(message);

      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);

      print('✅ Real-time message added to chat');
    } catch (e) {
      print('❌ Failed to handle incoming message: $e');
    }
  }

  /// Start polling for new messages (fallback for WebSocket)
  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      // Check if widget is still mounted before refreshing
      if (!mounted) {
        timer.cancel();
        return;
      }

      // Refresh messages every 3 seconds (keeps showing current messages)
      context.read<MessagesCubit>().refreshMessages(
        conversationId: widget.conversationId,
        companyId: widget.companyId,
      );
    });
    print('✅ Polling started (checking for new messages every 3 seconds)');
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    // Unsubscribe from channel
    final channelName = WebSocketService.getChatChannelName(
      widget.companyId,
      widget.conversationId,
    );
    _websocket.unsubscribe(channelName);

    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0B141A) // WhatsApp dark background
          : const Color(0xFFECE5DD), // WhatsApp light background
      appBar: _buildAppBar(isDark),
      resizeToAvoidBottomInset: true, // Ensure input field is visible above keyboard
      body: SafeArea(
        bottom: true,
        child: BlocConsumer<MessagesCubit, MessagesState>(
        listener: (context, state) {
          if (state is MessageSent) {
            _messageController.clear();
            // Scroll to bottom after sending
            Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
          }

          if (state is MessageSendError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                action: SnackBarAction(
                  label: 'Dismiss',
                  textColor: AppColors.white,
                  onPressed: () {},
                ),
              ),
            );
          }

          if (state is MessagesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Messages List
              Expanded(
                child: _buildMessagesList(state, isDark),
              ),

              // Message Input
              _buildMessageInput(state, isDark),
            ],
          );
        },
        ),
      ),
    );
  }

  /// Build App Bar
  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? AppColors.darkAppBar : AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: InkWell(
        onTap: _openEmployeeProfile,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withOpacity(0.2),
                ),
                child: Center(
                  child: Text(
                    widget.participantName.isNotEmpty
                        ? widget.participantName[0].toUpperCase()
                        : '?',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.participantName,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Tap to view profile',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.white),
          onPressed: () {
            context.read<MessagesCubit>().refreshMessages(
                  conversationId: widget.conversationId,
                  companyId: widget.companyId,
                );
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.white),
          onSelected: (value) {
            if (value == 'view_profile') {
              _openEmployeeProfile();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view_profile',
              child: Text('View profile'),
            ),
          ],
        ),
      ],
    );
  }

  /// Build Messages List
  Widget _buildMessagesList(MessagesState state, bool isDark) {
    if (state is MessagesLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: isDark ? AppColors.darkAccent : AppColors.accent,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading messages...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (state is MessagesError && state.messages == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load messages',
                style: AppTextStyles.titleMedium.copyWith(
                  color:
                      isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<MessagesCubit>().fetchMessages(
                        conversationId: widget.conversationId,
                        companyId: widget.companyId,
                      );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ? AppColors.darkAccent : AppColors.accent,
                  foregroundColor: AppColors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Get messages from state
    final messages = state is MessagesLoaded
        ? state.messages
        : state is MessageSending
            ? state.messages
            : state is MessageSent
                ? state.messages
                : state is MessagesRefreshing
                    ? state.messages
                    : state is MessagesError
                        ? (state.messages ?? [])
                        : [];

    if (messages.isEmpty) {
      return _buildEmptyState(isDark);
    }

    // Scroll to bottom after messages load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state is MessagesLoaded && _scrollController.hasClients) {
        _scrollToBottom();
      }
    });

    return RefreshIndicator(
      color: isDark ? AppColors.darkAccent : AppColors.accent,
      onRefresh: () async {
        await context.read<MessagesCubit>().refreshMessages(
              conversationId: widget.conversationId,
              companyId: widget.companyId,
            );
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];

          // Check if we need to show date separator
          bool showDateSeparator = false;
          if (index == 0) {
            showDateSeparator = true;
          } else {
            final previousMessage = messages[index - 1];
            showDateSeparator = _shouldShowDateSeparator(
              previousMessage.createdAt,
              message.createdAt,
            );
          }

          return Column(
            children: [
              // Date separator
              if (showDateSeparator)
                _buildDateSeparator(message.createdAt, isDark),

              // Message bubble
              Builder(
                builder: (context) {
                  // Use is_mine from Backend instead of comparing IDs
                  final isMine = message.isMine;
                  // Debug logging
                  if (index == 0) {
                    print('🔍 Message Debug:');
                    print('  message.isMine: ${message.isMine}');
                    print('  message.senderId: ${message.senderId}');
                    print('  widget.currentUserId: ${widget.currentUserId}');
                    print('  isSentByMe: $isMine');
                  }
                  return MessageBubble(
                    message: message,
                    isSentByMe: isMine,
                    isGroupChat: widget.isGroupChat,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  /// Build Empty State
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color:
                (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)
                    .withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: AppTextStyles.titleMedium.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send a message to start the conversation',
            style: AppTextStyles.bodyMedium.copyWith(
              color:
                  (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary)
                      .withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Build Message Input
  Widget _buildMessageInput(MessagesState state, bool isDark) {
    final isSending = state is MessageSending;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Emoji button
          IconButton(
            icon: Icon(
              Icons.emoji_emotions_outlined,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
            onPressed: isSending ? null : () {
              // TODO: Show emoji picker
            },
          ),

          // Text field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkInput : AppColors.background,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                enabled: !isSending,
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ),

          const SizedBox(width: 4),

          // Attachment button
          IconButton(
            icon: Icon(
              Icons.attach_file,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
            onPressed: isSending ? null : _pickFile,
          ),

          // Camera button
          IconButton(
            icon: Icon(
              Icons.camera_alt,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
            onPressed: isSending ? null : _pickImageFromCamera,
          ),

          // Send button
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSending
                  ? (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)
                  : (isDark ? AppColors.darkAccent : AppColors.accent),
              shape: BoxShape.circle,
            ),
            child: isSending
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.send, color: AppColors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
          ),
        ],
      ),
    );
  }

  /// Send Message
  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    context.read<MessagesCubit>().sendMessage(
          conversationId: widget.conversationId,
          companyId: widget.companyId,
          message: message,
        );
  }

  /// Pick Image from Camera
  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image != null) {
      _sendFileMessage(File(image.path));
    }
  }

  /// Pick File (Image/Document)
  Future<void> _pickFile() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image != null) {
      _sendFileMessage(File(image.path));
    }
  }

  /// Send File Message
  void _sendFileMessage(File file) {
    context.read<MessagesCubit>().sendMessage(
          conversationId: widget.conversationId,
          companyId: widget.companyId,
          attachment: file,
        );
  }

  /// Open Employee Profile
  void _openEmployeeProfile() {
    // TODO: Navigate to employee profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${widget.participantName}\'s profile...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Check if date separator should be shown
  bool _shouldShowDateSeparator(String previousDateStr, String currentDateStr) {
    try {
      final previousDate = DateTime.parse(previousDateStr);
      final currentDate = DateTime.parse(currentDateStr);

      final prevDay = DateTime(
        previousDate.year,
        previousDate.month,
        previousDate.day,
      );
      final currDay = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
      );

      return prevDay != currDay;
    } catch (e) {
      return false;
    }
  }

  /// Build Date Separator (Today, Yesterday, Date)
  Widget _buildDateSeparator(String dateStr, bool isDark) {
    String dateText = _getDateText(dateStr);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkCard.withOpacity(0.8)
              : const Color(0xFFE1F5FE).withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          dateText,
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : const Color(0xFF0277BD),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  /// Get date text (Today, Yesterday, or formatted date)
  String _getDateText(String dateStr) {
    try {
      final messageDate = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final messageDay = DateTime(
        messageDate.year,
        messageDate.month,
        messageDate.day,
      );

      if (messageDay == today) {
        return 'اليوم'; // Today
      } else if (messageDay == yesterday) {
        return 'أمس'; // Yesterday
      } else if (messageDate.isAfter(today.subtract(const Duration(days: 7)))) {
        // Show day name for messages within last week
        const days = [
          'الإثنين',
          'الثلاثاء',
          'الأربعاء',
          'الخميس',
          'الجمعة',
          'السبت',
          'الأحد'
        ];
        return days[messageDate.weekday - 1];
      } else {
        // Show formatted date for older messages
        const months = [
          'يناير',
          'فبراير',
          'مارس',
          'أبريل',
          'مايو',
          'يونيو',
          'يوليو',
          'أغسطس',
          'سبتمبر',
          'أكتوبر',
          'نوفمبر',
          'ديسمبر'
        ];
        return '${messageDate.day} ${months[messageDate.month - 1]} ${messageDate.year}';
      }
    } catch (e) {
      return '';
    }
  }
}
