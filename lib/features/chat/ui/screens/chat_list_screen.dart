import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/widgets/error_widgets.dart';
import '../../../../core/services/websocket_service.dart';
import '../../data/repo/chat_repository.dart';
import '../../logic/cubit/chat_cubit.dart';
import '../../logic/cubit/chat_state.dart';
import '../widgets/conversation_card.dart';
import '../widgets/recent_contacts_section.dart';
import '../widgets/chat_list_skeleton.dart';
import 'employee_selection_screen.dart';
import 'chat_room_screen.dart';

/// Chat List Screen - WhatsApp Style
///
/// Displays list of conversations
class ChatListScreen extends StatelessWidget {
  final int companyId;
  final int currentUserId;

  const ChatListScreen({
    super.key,
    required this.companyId,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    // Check if ChatCubit is already provided by parent (MainNavigationScreen)
    ChatCubit? existingCubit;
    try {
      existingCubit = context.read<ChatCubit>();
    } catch (_) {
      // No existing cubit
    }

    // If cubit already exists, use it directly
    if (existingCubit != null) {
      return _ChatListView(companyId: companyId, currentUserId: currentUserId);
    }

    // Otherwise create a new one (for direct navigation)
    return BlocProvider(
      create: (context) => ChatCubit(
        ChatRepository(),
      )..fetchConversations(companyId: companyId, currentUserId: currentUserId),
      child: _ChatListView(companyId: companyId, currentUserId: currentUserId),
    );
  }
}

class _ChatListView extends StatefulWidget {
  final int companyId;
  final int currentUserId;

  const _ChatListView({required this.companyId, required this.currentUserId});

