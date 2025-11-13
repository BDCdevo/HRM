# Chat Feature Implementation

## Overview
WhatsApp-style chat feature for the HRM application with complete UI implementation using mock data.

## Features Implemented

### 1. Chat List Screen (`chat_list_screen.dart`)
- **Description**: Main screen displaying all conversations
- **Features**:
  - WhatsApp-style app bar with "Chats" title
  - Search button (TODO: implement search functionality)
  - More options menu (New group, Settings)
  - List of conversations with unread badges
  - Floating Action Button (FAB) to start new chat
  - Empty state when no conversations exist
  - Mock data with 3 sample conversations

### 2. Chat Room Screen (`chat_room_screen.dart`)
- **Description**: Individual chat screen for messaging between users
- **Features**:
  - WhatsApp background color (#ECE5DD)
  - App bar with participant avatar, name, and online status
  - Video call and voice call buttons (TODO: implement)
  - Menu with "View profile" and "Clear chat" options
  - Message list with scrolling
  - Message input field with:
    - Emoji button (TODO: implement emoji picker)
    - Text input with multiple lines support
    - Attachment button (TODO: implement file picker)
    - Camera button (TODO: implement camera)
    - Send button (functional)
  - Mock data with 5 sample messages

### 3. Employee Selection Screen (`employee_selection_screen.dart`)
- **Description**: Screen to select an employee to start a new chat
- **Features**:
  - Search bar with live filtering
  - List of all company employees
  - Shows employee name and department
  - Empty state when no employees match search
  - Mock data with 8 sample employees
  - Navigation back to chat list (TODO: navigate to chat room)

### 4. Conversation Card Widget (`conversation_card.dart`)
- **Description**: Widget for displaying conversation item in the list
- **Features**:
  - Circular avatar (56x56) with initials fallback
  - Participant name (bold if unread)
  - Last message preview with type indicators:
    - 📷 Photo (for images)
    - 📄 File (for files)
    - 🎤 Voice message (for audio)
  - Time formatting (similar to WhatsApp):
    - "Just now" (< 1 min)
    - "5m ago" (< 1 hour)
    - "2h ago" (< 24 hours)
    - "Yesterday" (yesterday)
    - "12/25" (older)
  - Unread badge (orange circle) with count (shows "99+" if > 99)
  - WhatsApp-style border separator

### 5. Message Bubble Widget (`message_bubble.dart`)
- **Description**: Widget for displaying individual chat messages
- **Features**:
  - Color coding:
    - Green (#DCF8C6) for sent messages
    - White for received messages
  - Alignment:
    - Right-aligned for sent messages
    - Left-aligned for received messages
  - Message content with time display
  - Read receipts:
    - ✓✓ (blue) for read messages
    - ✓ (gray) for delivered messages
  - Support for different message types:
    - Text messages (default)
    - Images (TODO: implement image display)
    - Files (TODO: implement file display)
    - Voice messages (TODO: implement audio player)
  - WhatsApp-style rounded corners with tail

## Data Models

### 1. MessageModel (`message_model.dart`)
```dart
class MessageModel {
  final int id;
  final int conversationId;
  final int senderId;
  final String senderName;
  final String? senderAvatar;
  final String message;
  final String messageType; // 'text', 'image', 'file', 'voice'
  final bool isRead;
  final String createdAt;
  final String updatedAt;

  // Helper methods
  bool isSentByMe(int currentUserId);
  String get formattedTime; // "10:30 AM"
  String get formattedDate; // "Today", "Yesterday", "12/25/2024"
}
```

### 2. ConversationModel (`conversation_model.dart`)
```dart
class ConversationModel {
  final int id;
  final int participantId;
  final String participantName;
  final String? participantAvatar;
  final String? participantDepartment;
  final MessageModel? lastMessage;
  final int unreadCount;
  final String updatedAt;

  // Helper getters
  bool get hasUnreadMessages;
  String get formattedTime; // "Just now", "5m ago", "Yesterday"
  String get lastMessagePreview; // Message text or emoji for media
}
```

## Color Scheme

### ✅ Full Dark Mode & Light Mode Support

All chat screens now support both Light and Dark modes automatically based on system/app theme settings.

### Light Mode Colors
- **Background**: `#F5F7FA` (light blue-gray)
- **Cards**: `#FFFFFF` (white)
- **Primary**: `#6B7FA8` (warm blue)
- **Accent**: `#7FA89A` (warm teal)
- **Text Primary**: `#1F2937` (very dark)
- **Text Secondary**: `#374151` (dark gray)
- **Border**: `#E2E8F0` (light gray)

### Dark Mode Colors
- **Background**: `#1A1A1A` (pure dark black)
- **Cards**: `#2D2D2D` (dark gray)
- **AppBar**: `#1F1F1F` (darker black)
- **Input Fields**: `#2D2D2D` (dark gray)
- **Primary**: `#8FA3C4` (light blue)
- **Accent**: `#4CAF50` (green - for badges/success)
- **Text Primary**: `#FFFFFF` (pure white)
- **Text Secondary**: `#D1D5DB` (brighter gray)
- **Border**: `#4B5563` (lighter gray)

### WhatsApp-Specific Colors
- **Chat Background (Light)**: `#ECE5DD` (WhatsApp beige)
- **Chat Background (Dark)**: `#1A1A1A` (dark background)
- **Sent Message (Light)**: `#DCF8C6` (light green)
- **Sent Message (Dark)**: `#005C4B` (darker green)
- **Received Message (Light)**: `#FFFFFF` (white)
- **Received Message (Dark)**: `#2D2D2D` (dark card)
- **WhatsApp Green**: `#25D366` (for chat icon in dashboard)
- **Read Receipt**: `#34B7F1` (blue for checkmarks)

See `CHAT_DARK_MODE_SUPPORT.md` for detailed dark mode implementation.

## Navigation Flow

```
Dashboard
  └─> Chat Icon (services grid)
      └─> Chat List Screen
          ├─> Conversation Card → Chat Room Screen
          └─> FAB → Employee Selection Screen → (TODO: Chat Room Screen)
```

## Integration Points

### Dashboard Integration
- Added Chat icon to `services_grid_widget.dart`
- Replaced "Claims" card with "Chat" card
- Used WhatsApp green color (#25D366)
- Navigation: `Navigator.push(context, MaterialPageRoute(builder: (context) => ChatListScreen()))`

## Mock Data

### Conversations (3 samples)
1. **Ahmed Abbas** (Development)
   - Last message: "Hey! How are you?"
   - Unread: 2 messages
   - Time: 5 minutes ago

2. **Mohamed Ali** (HR)
   - Last message: "Thanks for your help!"
   - Unread: 0 messages
   - Time: 2 hours ago

3. **Sara Ahmed** (Sales)
   - Last message: "Can we meet tomorrow?"
   - Unread: 1 message
   - Time: 1 day ago

### Messages (5 samples per conversation)
- Mix of sent and received messages
- Time-based ordering (oldest to newest)
- Read/unread status variation

### Employees (8 samples)
- Ahmed Abbas (Development)
- Ibrahim Abusham (Development)
- Mohamed Ali (HR)
- Sara Ahmed (Sales)
- Omar Hassan (Marketing)
- Fatma Mahmoud (Finance)
- Ali Said (Operations)
- Nour Khaled (Customer Service)

## TODO: Backend Integration

### 1. Create Repository (`chat_repo.dart`)
```dart
class ChatRepo {
  final _dioClient = DioClient.getInstance();

  // Fetch conversations
  Future<List<ConversationModel>> fetchConversations() async {
    final response = await _dioClient.get('${ApiConfig.baseUrl}/conversations');
    // Parse and return
  }

  // Fetch messages for conversation
  Future<List<MessageModel>> fetchMessages(int conversationId) async {
    final response = await _dioClient.get('${ApiConfig.baseUrl}/conversations/$conversationId/messages');
    // Parse and return
  }

  // Send message
  Future<MessageModel> sendMessage(int conversationId, String message, String type) async {
    final response = await _dioClient.post('${ApiConfig.baseUrl}/messages', data: {
      'conversation_id': conversationId,
      'message': message,
      'message_type': type,
    });
    // Parse and return
  }

  // Mark messages as read
  Future<void> markAsRead(int conversationId) async {
    await _dioClient.put('${ApiConfig.baseUrl}/conversations/$conversationId/read');
  }

  // Fetch employees
  Future<List<EmployeeModel>> fetchEmployees() async {
    final response = await _dioClient.get('${ApiConfig.baseUrl}/employees');
    // Parse and return
  }

  // Start conversation
  Future<ConversationModel> startConversation(int employeeId) async {
    final response = await _dioClient.post('${ApiConfig.baseUrl}/conversations', data: {
      'participant_id': employeeId,
    });
    // Parse and return
  }
}
```

### 2. Create Cubit (`chat_cubit.dart` and `chat_state.dart`)
```dart
// States
abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ConversationsLoaded extends ChatState {
  final List<ConversationModel> conversations;
  const ConversationsLoaded(this.conversations);
  @override
  List<Object?> get props => [conversations];
}

class MessagesLoaded extends ChatState {
  final List<MessageModel> messages;
  const MessagesLoaded(this.messages);
  @override
  List<Object?> get props => [messages];
}

class MessageSent extends ChatState {
  final MessageModel message;
  const MessageSent(this.message);
  @override
  List<Object?> get props => [message];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class ChatCubit extends Cubit<ChatState> {
  final ChatRepo _repo;

  ChatCubit(this._repo) : super(ChatInitial());

  Future<void> fetchConversations() async {
    emit(ChatLoading());
    try {
      final conversations = await _repo.fetchConversations();
      emit(ConversationsLoaded(conversations));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> fetchMessages(int conversationId) async {
    emit(ChatLoading());
    try {
      final messages = await _repo.fetchMessages(conversationId);
      emit(MessagesLoaded(messages));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> sendMessage(int conversationId, String message, String type) async {
    try {
      final sentMessage = await _repo.sendMessage(conversationId, message, type);
      emit(MessageSent(sentMessage));
      // Refresh messages
      await fetchMessages(conversationId);
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> markAsRead(int conversationId) async {
    try {
      await _repo.markAsRead(conversationId);
    } catch (e) {
      // Silent fail or log
    }
  }
}
```

### 3. Update UI Screens to Use BLoC

Replace mock data calls with `BlocBuilder`:

```dart
// In chat_list_screen.dart
BlocBuilder<ChatCubit, ChatState>(
  builder: (context, state) {
    if (state is ChatLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (state is ConversationsLoaded) {
      return ListView.builder(
        itemCount: state.conversations.length,
        itemBuilder: (context, index) {
          final conversation = state.conversations[index];
          return ConversationCard(...);
        },
      );
    }
    if (state is ChatError) {
      return Center(child: Text(state.message));
    }
    return _buildEmptyState();
  },
)
```

### 4. Backend API Endpoints Required

#### Conversations
- `GET /api/v1/conversations` - List all conversations for current user
- `POST /api/v1/conversations` - Start new conversation with employee
- `GET /api/v1/conversations/{id}/messages` - Get messages for conversation
- `PUT /api/v1/conversations/{id}/read` - Mark conversation as read
- `DELETE /api/v1/conversations/{id}` - Delete/clear conversation

#### Messages
- `POST /api/v1/messages` - Send new message
- `PUT /api/v1/messages/{id}` - Edit message (optional)
- `DELETE /api/v1/messages/{id}` - Delete message (optional)

#### Employees
- `GET /api/v1/employees` - List all employees (for starting chat)

### 5. Real-time Updates (Optional)

Consider implementing real-time messaging using:
- **Laravel WebSockets** with Pusher
- **Socket.io**
- **Firebase Cloud Messaging**

This would enable:
- Instant message delivery
- Typing indicators
- Online status
- Read receipts in real-time

## Testing Checklist

### UI Testing (✅ Completed)
- [x] Chat icon appears in dashboard
- [x] Chat list screen displays with mock data
- [x] Conversation cards show correctly (avatar, name, message, time, badge)
- [x] FAB opens employee selection screen
- [x] Employee selection has search functionality
- [x] Clicking conversation opens chat room
- [x] Chat room displays messages correctly
- [x] Message bubbles have correct colors and alignment
- [x] Message input field works
- [x] Empty states display correctly

### Backend Integration Testing (TODO)
- [ ] Fetch conversations from API
- [ ] Display real conversation data
- [ ] Send message to API
- [ ] Receive message from API
- [ ] Mark messages as read
- [ ] Start new conversation
- [ ] Search employees
- [ ] Handle errors gracefully
- [ ] Upload images/files
- [ ] Send voice messages

### Real-time Testing (TODO)
- [ ] Receive messages in real-time
- [ ] Typing indicator
- [ ] Online status updates
- [ ] Read receipts update in real-time
- [ ] Push notifications

## Files Created

```
lib/features/chat/
├── data/
│   ├── models/
│   │   ├── message_model.dart
│   │   ├── message_model.g.dart (generated)
│   │   ├── conversation_model.dart
│   │   └── conversation_model.g.dart (generated)
│   └── repo/
│       └── (TODO: chat_repo.dart)
├── logic/
│   └── cubit/
│       ├── (TODO: chat_cubit.dart)
│       └── (TODO: chat_state.dart)
└── ui/
    ├── screens/
    │   ├── chat_list_screen.dart
    │   ├── chat_room_screen.dart
    │   └── employee_selection_screen.dart
    └── widgets/
        ├── conversation_card.dart
        └── message_bubble.dart
```

## Files Modified

- `lib/features/dashboard/ui/widgets/services_grid_widget.dart` - Added Chat icon

## Dependencies Used

- `flutter_bloc` - State management (for future BLoC integration)
- `equatable` - Value equality (for future state classes)
- `cached_network_image` - Avatar image caching
- `intl` - Date/time formatting
- `json_annotation` + `json_serializable` - JSON serialization for models

## Next Steps

1. **Backend Development**:
   - Create database migrations for `conversations` and `messages` tables
   - Implement API endpoints in Laravel backend
   - Add proper authentication and authorization

2. **State Management**:
   - Create `ChatRepo` for API calls
   - Implement `ChatCubit` and `ChatState`
   - Update UI screens to use BlocBuilder

3. **Feature Enhancements**:
   - Implement search functionality in chat list
   - Add image/file upload
   - Implement voice message recording
   - Add emoji picker
   - Implement typing indicator
   - Add online status detection

4. **Real-time**:
   - Set up Laravel WebSockets or Socket.io
   - Implement real-time message delivery
   - Add push notifications

5. **Testing**:
   - Write unit tests for models and repos
   - Write widget tests for UI components
   - Write integration tests for complete flows

## Screenshots Location

No screenshots currently available. Once the app is running, take screenshots of:
- Chat list screen (with conversations)
- Chat list screen (empty state)
- Chat room screen
- Employee selection screen
- Message bubbles (sent and received)

## Notes

- All UI is complete and tested with mock data
- Design follows WhatsApp style as requested
- Colors match the app's theme (primary #2D3142, accent #EF8354)
- Current user ID is hardcoded as `34` in mock data
- All timestamps use ISO 8601 format for future API compatibility
- JSON serialization is configured and generated for all models
