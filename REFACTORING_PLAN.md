# Chat Room Screen Refactoring Plan

## Current Status
- **File**: `chat_room_screen.dart`
- **Lines**: 1100 lines
- **Issue**: Too large, hard to maintain

## Refactoring Strategy

### Split into 4 widgets:

#### 1. `chat_app_bar_widget.dart` (AppBar section)
**Responsibilities**:
- Display participant name and avatar
- Show online status (if needed)
- Group info button
- Back button

**Props**:
- `participantName`: String
- `participantAvatar`: String?
- `isGroupChat`: bool
- `onGroupInfoTap`: VoidCallback?

---

#### 2. `chat_messages_list_widget.dart` (Messages list)
**Responsibilities**:
- Display list of messages
- Handle scroll controller
- Show loading/error states
- Auto-scroll to bottom on new message

**Props**:
- `messages`: List<MessageModel>
- `currentUserId`: int
- `isGroupChat`: bool
- `scrollController`: ScrollController
- `isLoading`: bool
- `error`: String?

---

#### 3. `chat_input_bar_widget.dart` (Input section)
**Responsibilities**:
- Text input field
- Send button
- Attachment buttons (camera, file, voice)
- Voice recording UI

**Props**:
- `messageController`: TextEditingController
- `onSendMessage`: Function(String message)
- `onPickImage`: VoidCallback
- `onPickFile`: VoidCallback
- `onStartRecording`: VoidCallback
- `onStopRecording`: VoidCallback
- `isRecording`: bool

---

#### 4. `chat_room_screen.dart` (Main coordinator)
**Responsibilities**:
- Provide BLoC
- Coordinate between widgets
- Handle business logic (sending, recording, etc.)
- Manage state
- WebSocket connection

**Reduced to**: ~300-400 lines

---

## Implementation Order

1. ✅ Create `chat_app_bar_widget.dart`
2. ✅ Create `chat_messages_list_widget.dart`
3. ✅ Create `chat_input_bar_widget.dart`
4. ✅ Update `chat_room_screen.dart` to use new widgets
5. ✅ Test functionality
6. ✅ Commit changes

---

## Benefits

- ✅ **Better maintainability**: Each widget has single responsibility
- ✅ **Reusability**: Widgets can be reused in other chat screens
- ✅ **Easier testing**: Test each widget independently
- ✅ **Cleaner code**: Easier to understand and modify
- ✅ **Follow best practices**: Aligns with Clean Architecture

---

## Next Screens to Refactor

After chat_room_screen.dart, refactor these large screens:

1. **attendance** screens (if > 500 lines)
2. **leaves** screens (if > 500 lines)
3. **dashboard_screen** (if > 500 lines)
4. **profile_screen** (if > 500 lines)

---

## Code Quality Metrics

### Before Refactoring:
- chat_room_screen.dart: **1100 lines** ❌

### After Refactoring (Target):
- chat_room_screen.dart: **300-400 lines** ✅
- chat_app_bar_widget.dart: **~80 lines**
- chat_messages_list_widget.dart: **~150 lines**
- chat_input_bar_widget.dart: **~200 lines**

**Total**: Still ~1100 lines, but split into manageable pieces!

---

## Testing Checklist

After refactoring, test:
- [ ] Send text message
- [ ] Send image
- [ ] Send file
- [ ] Send voice message
- [ ] Receive messages (real-time)
- [ ] Scroll to bottom on new message
- [ ] Group chat avatar/name display
- [ ] Private chat avatar/name display
- [ ] Error handling
- [ ] Loading states

---

Generated: 2025-11-18
