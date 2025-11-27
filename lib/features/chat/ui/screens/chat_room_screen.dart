import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/networking/dio_client.dart';
import '../../../../core/services/websocket_service.dart';
import '../../../../core/widgets/error_widgets.dart';
import '../../data/repo/chat_repository.dart';
import '../../data/models/message_model.dart';
import '../../logic/cubit/messages_cubit.dart';
import '../../logic/cubit/messages_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/voice_recording_widget.dart';
import '../widgets/chat_app_bar_widget.dart';
import '../widgets/chat_messages_list_widget.dart';
import '../widgets/chat_input_bar_widget.dart';
import 'group_info_screen.dart';
import 'chat_user_profile_screen.dart';

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
  final int? participantId; // Other user's ID (for profile)
  final bool isOnline; // Online status of participant

  const ChatRoomScreen({
    super.key,
    required this.conversationId,
    required this.participantName,
    this.participantAvatar,
    required this.companyId,
    required this.currentUserId,
    this.isGroupChat = false,
    this.participantId,
    this.isOnline = false,
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
        participantId: participantId,
        isOnline: isOnline,
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
  final int? participantId;
  final bool isOnline;

  const _ChatRoomView({
    required this.conversationId,
    required this.participantName,
    this.participantAvatar,
    required this.companyId,
    required this.currentUserId,
    this.isGroupChat = false,
    this.participantId,
    this.isOnline = false,
  });

  @override
  State<_ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<_ChatRoomView> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  final WebSocketService _websocket = WebSocketService.instance;
  final AudioRecorder _audioRecorder = AudioRecorder();
  final ChatRepository _chatRepository = ChatRepository();
  Timer? _pollingTimer;
  int _lastMessageId = 0;
  bool _isRecording = false;
  String? _recordedFilePath;

  // Typing indicator state
  Timer? _typingTimer;
  bool _isTyping = false;
  bool _otherUserIsTyping = false;
  String? _typingUserName;

  // Emoji picker state
  bool _isEmojiPickerVisible = false;

  // Reply to message state
  MessageModel? _replyToMessage;

  @override
  void initState() {
    super.initState();
    _setupWebSocket();
    // Start polling as fallback for real-time updates
    _startPolling();
    // Listen to text changes for typing indicator
    _messageController.addListener(_onTextChanged);
    // Listen to focus changes to hide emoji picker when keyboard shows
    _messageFocusNode.addListener(_onFocusChanged);
  }

  /// Handle focus changes - hide emoji picker when text field is focused
  void _onFocusChanged() {
    if (_messageFocusNode.hasFocus && _isEmojiPickerVisible) {
      setState(() {
        _isEmojiPickerVisible = false;
      });
    }
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
          print('📨 Received event: ${event.eventName}');

          // Handle incoming message
          if (event.eventName == 'message.sent') {
            _handleIncomingMessage(event.data);
          }

          // Handle typing indicator
          if (event.eventName == 'user.typing') {
            _handleTypingEvent(event.data);
          }

          // Handle message deleted
          if (event.eventName == 'message.deleted') {
            _handleMessageDeleted(event.data);
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

      // Add message to cubit (which will update UI and cache)
      context.read<MessagesCubit>().addOptimisticMessage(
        message,
        conversationId: widget.conversationId,
      );

      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);

      print('✅ Real-time message added to chat');
    } catch (e) {
      print('❌ Failed to handle incoming message: $e');
    }
  }

  /// Start polling for new messages (fallback for WebSocket)
  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // Check if widget is still mounted before refreshing
      if (!mounted) {
        timer.cancel();
        return;
      }

      // Refresh messages every 5 seconds (optimized for better performance)
      context.read<MessagesCubit>().refreshMessages(
        conversationId: widget.conversationId,
        companyId: widget.companyId,
      );
    });
    print('✅ Polling started (checking for new messages every 5 seconds)');
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _typingTimer?.cancel();
    _audioRecorder.dispose();
    // Send stop typing before leaving
    if (_isTyping) {
      _sendTypingIndicator(false);
    }
    // Unsubscribe from channel
    final channelName = WebSocketService.getChatChannelName(
      widget.companyId,
      widget.conversationId,
    );
    _websocket.unsubscribe(channelName);

    _messageController.removeListener(_onTextChanged);
    _messageFocusNode.removeListener(_onFocusChanged);
    _messageController.dispose();
    _messageFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Handle text changes for typing indicator
  void _onTextChanged() {
    final hasText = _messageController.text.isNotEmpty;

    if (hasText && !_isTyping) {
      // Start typing
      _isTyping = true;
      _sendTypingIndicator(true);
    }

    // Reset the timer on each keystroke
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      // Stop typing after 2 seconds of inactivity
      if (_isTyping) {
        _isTyping = false;
        _sendTypingIndicator(false);
      }
    });
  }

  /// Send typing indicator to server
  void _sendTypingIndicator(bool isTyping) {
    _chatRepository.sendTypingIndicator(
      conversationId: widget.conversationId,
      companyId: widget.companyId,
      isTyping: isTyping,
    );
  }

  /// Handle incoming typing event from WebSocket
  void _handleTypingEvent(dynamic data) {
    try {
      final typingData = data is String ? {} : (data as Map<String, dynamic>);
      final userId = typingData['user_id'];
      final userName = typingData['user_name'] ?? 'Someone';
      final isTyping = typingData['is_typing'] ?? false;

      // Ignore own typing events
      if (userId == widget.currentUserId) return;

      if (mounted) {
        setState(() {
          _otherUserIsTyping = isTyping;
          _typingUserName = isTyping ? userName : null;
        });
      }

      print('⌨️ ${isTyping ? "$userName is typing..." : "$userName stopped typing"}');
    } catch (e) {
      print('❌ Error handling typing event: $e');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // With reverse: true, position 0 is the bottom (latest messages)
      _scrollController.animateTo(
        0,
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
          ? AppColors.darkChatBackground
          : AppColors.chatBackground,
      appBar: ChatAppBarWidget(
        participantName: widget.participantName,
        participantAvatar: widget.participantAvatar,
        isGroupChat: widget.isGroupChat,
        isOnline: widget.isOnline,
        isDark: isDark,
        onTap: widget.isGroupChat ? _openGroupInfo : _openEmployeeProfile,
      ),
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
            ErrorSnackBar.show(
              context: context,
              message: ErrorSnackBar.getArabicMessage(state.message),
              isNetworkError: ErrorSnackBar.isNetworkRelated(state.message),
            );
          }

          if (state is MessagesError) {
            ErrorSnackBar.show(
              context: context,
              message: ErrorSnackBar.getArabicMessage(state.message),
              isNetworkError: ErrorSnackBar.isNetworkRelated(state.message),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Messages List with Gradient Overlay
              Expanded(
                child: Stack(
                  children: [
                    // Messages List
                    ChatMessagesListWidget(
                      state: state,
                      scrollController: _scrollController,
                      isDark: isDark,
                      conversationId: widget.conversationId,
                      companyId: widget.companyId,
                      isGroupChat: widget.isGroupChat,
                      onRefresh: () => context.read<MessagesCubit>().refreshMessages(
                        conversationId: widget.conversationId,
                        companyId: widget.companyId,
                      ),
                      onReply: _setReplyToMessage,
                      onDelete: _deleteMessage,
                    ),

                    // Top Gradient Overlay
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                isDark
                                    ? AppColors.darkChatBackground
                                    : AppColors.chatBackground,
                                isDark
                                    ? AppColors.darkChatBackground.withValues(alpha: 0.0)
                                    : AppColors.chatBackground.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Typing Indicator
              if (_otherUserIsTyping)
                _buildTypingIndicator(isDark),

              // Message Input
              ChatInputBarWidget(
                messageController: _messageController,
                messageFocusNode: _messageFocusNode,
                isSending: state is MessageSending,
                isRecording: _isRecording,
                isEmojiPickerVisible: _isEmojiPickerVisible,
                isDark: isDark,
                onSendMessage: _sendMessage,
                onPickImage: _pickImageFromCamera,
                onPickFile: _pickFile,
                onStartRecording: _startRecording,
                onStopRecording: _stopRecording,
                onSendRecording: _sendRecording,
                onCancelRecording: _cancelRecording,
                onEmojiToggle: _toggleEmojiPicker,
                replyToMessage: _replyToMessage,
                onCancelReply: _cancelReply,
              ),

              // Emoji Picker - shows below input bar (replaces keyboard)
              if (_isEmojiPickerVisible)
                _buildEmojiPicker(isDark),
            ],
          );
        },
        ),
      ),
    );
  }

  /// Set reply to message (called from swipe gesture)
  void _setReplyToMessage(MessageModel message) {
    setState(() {
      _replyToMessage = message;
    });
    // Focus on text field after selecting reply
    _messageFocusNode.requestFocus();
  }

  /// Cancel reply
  void _cancelReply() {
    setState(() {
      _replyToMessage = null;
    });
  }

  /// Delete message
  void _deleteMessage(MessageModel message) {
    context.read<MessagesCubit>().deleteMessage(
      conversationId: widget.conversationId,
      companyId: widget.companyId,
      messageId: message.id,
    );
  }

  /// Handle message deleted event from WebSocket
  void _handleMessageDeleted(dynamic data) {
    try {
      print('🗑️ Received message.deleted event: $data');

      final messageData = data is Map ? data : {};
      final messageId = messageData['message_id'] as int?;

      if (messageId != null && mounted) {
        // Remove message from cubit
        context.read<MessagesCubit>().removeMessageById(messageId);
        print('✅ Message $messageId removed from UI');
      }
    } catch (e) {
      print('❌ Error handling message deleted: $e');
    }
  }

  /// Toggle emoji picker visibility
  void _toggleEmojiPicker() {
    if (_isEmojiPickerVisible) {
      // Hide emoji picker and show keyboard
      setState(() {
        _isEmojiPickerVisible = false;
      });
      _messageFocusNode.requestFocus();
    } else {
      // Hide keyboard and show emoji picker
      _messageFocusNode.unfocus();
      setState(() {
        _isEmojiPickerVisible = true;
      });
    }
  }

  /// Build Emoji Picker Widget
  Widget _buildEmojiPicker(bool isDark) {
    return SizedBox(
      height: 280,
      child: EmojiPicker(
        textEditingController: _messageController,
        onEmojiSelected: (category, emoji) {
          // Emoji is automatically added to text controller
        },
        onBackspacePressed: () {
          // Handle backspace in emoji picker
          final text = _messageController.text;
          if (text.isNotEmpty) {
            // Remove last character (handles emoji which may be multiple code units)
            final characters = text.characters;
            _messageController.text = characters.skipLast(1).string;
            _messageController.selection = TextSelection.fromPosition(
              TextPosition(offset: _messageController.text.length),
            );
          }
        },
        config: Config(
          height: 280,
          // Disable platform check for faster loading
          checkPlatformCompatibility: false,
          emojiViewConfig: EmojiViewConfig(
            columns: 8,
            emojiSizeMax: 32.0 * (Platform.isIOS ? 1.30 : 1.0),
            verticalSpacing: 0,
            horizontalSpacing: 0,
            gridPadding: EdgeInsets.zero,
            backgroundColor: isDark ? AppColors.darkChatInputBackground : AppColors.surface,
            loadingIndicator: const SizedBox.shrink(),
            noRecents: Text(
              'No recent emojis',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ),
          skinToneConfig: const SkinToneConfig(enabled: false),
          categoryViewConfig: CategoryViewConfig(
            initCategory: Category.SMILEYS,
            backgroundColor: isDark ? AppColors.darkChatInputBackground : AppColors.surface,
            indicatorColor: isDark ? AppColors.darkAccent : AppColors.accent,
            iconColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            iconColorSelected: isDark ? AppColors.darkAccent : AppColors.accent,
            categoryIcons: const CategoryIcons(),
          ),
          bottomActionBarConfig: const BottomActionBarConfig(
            enabled: false,
          ),
          searchViewConfig: SearchViewConfig(
            backgroundColor: isDark ? AppColors.darkChatInputBackground : AppColors.surface,
            buttonIconColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            hintText: 'Search for emoji...',
          ),
        ),
      ),
    );
  }

  /// Build Typing Indicator Widget
  Widget _buildTypingIndicator(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Avatar placeholder
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.border,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: 18,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          // Typing bubble
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkChatInputBackground : AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated dots
                _TypingDotsAnimation(isDark: isDark),
                const SizedBox(width: 8),
                Text(
                  widget.isGroupChat
                      ? '${_typingUserName ?? 'Someone'} is typing...'
                      : 'typing...',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
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

    // Clear text immediately for better UX
    _messageController.clear();

    // Get reply message ID if replying
    final replyId = _replyToMessage?.id;

    // Clear reply state
    if (_replyToMessage != null) {
      setState(() {
        _replyToMessage = null;
      });
    }

    // Send the message
    context.read<MessagesCubit>().sendMessage(
          conversationId: widget.conversationId,
          companyId: widget.companyId,
          message: message,
          replyToMessageId: replyId,
        );

    // Keep keyboard open - use WidgetsBinding to ensure focus after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _messageFocusNode.requestFocus();
      }
    });

    // Scroll to bottom after sending
    _scrollToBottom();
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

  /// Pick File (Image/Document/PDF/etc)
  Future<void> _pickFile() async {
    try {
      print('📎 Opening file picker...');

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        final fileSize = await file.length();

        print('📎 File picked:');
        print('   Name: $fileName');
        print('   Path: ${file.path}');
        print('   Size: $fileSize bytes');

        _sendFileMessage(file);
      } else {
        print('📎 No file selected');
      }
    } catch (e, stackTrace) {
      print('❌ Error picking file: $e');
      print('❌ Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Send File Message
  void _sendFileMessage(File file, {String? attachmentType}) {
    // Auto-detect attachment type if not provided
    String type = attachmentType ?? 'file';
    if (attachmentType == null) {
      final extension = file.path.split('.').last.toLowerCase();
      if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
        type = 'image';
      } else if (['m4a', 'mp3', 'wav', 'aac', 'ogg'].contains(extension)) {
        type = 'voice';
      }
    }

    print('📎 Sending file with type: $type');
    print('📎 File path: ${file.path}');
    print('📎 Conversation ID: ${widget.conversationId}');
    print('📎 Company ID: ${widget.companyId}');

    context.read<MessagesCubit>().sendMessage(
          conversationId: widget.conversationId,
          companyId: widget.companyId,
          attachment: file,
          attachmentType: type,
        );

    print('📎 sendMessage() called successfully');
  }

  /// Start Voice Recording
  Future<void> _startRecording() async {
    print('🎤 Starting recording process...');

    // Check microphone permission
    final status = await Permission.microphone.request();
    print('🎤 Microphone permission status: ${status.isGranted}');

    if (!status.isGranted) {
      print('❌ Microphone permission denied');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission denied')),
      );
      return;
    }

    try {
      // Check if recorder is available
      final hasPermission = await _audioRecorder.hasPermission();
      print('🎤 Audio recorder has permission: $hasPermission');

      if (!hasPermission) {
        print('❌ Audio recorder reports no permission');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone access denied by audio recorder')),
        );
        return;
      }

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final filePath = '${tempDir.path}/$fileName';
      print('🎤 Recording file path: $filePath');

      // Start recording with Android-compatible settings
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,  // AAC-LC is widely supported
          bitRate: 128000,               // 128 kbps
          sampleRate: 44100,             // CD quality
          numChannels: 1,                // Mono (better for voice)
        ),
        path: filePath,
      );

      setState(() {
        _isRecording = true;
        _recordedFilePath = filePath;
      });

      print('✅ Recording started successfully: $filePath');
    } catch (e, stackTrace) {
      print('❌ Error starting recording: $e');
      print('❌ Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start recording: $e')),
      );
    }
  }

  /// Stop Voice Recording
  Future<void> _stopRecording() async {
    try {
      print('🎤 Stopping recording...');
      final path = await _audioRecorder.stop();
      print('🎤 Recording stopped, path returned: $path');

      // Verify the file exists and get its size
      if (path != null && path.isNotEmpty) {
        final file = File(path);
        final exists = await file.exists();
        final size = exists ? await file.length() : 0;
        print('🎤 File exists: $exists, Size: $size bytes');

        if (size == 0) {
          print('⚠️ WARNING: Recording file is empty (0 bytes)!');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recording failed: File is empty. Microphone may not be working.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
          setState(() {
            _isRecording = false;
          });
        } else {
          // File is valid - send it immediately
          setState(() {
            _isRecording = false;
          });

          print('🎤 Sending voice message automatically...');
          await _sendRecording(path);
        }
      } else {
        print('⚠️ WARNING: No path returned from recorder.stop()');
        setState(() {
          _isRecording = false;
        });
      }
    } catch (e, stackTrace) {
      print('❌ Error stopping recording: $e');
      print('❌ Stack trace: $stackTrace');
      setState(() {
        _isRecording = false;
      });
    }
  }

  /// Cancel Voice Recording
  Future<void> _cancelRecording() async {
    try {
      await _audioRecorder.stop();

      // Delete the recorded file
      if (_recordedFilePath != null) {
        final file = File(_recordedFilePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      setState(() {
        _isRecording = false;
        _recordedFilePath = null;
      });

      print('🎤 Recording canceled');
    } catch (e) {
      print('❌ Error canceling recording: $e');
    }
  }

  /// Send Voice Recording
  Future<void> _sendRecording(String path) async {
    try {
      print('🎤 Attempting to send recording: $path');

      final file = File(path);
      final exists = await file.exists();

      print('🎤 File exists: $exists');

      if (exists) {
        final fileSize = await file.length();
        print('🎤 File size: ${fileSize} bytes');

        _sendFileMessage(file);
        print('🎤 Recording sent successfully');
      } else {
        print('❌ Recording file does not exist: $path');
      }

      setState(() {
        _isRecording = false;
        _recordedFilePath = null;
      });
    } catch (e) {
      print('❌ Error sending recording: $e');
      setState(() {
        _isRecording = false;
        _recordedFilePath = null;
      });
    }
  }

  /// Open Employee Profile
  void _openEmployeeProfile() {
    if (widget.participantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User profile not available'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Navigate to user profile screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatUserProfileScreen(
          userId: widget.participantId!,
          userName: widget.participantName,
          userAvatar: widget.participantAvatar,
        ),
      ),
    );
  }

  /// Open Group Info Screen
  void _openGroupInfo() {
    if (!widget.isGroupChat) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupInfoScreen(
          conversationId: widget.conversationId,
          groupName: widget.participantName,
          groupAvatar: widget.participantAvatar,
          participantsCount: 3, // TODO: Get actual count from conversation data
          companyId: widget.companyId,
          currentUserId: widget.currentUserId,
        ),
      ),
    );
  }

  /// Check if date separator should be shown
  bool _shouldShowDateSeparator(String previousDateStr, String currentDateStr) {
    try {
      final previousDate = DateTime.parse(previousDateStr).toLocal();
      final currentDate = DateTime.parse(currentDateStr).toLocal();

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
              : AppColors.infoLight.withOpacity(0.5),
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
                : AppColors.primaryDark,
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
      final messageDate = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final messageDay = DateTime(
        messageDate.year,
        messageDate.month,
        messageDate.day,
      );

      if (messageDay == today) {
        return 'Today';
      } else if (messageDay == yesterday) {
        return 'Yesterday';
      } else if (messageDate.isAfter(today.subtract(const Duration(days: 7)))) {
        // Show day name for messages within last week
        const days = [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday'
        ];
        return days[messageDate.weekday - 1];
      } else {
        // Show formatted date for older messages
        const months = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December'
        ];
        return '${months[messageDate.month - 1]} ${messageDate.day}, ${messageDate.year}';
      }
    } catch (e) {
      return '';
    }
  }
}

/// Animated typing dots widget
class _TypingDotsAnimation extends StatefulWidget {
  final bool isDark;

  const _TypingDotsAnimation({required this.isDark});

  @override
  State<_TypingDotsAnimation> createState() => _TypingDotsAnimationState();
}

class _TypingDotsAnimationState extends State<_TypingDotsAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _animations = List.generate(3, (index) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.2,
            0.6 + index * 0.2,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: Transform.translate(
                offset: Offset(0, -4 * _animations[index].value),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: widget.isDark
                        ? AppColors.darkTextSecondary.withValues(
                            alpha: 0.5 + 0.5 * _animations[index].value)
                        : AppColors.textSecondary.withValues(
                            alpha: 0.5 + 0.5 * _animations[index].value),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
