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
import '../widgets/chat_app_bar_widget.dart';
import '../widgets/chat_messages_list_widget.dart';
import '../widgets/chat_input_bar_widget.dart';
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
  final FocusNode _messageFocusNode = FocusNode();
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
    _messageFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
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
          ? const Color(0xFF0B141A) // WhatsApp dark background
          : const Color(0xFFECE5DD), // WhatsApp light background
      appBar: ChatAppBarWidget(
        participantName: widget.participantName,
        participantAvatar: widget.participantAvatar,
        isGroupChat: widget.isGroupChat,
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
                child: ChatMessagesListWidget(
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
                ),
              ),

              // Message Input
              ChatInputBarWidget(
                messageController: _messageController,
                messageFocusNode: _messageFocusNode,
                isSending: state is MessageSending,
                isRecording: _isRecording,
                isDark: isDark,
                onSendMessage: _sendMessage,
                onPickImage: _pickImageFromCamera,
                onPickFile: _pickFile,
                onStartRecording: _startRecording,
                onStopRecording: _stopRecording,
                onSendRecording: _sendRecording,
                onCancelRecording: _cancelRecording,
              ),
            ],
          );
        },
        ),
      ),
    );
  }

  /// Send Message
  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Clear text immediately for better UX
    _messageController.clear();

    context.read<MessagesCubit>().sendMessage(
          conversationId: widget.conversationId,
          companyId: widget.companyId,
          message: message,
        );

    // Keep keyboard open by requesting focus
    _messageFocusNode.requestFocus();

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
