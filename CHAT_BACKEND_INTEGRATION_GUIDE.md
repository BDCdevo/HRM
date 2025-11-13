# Chat Feature - Backend Integration Guide

## 📋 Overview

هذا الدليل يوضح خطوات تطبيق الـ Backend للشات وربطه مع Flutter. الـ UI جاهز 100% والآن نحتاج فقط API Endpoints.

## ✅ Current Status

### Frontend (Flutter) - 100% Complete ✅
- ✅ All UI screens created
- ✅ Models with JSON serialization
- ✅ Mock data for testing
- ✅ Dark mode support
- ✅ Navigation Bar integration
- ✅ Full documentation

### Backend (Laravel) - 0% (To Be Implemented) 🔜
- 🔜 Database migrations
- 🔜 Models and relationships
- 🔜 API Controllers
- 🔜 API Routes
- 🔜 Real-time events (optional)

## 📊 Database Structure

### Table 1: `conversations`

```sql
CREATE TABLE conversations (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    employee1_id BIGINT UNSIGNED NOT NULL,
    employee2_id BIGINT UNSIGNED NOT NULL,
    company_id BIGINT UNSIGNED NOT NULL,
    last_message_id BIGINT UNSIGNED NULL,
    last_message_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Foreign Keys
    FOREIGN KEY (employee1_id) REFERENCES employees(id) ON DELETE CASCADE,
    FOREIGN KEY (employee2_id) REFERENCES employees(id) ON DELETE CASCADE,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (last_message_id) REFERENCES messages(id) ON DELETE SET NULL,

    -- Indexes
    INDEX idx_employee1 (employee1_id),
    INDEX idx_employee2 (employee2_id),
    INDEX idx_company (company_id),
    INDEX idx_last_message_at (last_message_at),

    -- Unique: Prevent duplicate conversations
    UNIQUE KEY unique_conversation (employee1_id, employee2_id, company_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Important Notes**:
- `employee1_id` should always be < `employee2_id` (normalize before inserting)
- Multi-tenancy: Always scope by `company_id`

### Table 2: `messages`

```sql
CREATE TABLE messages (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    conversation_id BIGINT UNSIGNED NOT NULL,
    sender_id BIGINT UNSIGNED NOT NULL,
    message TEXT NOT NULL,
    message_type ENUM('text', 'image', 'file', 'voice') DEFAULT 'text',
    file_url VARCHAR(255) NULL,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Foreign Keys
    FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES employees(id) ON DELETE CASCADE,

    -- Indexes
    INDEX idx_conversation (conversation_id),
    INDEX idx_sender (sender_id),
    INDEX idx_created_at (created_at),
    INDEX idx_is_read (is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

## 🔧 Laravel Implementation

### Step 1: Create Migration

```bash
php artisan make:migration create_conversations_table
php artisan make:migration create_messages_table
```

**File**: `database/migrations/xxxx_xx_xx_create_conversations_table.php`
```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('conversations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('employee1_id')->constrained('employees')->onDelete('cascade');
            $table->foreignId('employee2_id')->constrained('employees')->onDelete('cascade');
            $table->foreignId('company_id')->constrained('companies')->onDelete('cascade');
            $table->foreignId('last_message_id')->nullable()->constrained('messages')->onDelete('set null');
            $table->timestamp('last_message_at')->nullable();
            $table->timestamps();

            // Indexes
            $table->index('employee1_id');
            $table->index('employee2_id');
            $table->index('company_id');
            $table->index('last_message_at');

            // Unique constraint
            $table->unique(['employee1_id', 'employee2_id', 'company_id'], 'unique_conversation');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('conversations');
    }
};
```

**File**: `database/migrations/xxxx_xx_xx_create_messages_table.php`
```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('messages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('conversation_id')->constrained('conversations')->onDelete('cascade');
            $table->foreignId('sender_id')->constrained('employees')->onDelete('cascade');
            $table->text('message');
            $table->enum('message_type', ['text', 'image', 'file', 'voice'])->default('text');
            $table->string('file_url')->nullable();
            $table->boolean('is_read')->default(false);
            $table->timestamp('read_at')->nullable();
            $table->timestamps();

            // Indexes
            $table->index('conversation_id');
            $table->index('sender_id');
            $table->index('created_at');
            $table->index('is_read');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('messages');
    }
};
```

```bash
php artisan migrate
```

### Step 2: Create Models

**File**: `app/Models/Conversation.php`
```php
<?php

namespace App\Models;

use App\Traits\CompanyOwned;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Conversation extends Model
{
    use CompanyOwned;

    protected $fillable = [
        'employee1_id',
        'employee2_id',
        'company_id',
        'last_message_id',
        'last_message_at',
    ];

    protected $casts = [
        'last_message_at' => 'datetime',
    ];

    // Relationships
    public function employee1(): BelongsTo
    {
        return $this->belongsTo(Employee::class, 'employee1_id');
    }

    public function employee2(): BelongsTo
    {
        return $this->belongsTo(Employee::class, 'employee2_id');
    }

    public function company(): BelongsTo
    {
        return $this->belongsTo(Company::class);
    }

    public function lastMessage(): BelongsTo
    {
        return $this->belongsTo(Message::class, 'last_message_id');
    }

    public function messages(): HasMany
    {
        return $this->hasMany(Message::class)->orderBy('created_at', 'desc');
    }

    // Helper: Get participant for current employee
    public function getParticipant(int $currentEmployeeId): Employee
    {
        return $this->employee1_id === $currentEmployeeId
            ? $this->employee2
            : $this->employee1;
    }

    // Helper: Get unread count for employee
    public function getUnreadCount(int $employeeId): int
    {
        return $this->messages()
            ->where('sender_id', '!=', $employeeId)
            ->where('is_read', false)
            ->count();
    }

    // Normalize employee IDs (employee1 < employee2)
    public static function normalizeEmployeeIds(int $id1, int $id2): array
    {
        return $id1 < $id2 ? [$id1, $id2] : [$id2, $id1];
    }
}
```

**File**: `app/Models/Message.php`
```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Message extends Model
{
    protected $fillable = [
        'conversation_id',
        'sender_id',
        'message',
        'message_type',
        'file_url',
        'is_read',
        'read_at',
    ];

    protected $casts = [
        'is_read' => 'boolean',
        'read_at' => 'datetime',
    ];

    // Relationships
    public function conversation(): BelongsTo
    {
        return $this->belongsTo(Conversation::class);
    }

    public function sender(): BelongsTo
    {
        return $this->belongsTo(Employee::class, 'sender_id');
    }

    // Mark as read
    public function markAsRead(): void
    {
        if (!$this->is_read) {
            $this->update([
                'is_read' => true,
                'read_at' => now(),
            ]);
        }
    }
}
```

### Step 3: Create API Controller

**File**: `app/Http/Controllers/Api/V1/ChatController.php`
```php
<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Conversation;
use App\Models\Message;
use App\Models\Employee;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ChatController extends Controller
{
    /**
     * Get all conversations for authenticated employee
     *
     * GET /api/v1/chat/conversations
     */
    public function conversations(Request $request): JsonResponse
    {
        $employee = $request->user();

        // Set company session for multi-tenancy
        session(['current_company_id' => $employee->company_id]);

        $conversations = Conversation::where(function ($query) use ($employee) {
            $query->where('employee1_id', $employee->id)
                  ->orWhere('employee2_id', $employee->id);
        })
        ->with(['employee1', 'employee2', 'lastMessage'])
        ->orderBy('last_message_at', 'desc')
        ->get()
        ->map(function ($conversation) use ($employee) {
            $participant = $conversation->getParticipant($employee->id);

            return [
                'id' => $conversation->id,
                'participant_id' => $participant->id,
                'participant_name' => $participant->first_name . ' ' . $participant->last_name,
                'participant_avatar' => $participant->image,
                'last_message' => $conversation->lastMessage ? [
                    'id' => $conversation->lastMessage->id,
                    'message' => $conversation->lastMessage->message,
                    'message_type' => $conversation->lastMessage->message_type,
                    'sender_id' => $conversation->lastMessage->sender_id,
                    'created_at' => $conversation->lastMessage->created_at->toIso8601String(),
                    'is_read' => $conversation->lastMessage->is_read,
                ] : null,
                'unread_count' => $conversation->getUnreadCount($employee->id),
                'updated_at' => $conversation->updated_at->toIso8601String(),
            ];
        });

        return response()->json([
            'success' => true,
            'message' => 'Conversations fetched successfully',
            'data' => $conversations,
        ]);
    }

    /**
     * Get messages for a conversation
     *
     * GET /api/v1/chat/conversations/{conversationId}/messages
     */
    public function messages(Request $request, int $conversationId): JsonResponse
    {
        $employee = $request->user();

        // Set company session
        session(['current_company_id' => $employee->company_id]);

        $conversation = Conversation::findOrFail($conversationId);

        // Verify employee is participant
        if ($conversation->employee1_id !== $employee->id &&
            $conversation->employee2_id !== $employee->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access to conversation',
            ], 403);
        }

        $messages = Message::where('conversation_id', $conversationId)
            ->with('sender')
            ->orderBy('created_at', 'asc')
            ->get()
            ->map(function ($message) {
                return [
                    'id' => $message->id,
                    'conversation_id' => $message->conversation_id,
                    'sender_id' => $message->sender_id,
                    'sender_name' => $message->sender->first_name . ' ' . $message->sender->last_name,
                    'message' => $message->message,
                    'message_type' => $message->message_type,
                    'file_url' => $message->file_url,
                    'is_read' => $message->is_read,
                    'created_at' => $message->created_at->toIso8601String(),
                    'updated_at' => $message->updated_at->toIso8601String(),
                ];
            });

        return response()->json([
            'success' => true,
            'message' => 'Messages fetched successfully',
            'data' => $messages,
        ]);
    }

    /**
     * Send a message
     *
     * POST /api/v1/chat/conversations/{conversationId}/messages
     * Body: { message, message_type? }
     */
    public function sendMessage(Request $request, int $conversationId): JsonResponse
    {
        $employee = $request->user();

        // Set company session
        session(['current_company_id' => $employee->company_id]);

        // Validate
        $validator = Validator::make($request->all(), [
            'message' => 'required|string|max:10000',
            'message_type' => 'nullable|in:text,image,file,voice',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $conversation = Conversation::findOrFail($conversationId);

        // Verify employee is participant
        if ($conversation->employee1_id !== $employee->id &&
            $conversation->employee2_id !== $employee->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access to conversation',
            ], 403);
        }

        // Create message
        $message = Message::create([
            'conversation_id' => $conversationId,
            'sender_id' => $employee->id,
            'message' => $request->message,
            'message_type' => $request->message_type ?? 'text',
            'is_read' => false,
        ]);

        // Update conversation last_message
        $conversation->update([
            'last_message_id' => $message->id,
            'last_message_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Message sent successfully',
            'data' => [
                'id' => $message->id,
                'conversation_id' => $message->conversation_id,
                'sender_id' => $message->sender_id,
                'sender_name' => $employee->first_name . ' ' . $employee->last_name,
                'message' => $message->message,
                'message_type' => $message->message_type,
                'is_read' => $message->is_read,
                'created_at' => $message->created_at->toIso8601String(),
                'updated_at' => $message->updated_at->toIso8601String(),
            ],
        ], 201);
    }

    /**
     * Mark conversation messages as read
     *
     * PUT /api/v1/chat/conversations/{conversationId}/read
     */
    public function markAsRead(Request $request, int $conversationId): JsonResponse
    {
        $employee = $request->user();

        // Set company session
        session(['current_company_id' => $employee->company_id]);

        $conversation = Conversation::findOrFail($conversationId);

        // Verify employee is participant
        if ($conversation->employee1_id !== $employee->id &&
            $conversation->employee2_id !== $employee->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access to conversation',
            ], 403);
        }

        // Mark unread messages from other participant as read
        Message::where('conversation_id', $conversationId)
            ->where('sender_id', '!=', $employee->id)
            ->where('is_read', false)
            ->update([
                'is_read' => true,
                'read_at' => now(),
            ]);

        return response()->json([
            'success' => true,
            'message' => 'Messages marked as read',
        ]);
    }

    /**
     * Create new conversation
     *
     * POST /api/v1/chat/conversations
     * Body: { participant_id }
     */
    public function createConversation(Request $request): JsonResponse
    {
        $employee = $request->user();

        // Set company session
        session(['current_company_id' => $employee->company_id]);

        // Validate
        $validator = Validator::make($request->all(), [
            'participant_id' => 'required|exists:employees,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        // Can't chat with yourself
        if ($request->participant_id == $employee->id) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot create conversation with yourself',
            ], 422);
        }

        // Check if conversation exists
        [$emp1, $emp2] = Conversation::normalizeEmployeeIds($employee->id, $request->participant_id);

        $conversation = Conversation::firstOrCreate(
            [
                'employee1_id' => $emp1,
                'employee2_id' => $emp2,
                'company_id' => $employee->company_id,
            ],
            [
                'last_message_at' => now(),
            ]
        );

        $participant = Employee::findOrFail($request->participant_id);

        return response()->json([
            'success' => true,
            'message' => 'Conversation created successfully',
            'data' => [
                'id' => $conversation->id,
                'participant_id' => $participant->id,
                'participant_name' => $participant->first_name . ' ' . $participant->last_name,
                'participant_avatar' => $participant->image,
                'last_message' => null,
                'unread_count' => 0,
                'updated_at' => $conversation->updated_at->toIso8601String(),
            ],
        ], 201);
    }

    /**
     * Delete conversation
     *
     * DELETE /api/v1/chat/conversations/{conversationId}
     */
    public function deleteConversation(Request $request, int $conversationId): JsonResponse
    {
        $employee = $request->user();

        // Set company session
        session(['current_company_id' => $employee->company_id]);

        $conversation = Conversation::findOrFail($conversationId);

        // Verify employee is participant
        if ($conversation->employee1_id !== $employee->id &&
            $conversation->employee2_id !== $employee->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access to conversation',
            ], 403);
        }

        // Delete conversation (cascade deletes messages)
        $conversation->delete();

        return response()->json([
            'success' => true,
            'message' => 'Conversation deleted successfully',
        ]);
    }

    /**
     * Get all employees for selection (start new chat)
     *
     * GET /api/v1/chat/employees
     */
    public function employees(Request $request): JsonResponse
    {
        $employee = $request->user();

        // Set company session
        session(['current_company_id' => $employee->company_id]);

        $employees = Employee::where('company_id', $employee->company_id)
            ->where('id', '!=', $employee->id) // Exclude current employee
            ->where('status', 1) // Active employees only
            ->with('department')
            ->orderBy('first_name')
            ->get()
            ->map(function ($emp) {
                return [
                    'id' => $emp->id,
                    'name' => $emp->first_name . ' ' . $emp->last_name,
                    'email' => $emp->email,
                    'department' => $emp->department ? $emp->department->name : 'No Department',
                    'image' => $emp->image,
                ];
            });

        return response()->json([
            'success' => true,
            'message' => 'Employees fetched successfully',
            'data' => $employees,
        ]);
    }
}
```

### Step 4: Add API Routes

**File**: `routes/api.php`
```php
Route::middleware('auth:sanctum')->prefix('v1')->group(function () {
    // ... existing routes ...

    // Chat Routes
    Route::prefix('chat')->group(function () {
        // Get all conversations
        Route::get('/conversations', [ChatController::class, 'conversations']);

        // Create new conversation
        Route::post('/conversations', [ChatController::class, 'createConversation']);

        // Get messages for conversation
        Route::get('/conversations/{conversationId}/messages', [ChatController::class, 'messages']);

        // Send message
        Route::post('/conversations/{conversationId}/messages', [ChatController::class, 'sendMessage']);

        // Mark conversation as read
        Route::put('/conversations/{conversationId}/read', [ChatController::class, 'markAsRead']);

        // Delete conversation
        Route::delete('/conversations/{conversationId}', [ChatController::class, 'deleteConversation']);

        // Get all employees (for selection)
        Route::get('/employees', [ChatController::class, 'employees']);
    });
});
```

### Step 5: Clear Caches

```bash
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan route:list --path=api/v1/chat
```

## 🔗 Flutter Integration

### Step 1: Create Repository

**File**: `lib/features/chat/data/repo/chat_repo.dart`
```dart
import 'package:dio/dio.dart';
import '../../../../core/networking/dio_client.dart';
import '../../../../core/config/api_config.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class ChatRepo {
  final DioClient _dioClient;

  ChatRepo() : _dioClient = DioClient.getInstance();

  /// Get all conversations
  Future<List<ConversationModel>> getConversations() async {
    final response = await _dioClient.get(ApiConfig.chatConversations);

    if (response.statusCode == 200) {
      final data = response.data['data'] as List;
      return data.map((json) => ConversationModel.fromJson(json)).toList();
    }

    throw Exception(response.data['message'] ?? 'Failed to fetch conversations');
  }

  /// Get messages for a conversation
  Future<List<MessageModel>> getMessages(int conversationId) async {
    final response = await _dioClient.get(
      '${ApiConfig.chatConversations}/$conversationId/messages',
    );

    if (response.statusCode == 200) {
      final data = response.data['data'] as List;
      return data.map((json) => MessageModel.fromJson(json)).toList();
    }

    throw Exception(response.data['message'] ?? 'Failed to fetch messages');
  }

  /// Send a message
  Future<MessageModel> sendMessage(int conversationId, String message, {String messageType = 'text'}) async {
    final response = await _dioClient.post(
      '${ApiConfig.chatConversations}/$conversationId/messages',
      data: {
        'message': message,
        'message_type': messageType,
      },
    );

    if (response.statusCode == 201) {
      return MessageModel.fromJson(response.data['data']);
    }

    throw Exception(response.data['message'] ?? 'Failed to send message');
  }

  /// Mark conversation as read
  Future<void> markAsRead(int conversationId) async {
    final response = await _dioClient.put(
      '${ApiConfig.chatConversations}/$conversationId/read',
    );

    if (response.statusCode != 200) {
      throw Exception(response.data['message'] ?? 'Failed to mark as read');
    }
  }

  /// Create new conversation
  Future<ConversationModel> createConversation(int participantId) async {
    final response = await _dioClient.post(
      ApiConfig.chatConversations,
      data: {'participant_id': participantId},
    );

    if (response.statusCode == 201) {
      return ConversationModel.fromJson(response.data['data']);
    }

    throw Exception(response.data['message'] ?? 'Failed to create conversation');
  }

  /// Delete conversation
  Future<void> deleteConversation(int conversationId) async {
    final response = await _dioClient.delete(
      '${ApiConfig.chatConversations}/$conversationId',
    );

    if (response.statusCode != 200) {
      throw Exception(response.data['message'] ?? 'Failed to delete conversation');
    }
  }

  /// Get all employees (for selection)
  Future<List<Map<String, dynamic>>> getEmployees() async {
    final response = await _dioClient.get(ApiConfig.chatEmployees);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(response.data['data']);
    }

    throw Exception(response.data['message'] ?? 'Failed to fetch employees');
  }
}
```

### Step 2: Add API Endpoints to Config

**File**: `lib/core/config/api_config.dart`
```dart
class ApiConfig {
  // ... existing endpoints ...

  // Chat Endpoints
  static const String chatConversations = '$baseUrl/chat/conversations';
  static const String chatEmployees = '$baseUrl/chat/employees';
}
```

### Step 3: Create Cubit (State Management)

**File**: `lib/features/chat/logic/cubit/chat_state.dart`
```dart
import 'package:equatable/equatable.dart';
import '../../data/models/conversation_model.dart';
import '../../data/models/message_model.dart';

class ChatState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<ConversationModel> conversations;
  final List<MessageModel> messages;
  final int? activeConversationId;

  const ChatState({
    this.isLoading = false,
    this.error,
    this.conversations = const [],
    this.messages = const [],
    this.activeConversationId,
  });

  ChatState copyWith({
    bool? isLoading,
    String? error,
    List<ConversationModel>? conversations,
    List<MessageModel>? messages,
    int? activeConversationId,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      activeConversationId: activeConversationId ?? this.activeConversationId,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    error,
    conversations,
    messages,
    activeConversationId,
  ];
}
```

**File**: `lib/features/chat/logic/cubit/chat_cubit.dart`
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/chat_repo.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepo _chatRepo;

  ChatCubit(this._chatRepo) : super(const ChatState());

  /// Fetch all conversations
  Future<void> fetchConversations() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final conversations = await _chatRepo.getConversations();
      emit(state.copyWith(
        isLoading: false,
        conversations: conversations,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  /// Fetch messages for conversation
  Future<void> fetchMessages(int conversationId) async {
    emit(state.copyWith(
      isLoading: true,
      error: null,
      activeConversationId: conversationId,
    ));

    try {
      final messages = await _chatRepo.getMessages(conversationId);
      emit(state.copyWith(
        isLoading: false,
        messages: messages,
      ));

      // Mark as read
      await _chatRepo.markAsRead(conversationId);
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  /// Send message
  Future<void> sendMessage(int conversationId, String message) async {
    try {
      final newMessage = await _chatRepo.sendMessage(conversationId, message);

      // Add message to list
      final updatedMessages = [...state.messages, newMessage];
      emit(state.copyWith(messages: updatedMessages));

      // Refresh conversations to update last message
      await fetchConversations();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Create new conversation
  Future<void> createConversation(int participantId) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final conversation = await _chatRepo.createConversation(participantId);

      // Add to conversations list
      final updatedConversations = [conversation, ...state.conversations];
      emit(state.copyWith(
        isLoading: false,
        conversations: updatedConversations,
        activeConversationId: conversation.id,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  /// Delete conversation
  Future<void> deleteConversation(int conversationId) async {
    try {
      await _chatRepo.deleteConversation(conversationId);

      // Remove from list
      final updatedConversations = state.conversations
          .where((c) => c.id != conversationId)
          .toList();
      emit(state.copyWith(conversations: updatedConversations));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
```

### Step 4: Replace Mock Data with BlocBuilder

**In `chat_list_screen.dart`**:
```dart
@override
Widget build(BuildContext context) {
  return BlocProvider(
    create: (context) => ChatCubit(ChatRepo())..fetchConversations(),
    child: Scaffold(
      appBar: _buildAppBar(),
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(child: Text('Error: ${state.error}'));
          }

          if (state.conversations.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            itemCount: state.conversations.length,
            itemBuilder: (context, index) {
              final conversation = state.conversations[index];
              return ConversationCard(
                conversation: conversation,
                currentUserId: 34, // Get from AuthCubit
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatRoomScreen(
                        conversationId: conversation.id,
                        participantName: conversation.participantName,
                        participantAvatar: conversation.participantAvatar,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: _buildFAB(context),
    ),
  );
}
```

## 🧪 Testing

### Backend Testing (Postman/Insomnia)

**1. Get Conversations**
```
GET https://erp1.bdcbiz.com/api/v1/chat/conversations
Authorization: Bearer {token}
```

**2. Create Conversation**
```
POST https://erp1.bdcbiz.com/api/v1/chat/conversations
Authorization: Bearer {token}
Content-Type: application/json

{
  "participant_id": 32
}
```

**3. Get Messages**
```
GET https://erp1.bdcbiz.com/api/v1/chat/conversations/1/messages
Authorization: Bearer {token}
```

**4. Send Message**
```
POST https://erp1.bdcbiz.com/api/v1/chat/conversations/1/messages
Authorization: Bearer {token}
Content-Type: application/json

{
  "message": "Hello! How are you?",
  "message_type": "text"
}
```

**5. Mark as Read**
```
PUT https://erp1.bdcbiz.com/api/v1/chat/conversations/1/read
Authorization: Bearer {token}
```

**6. Get Employees**
```
GET https://erp1.bdcbiz.com/api/v1/chat/employees
Authorization: Bearer {token}
```

## ✅ Final Checklist

### Backend:
- [ ] Create migrations
- [ ] Run `php artisan migrate`
- [ ] Create Conversation model
- [ ] Create Message model
- [ ] Create ChatController
- [ ] Add routes to `routes/api.php`
- [ ] Test with Postman
- [ ] Clear caches

### Flutter:
- [ ] Create `chat_repo.dart`
- [ ] Create `chat_state.dart`
- [ ] Create `chat_cubit.dart`
- [ ] Add API endpoints to `api_config.dart`
- [ ] Replace mock data in `chat_list_screen.dart`
- [ ] Replace mock data in `chat_room_screen.dart`
- [ ] Replace mock data in `employee_selection_screen.dart`
- [ ] Test full flow

### Deployment:
- [ ] Push backend changes to production
- [ ] Run migrations on production
- [ ] Build Flutter APK
- [ ] Test on device

## 🚀 Next Steps (Optional Enhancements)

- [ ] Real-time messaging with Laravel Echo + Pusher
- [ ] Image upload support
- [ ] File upload support
- [ ] Voice message recording
- [ ] Push notifications
- [ ] Online/offline status
- [ ] Typing indicators
- [ ] Message deletion
- [ ] Message editing
- [ ] Search in messages

---

**Status**: Ready for Backend Implementation
**Last Updated**: 2025-11-13
**Version**: 1.0

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
