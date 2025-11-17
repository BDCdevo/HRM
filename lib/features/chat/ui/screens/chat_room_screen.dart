import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/networking/dio_client.dart';
import '../../../../core/services/websocket_service.dart';
import '../../data/repo/chat_repository.dart';
import '../../data/models/message_model.dart';
import '../../logic/cubit/messages_cubit.dart';
import '../../logic/cubit/messages_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/voice_recording_widget.dart';
import 'group_info_screen.dart';

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
  final AudioRecorder _audioRecorder = AudioRecorder();
  Timer? _pollingTimer;
  int _lastMessageId = 0;
  bool _isRecording = false;
  String? _recordedFilePath;

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
    _audioRecorder.dispose();
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
        onTap: widget.isGroupChat ? _openGroupInfo : _openEmployeeProfile,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              // Avatar (Group icon or User initial)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withOpacity(0.2),
                ),
                child: Center(
                  child: widget.isGroupChat
                      ? const Icon(
                          Icons.group,
                          color: AppColors.white,
                          size: 20,
                        )
                      : Text(
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
                      widget.isGroupChat
                          ? 'Tap for group info'
                          : 'Tap to view profile',
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
            } else if (value == 'group_info') {
              _openGroupInfo();
            }
          },
          itemBuilder: (context) => widget.isGroupChat
              ? [
                  const PopupMenuItem(
                    value: 'group_info',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline),
                        SizedBox(width: 8),
                        Text('Group info'),
                      ],
                    ),
                  ),
                ]
              : [
                  const PopupMenuItem(
                    value: 'view_profile',
                    child: Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 8),
                        Text('View profile'),
                      ],
                    ),
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
    final hasText = _messageController.text.isNotEmpty;

    // Show recording widget if recording
    if (_isRecording) {
      return VoiceRecordingWidget(
        onRecordingComplete: () async {
          print('🎤 Send button pressed - stopping recording...');

          // Stop recording and get the path
          final path = await _audioRecorder.stop();

          print('🎤 Recording stopped, path: $path');

          if (path != null && path.isNotEmpty) {
            print('🎤 Path is valid, sending recording...');
            await _sendRecording(path);
          } else {
            print('❌ Path is null or empty!');
            // Try using the stored path
            if (_recordedFilePath != null) {
              print('🎤 Using stored path: $_recordedFilePath');
              await _sendRecording(_recordedFilePath!);
            }
          }
        },
        onSendRecording: (path) async {
          await _sendRecording(path);
        },
        onCancel: _cancelRecording,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Text field with emoji, attachment, and camera icons inside
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkInput : AppColors.background,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Emoji button (inside TextField)
                  IconButton(
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.emoji_emotions_outlined,
                      color: isDark
                          ? const Color(0xFF8696A0)  // WhatsApp dark gray
                          : const Color(0xFF54656F),  // WhatsApp gray
                      size: 26,
                    ),
                    onPressed: isSending ? null : () {
                      // TODO: Show emoji picker
                    },
                  ),

                  const SizedBox(width: 4),

                  // Text input
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      enabled: !isSending,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Message',
                        hintStyle: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary.withOpacity(0.6)
                              : AppColors.textSecondary.withOpacity(0.6),
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 4,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (value) {
                        setState(() {
                          // Rebuild to show/hide mic/send buttons
                        });
                      },
                    ),
                  ),

                  // Show attachment and camera only when no text
                  if (!hasText) ...[
                    // Attachment button
                    IconButton(
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                      icon: Transform.rotate(
                        angle: -0.785398, // -45 degrees in radians
                        child: Icon(
                          Icons.attach_file,
                          color: isDark
                              ? const Color(0xFF8696A0)  // WhatsApp dark gray
                              : const Color(0xFF54656F),  // WhatsApp gray
                          size: 24,
                        ),
                      ),
                      onPressed: isSending ? null : _pickFile,
                    ),

                    const SizedBox(width: 4),

                    // Camera button (using WhatsApp icon)
                    IconButton(
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                      icon: SvgPicture.asset(
                        'assets/whatsapp_icons/Camera.svg',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          isDark
                              ? const Color(0xFF8696A0)  // WhatsApp dark gray
                              : const Color(0xFF54656F),  // WhatsApp gray
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: isSending ? null : _pickImageFromCamera,
                    ),

                    const SizedBox(width: 4),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Microphone button (when no text) or Send button (when has text)
          if (!hasText)
            // Microphone button - Large circular green button
            GestureDetector(
              onTap: isSending ? null : _startRecording,
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFF25D366), // WhatsApp green
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/whatsapp_icons/mic.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            )
          else
            // Send button
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF25D366), // WhatsApp green
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
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.send, color: AppColors.white, size: 22),
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

    context.read<MessagesCubit>().sendMessage(
          conversationId: widget.conversationId,
          companyId: widget.companyId,
          attachment: file,
          attachmentType: type,
        );
  }

  /// Start Voice Recording
  Future<void> _startRecording() async {
    // Check microphone permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission denied')),
      );
      return;
    }

    try {
      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final filePath = '${tempDir.path}/$fileName';

      // Start recording
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: filePath,
      );

      setState(() {
        _isRecording = true;
        _recordedFilePath = filePath;
      });

      print('🎤 Recording started: $filePath');
    } catch (e) {
      print('❌ Error starting recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start recording: $e')),
      );
    }
  }

  /// Stop Voice Recording
  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      print('🎤 Recording stopped: $path');

      setState(() {
        _isRecording = false;
      });
    } catch (e) {
      print('❌ Error stopping recording: $e');
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
    // TODO: Navigate to employee profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${widget.participantName}\'s profile...'),
        duration: const Duration(seconds: 2),
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