  @override
  State<_ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<_ChatListView> with WidgetsBindingObserver {
  // Key to access RecentContactsSection for refresh
  final GlobalKey<RecentContactsSectionState> _recentContactsKey = GlobalKey();

  // Auto-refresh timer for new messages (fallback)
  Timer? _refreshTimer;

  // WebSocket service for real-time updates
  final WebSocketService _websocket = WebSocketService.instance;
  String? _userChannelName;

  // Refresh interval (30 seconds - increased since we have WebSocket now)
  static const _refreshInterval = Duration(seconds: 30);

  int get companyId => widget.companyId;
  int get currentUserId => widget.currentUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupWebSocket();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _cleanupWebSocket();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Setup WebSocket listener for real-time message notifications
  Future<void> _setupWebSocket() async {
    try {
      // Initialize WebSocket connection
      await _websocket.initialize();

      // Get user channel name: user.{companyId}.{userId}
      _userChannelName = WebSocketService.getUserChannelName(
        companyId,
        currentUserId,
      );

      // Subscribe to user's private channel for notifications
      await _websocket.subscribeToPrivateChannel(
        channelName: _userChannelName!,
        onEvent: (PusherEvent event) {
          print('📨 Chat List - Received event: ${event.eventName}');

          // Handle new message notification
          if (event.eventName == 'new.message') {
            _handleNewMessageNotification(event.data);
          }
        },
      );

      print('✅ WebSocket setup complete for chat list (channel: $_userChannelName)');
    } catch (e) {
      print('❌ Failed to setup WebSocket for chat list: $e');
      // WebSocket failed, rely on polling
    }
  }

  /// Handle incoming message notification
  void _handleNewMessageNotification(String? data) {
    if (data == null) return;

    try {
      final jsonData = jsonDecode(data);
      final conversationId = jsonData['conversation_id'];
      final senderName = jsonData['sender_name'] ?? 'New message';

      print('📬 New message in conversation $conversationId from $senderName');

      // Refresh conversation list immediately
      if (mounted) {
        context.read<ChatCubit>().fetchConversations(
          companyId: companyId,
          currentUserId: currentUserId,
          silent: true,
        );
      }
    } catch (e) {
      print('❌ Error parsing message notification: $e');
    }
  }

  /// Cleanup WebSocket subscription
  Future<void> _cleanupWebSocket() async {
    if (_userChannelName != null) {
      await _websocket.unsubscribe(_userChannelName!);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh when app comes to foreground
      _refreshConversations();
      _startAutoRefresh();
    } else if (state == AppLifecycleState.paused) {
      // Stop timer when app goes to background
      _refreshTimer?.cancel();
    }
  }

  /// Start auto-refresh timer
  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      _refreshConversations();
    });
  }

  /// Refresh conversations silently (without loading indicator)
  void _refreshConversations() {
    if (mounted) {
      context.read<ChatCubit>().fetchConversations(
        companyId: companyId,
        currentUserId: currentUserId,
        silent: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1C1E2B)
          : const Color(0xFFF5F5F5), // Adaptive background
      appBar: _buildAppBar(context, isDark),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state is ChatError) {
            ErrorSnackBar.show(
              context: context,
              message: ErrorSnackBar.getArabicMessage(state.message),
              isNetworkError: ErrorSnackBar.isNetworkRelated(state.message),
              onRetry: () {
                context.read<ChatCubit>().fetchConversations(
                  companyId: companyId,
                  currentUserId: currentUserId,
                );
              },
            );
          }
        },
        builder: (context, state) {
          if (state is ChatLoading) {
            return _buildLoadingState(isDark);
          }

          if (state is ChatError) {
            return _buildErrorState(context, state.message);
          }

          if (state is ChatLoaded) {
            if (state.conversations.isEmpty) {
              return _buildEmptyState(context, isDark);
            }
            return _buildConversationsList(context, state, isDark);
          }

          if (state is ChatRefreshing) {
            return _buildConversationsList(
              context,
              ChatLoaded(state.conversations),
              isDark,
              isRefreshing: true,
            );
          }

          return _buildEmptyState(context, isDark);
        },
      ),
      floatingActionButton: _buildNewChatButton(context),
    );
  }

  /// Build App Bar
  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1C1E2B) : AppColors.primary,
      elevation: 0,
      title: Text(
        'Messages',
        style: AppTextStyles.titleLarge.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
      ),
      actions: [
        // Search button
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.white, size: 26),
          onPressed: () {
            // TODO: Navigate to search screen
          },
        ),
      ],
    );
  }

  /// Build Loading State
  Widget _buildLoadingState(bool isDark) {
    return const ChatListSkeleton();
  }

  /// Build Error State
  Widget _buildErrorState(BuildContext context, String message) {
    return CompactErrorWidget(
      message: ErrorSnackBar.getArabicMessage(message),
      onRetry: () {
        context.read<ChatCubit>().fetchConversations(
          companyId: companyId,
          currentUserId: currentUserId,
        );
      },
    );
  }

  /// Build Empty State
  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie Animation
            SizedBox(
              width: 250,
              height: 250,
              child: Lottie.asset(
                'assets/animations/welcome.json',
                fit: BoxFit.contain,
                repeat: true,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'No conversations yet',
              style: AppTextStyles.titleLarge.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Start chatting with your colleagues!\nTap the + button below to begin',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 32),

            // Call to action button
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmployeeSelectionScreen(
                      companyId: companyId,
                      currentUserId: currentUserId,
                    ),
                  ),
                );

                // Refresh conversation list when returning from new chat
                if (context.mounted) {
                  context.read<ChatCubit>().fetchConversations(
                    companyId: companyId,
                    currentUserId: currentUserId,
                  );
                }
              },
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Start New Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? AppColors.darkAccent
                    : AppColors.accent,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Conversations List
  Widget _buildConversationsList(
    BuildContext context,
    ChatLoaded state,
    bool isDark, {
    bool isRefreshing = false,
  }) {
    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: isDark ? const Color(0xFF2A2D3E) : Colors.white,
      onRefresh: () async {
        // Refresh both conversations and recent contacts
        _recentContactsKey.currentState?.refresh();
        await context.read<ChatCubit>().refreshConversations(
          companyId: companyId,
          currentUserId: currentUserId,
        );
      },
      child: CustomScrollView(
        slivers: [
          // Recent Contacts Section
          SliverToBoxAdapter(
            child: RecentContactsSection(
              key: _recentContactsKey,
              companyId: companyId,
              currentUserId: currentUserId,
              onContactTap: (userId, userName, userAvatar, isOnline) async {
                // Create or navigate to conversation with selected user
                await _createOrNavigateToConversation(
                  context,
                  userId,
                  userName,
                  userAvatar,
                  isOnline: isOnline,
                );
              },
            ),
          ),

          // Conversations List
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final conversation = state.conversations[index];
              final isFirst = index == 0;

              // Wrap first conversation card with rounded top border
              Widget conversationWidget = ConversationCard(
                conversation: conversation,
                currentUserId: currentUserId,
                index: index,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatRoomScreen(
                        conversationId: conversation.id,
                        participantName: conversation.participantName,
                        participantAvatar: conversation.participantAvatar,
                        companyId: companyId,
                        currentUserId: currentUserId,
                        isGroupChat: conversation.isGroup,
                        participantId: conversation.participantId,
                        isOnline: conversation.isOnline,
                      ),
                    ),
                  );

                  // Refresh conversation list when returning
                  if (context.mounted) {
                    context.read<ChatCubit>().fetchConversations(
                      companyId: companyId,
                      currentUserId: currentUserId,
                    );
                  }
                },
                onArchive: () {
                  _showSnackBar(context, '📦 Conversation archived', isDark);
                },
                onDelete: () {
                  _showSnackBar(context, '🗑️ Conversation deleted', isDark);
                },
                onPin: () {
                  _showSnackBar(context, '📌 Conversation pinned', isDark);
                },
              );

              // Add rounded top border with shadow to first conversation
              if (isFirst) {
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2D3E) : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    child: conversationWidget,
                  ),
                );
              }

              return conversationWidget;
            }, childCount: state.conversations.length),
          ),
        ],
      ),
    );
  }

  /// Create or Navigate to Conversation
  Future<void> _createOrNavigateToConversation(
    BuildContext context,
    int userId,
    String userName,
    String? userAvatar, {
    bool isOnline = false,
  }) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );

      // Create conversation
      final chatRepo = ChatRepository();
      final conversationId = await chatRepo.createConversation(
        companyId: companyId,
        userIds: [userId],
        type: 'private',
      );

      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      // Navigate to chat room
      if (context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomScreen(
              conversationId: conversationId,
              participantName: userName,
              participantAvatar: userAvatar,
              companyId: companyId,
              currentUserId: currentUserId,
              isGroupChat: false,
              participantId: userId,
              isOnline: isOnline,
            ),
          ),
        );

        // Refresh conversation list
        if (context.mounted) {
          context.read<ChatCubit>().fetchConversations(
            companyId: companyId,
            currentUserId: currentUserId,
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      // Show error
      if (context.mounted) {
        ErrorSnackBar.show(
          context: context,
          message: ErrorSnackBar.getArabicMessage(e.toString()),
          isNetworkError: ErrorSnackBar.isNetworkRelated(e.toString()),
        );
      }
    }
  }

  /// Show SnackBar
  void _showSnackBar(BuildContext context, String message, bool isDark) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isDark ? AppColors.darkCard : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Build New Chat Button (FAB)
  Widget _buildNewChatButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FloatingActionButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmployeeSelectionScreen(
              companyId: companyId,
              currentUserId: currentUserId,
            ),
          ),
        );

        // Refresh conversation list when returning from new chat
        if (context.mounted) {
          context.read<ChatCubit>().fetchConversations(
            companyId: companyId,
            currentUserId: currentUserId,
          );
        }
      },
      backgroundColor: isDark ? AppColors.darkAccent : AppColors.accent,
      child: const Icon(Icons.chat, color: AppColors.white),
    );
  }
}
