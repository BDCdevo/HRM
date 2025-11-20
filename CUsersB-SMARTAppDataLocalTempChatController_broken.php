<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Conversation;
use App\Models\Message;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Events\MessageSent;

class ChatController extends Controller
{

    /**
     * Normalize User ID - Convert employee_id to user_id if exists
     */
    protected function normalizeUserId($userId)
    {
        $employee = \App\Models\Employee::find($userId);
        if ($employee && $employee->email) {
            $user = \App\Models\User::where('email', $employee->email)->first();
            if ($user) {
                \Log::info("🔄 Normalizing: employee_id={$userId} → user_id={$user->id}");
                return $user->id;
            }
        }
        return $userId;
    }

    /**
     * Get conversations for current user and company
     */
    public function getConversations(Request $request)
    {
        if (!auth()->check()) {
            return response()->json(['error' => 'Unauthenticated'], 401);
        }

        $companyId = $request->get('company_id');

        if (!$companyId) {
            return response()->json(['error' => 'Company ID required'], 400);
        }

        // Skip company verification for now
        // Set company_id in session for CurrentCompanyScope
        session(['current_company_id' => $companyId]);

        // Normalize user ID for participant lookup
        $normalizedUserId = $this->normalizeUserId(auth()->id());



        // Optimize query with select to reduce data transfer
        $conversations = Conversation::forUser($normalizedUserId)
            ->forCompany($companyId)
            ->with([
                'users:id,name,email',
                'latestMessage',
                'latestMessage.user:id,name',
                'users'
            ])
            ->orderBy('conversations.last_message_at', 'desc')
            ->get()
            ->map(function ($conversation) use ($normalizedUserId) {
                $participant = $conversation->users->where('user_id', $normalizedUserId)->first();

                // Get other user for private conversations
                $otherUser = null;
                if ($conversation->type === 'private') {
                    $otherUser = $conversation->users->where('id', '!=', $normalizedUserId)->first();
                }

                // Check if user is online (within last 5 minutes)
                $isOnline = $otherUser && $otherUser->last_seen_at
                    ? $otherUser->last_seen_at->gt(now()->subMinutes(5))
                    : false;

                // Format last seen for display
                $lastSeenText = null;
                if ($otherUser && $otherUser->last_seen_at && !$isOnline) {
                    $lastSeenText = $otherUser->last_seen_at->diffForHumans();
                }

                return [
                    'id' => $conversation->id,
                    'type' => $conversation->type,
                    'name' => $conversation->type === 'group'
                        ? $conversation->name
                        : $otherUser?->name,
                    'avatar' => null, // Optimize: skip avatar for now
                    'last_message' => ->latestMessage ? (->latestMessage->message ?: (->latestMessage->attachment_type ? 'رسالة ' . ->latestMessage->attachment_type : 'لا توجد رسائل')) : 'لا توجد رسائل',
                    'last_message_at' => $lastSeenText ?: $conversation->last_message_at?->diffForHumans(),
                    'unread_count' => $participant?->unread_count ?? 0,
                    'is_online' => $isOnline,
                    'last_seen_at' => $lastSeenText,
                ];
            });

        return response()->json([
            'success' => true,
            'conversations' => $conversations
        ]);
    }

    /**
     * Get messages for a conversation
     */
    public function getMessages(Request $request, $conversationId)
    {
        if (!auth()->check()) {
            return response()->json(['error' => 'Unauthenticated'], 401);
        }

        // Get company ID from request
        $companyId = $this->getCompanyIdFromRequest($request);

        if (!$companyId) {
            return response()->json(['error' => 'Company ID required'], 400);
        }
        // Set company_id in session for CurrentCompanyScope
        session(['current_company_id' => $companyId]);

        // Normalize user ID for participant lookup
        $normalizedUserId = $this->normalizeUserId(auth()->id());

        // Verify user has access to this conversation
        $conversation = Conversation::forUser($normalizedUserId)
            ->forCompany($companyId)
            ->findOrFail($conversationId);

        // Mark conversation as read
        $conversation->markAsReadForUser($normalizedUserId);

        $messages = $conversation->messages()
            ->orderBy('created_at', 'asc')
            ->get()
            ->map(function ($message) use ($normalizedUserId) {
                // Handle case where user relationship might not exist
                $userName = 'Unknown User';
                $userAvatar = null;

                // Try to get user info safely
                try {
                    if ($message->user_id) {
                        $user = \App\Models\User::find($message->user_id);
                        if ($user) {
                            $userName = $user->name ?? $user->email ?? "User #{$user->id}";
                            if (method_exists($user, 'getFirstMediaUrl')) {
                                $userAvatar = $user->getFirstMediaUrl('avatar');
                            }
                        }
                    }
                } catch (\Exception $e) {
                    // If user not found, use default name
                }

                // Check if message is read by OTHER users (not sender)
                // For MY messages: check if ANY other user read it
                // For OTHER's messages: null (we don't show read status for received messages)
                $readAt = null;
                if ($message->user_id === $normalizedUserId) {
                    // This is MY message - check if others read it
                    if ($message->read_by && is_array($message->read_by)) {
                        foreach ($message->read_by as $reader) {
                            if (isset($reader['user_id']) && $reader['user_id'] != $normalizedUserId) {
                                $readAt = $reader['read_at'] ?? null;
                                break;  // Found at least one reader
                            }
                        }
                    }
                }

                return [
                    'id' => $message->id,
                    'body' => $message->message,
                    'user_id' => $message->user_id,
                    'user_name' => $userName,
                    'user_avatar' => $userAvatar,
                    'created_at' => $message->created_at->toIso8601String(),
                    'is_mine' => $message->user_id === $normalizedUserId,
                    'attachment_type' => $message->attachment_type,
                    'attachment_name' => $message->attachment_name,
                    'attachment_size' => $message->attachment_size,
                    'attachment_url' => $message->attachment_path ? asset('storage/' . $message->attachment_path) : null,
                    'read_at' => $readAt,
                ];
            });

        return response()->json([
            'success' => true,
            'messages' => $messages
        ]);
    }

    public function sendMessage(Request $request, $conversationId)
    {
        \Log::info("📨 sendMessage called", [
            'conversation_id' => $conversationId,
            'has_file' => $request->hasFile('attachment'),
            'all_files' => $request->allFiles(),
            'attachment_type_param' => $request->input('attachment_type'),
            'message' => $request->input('message'),
            'request_keys' => array_keys($request->all()),
        ]);

        if (!auth()->check()) {
            return response()->json(['error' => 'Unauthenticated'], 401);
        }

        $validator = Validator::make($request->all(), [
            'message' => 'nullable|string|max:2000',
            'attachment' => 'nullable|file|max:10240',
            'attachment_type' => 'nullable|string|in:voice,image,video,audio,document,file',
        ]);

        if ($validator->fails()) {
            \Log::error("❌ Validation failed", ['errors' => $validator->errors()]);
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        // Get company ID from request
        $companyId = $this->getCompanyIdFromRequest($request);

        if (!$companyId) {
            return response()->json(['error' => 'Company ID required'], 400);
        }
        // Set company_id in session for CurrentCompanyScope
        session(['current_company_id' => $companyId]);

        // Normalize user ID
        $normalizedUserId = $this->normalizeUserId(auth()->id());

        // Verify conversation belongs to current company
        $conversation = Conversation::forUser($normalizedUserId)
            ->forCompany($companyId)
            ->findOrFail($conversationId);

        $messageData = [
            'conversation_id' => $conversationId,
            'user_id' => $normalizedUserId,
            'message' => $request->message ?? '',
            'type' => 'text',
        ];

        // Handle file attachment
        if ($request->hasFile('attachment')) {
            \Log::info("📎 File detected in request");

            try {
                $file = $request->file('attachment');

                \Log::info("📄 File details", [
                    'original_name' => $file->getClientOriginalName(),
                    'mime_type' => $file->getMimeType(),
                    'size' => $file->getSize(),
                    'extension' => $file->getClientOriginalExtension(),
                    'is_valid' => $file->isValid(),
                    'error' => $file->getError(),
                ]);

                $fileName = time() . '_' . $file->getClientOriginalName();

                \Log::info("💾 Attempting to store file", [
                    'filename' => $fileName,
                    'disk' => 'public',
                    'path' => 'chat-attachments',
                ]);

                $filePath = $file->storeAs('chat-attachments', $fileName, 'public');

                \Log::info("✅ File stored successfully", [
                    'stored_path' => $filePath,
                    'full_path' => storage_path('app/public/' . $filePath),
                    'exists' => file_exists(storage_path('app/public/' . $filePath)),
                ]);

                $messageData['attachment_path'] = $filePath;
                $messageData['attachment_name'] = $file->getClientOriginalName();
                $messageData['attachment_size'] = $file->getSize();

                // Priority 1: Use client-provided attachment_type if available
                if ($request->has('attachment_type') && !empty($request->attachment_type)) {
                    $clientType = strtolower($request->attachment_type);

                    $typeMap = [
                        'voice' => 'voice',
                        'image' => 'image',
                        'video' => 'video',
                        'audio' => 'audio',
                        'document' => 'document',
                        'file' => 'document',
                    ];

                    $messageData['attachment_type'] = $typeMap[$clientType] ?? 'document';

                    \Log::info("🎤 Using client-provided attachment_type", [
                        'client_type' => $request->attachment_type,
                        'mapped_type' => $messageData['attachment_type'],
                    ]);
                } else {
                    // Priority 2: Fallback to MIME type detection
                    $mimeType = $file->getMimeType();
                    if (str_starts_with($mimeType, 'image/')) {
                        $messageData['attachment_type'] = 'image';
                    } elseif (str_starts_with($mimeType, 'video/')) {
                        $messageData['attachment_type'] = 'video';
                    } elseif (str_starts_with($mimeType, 'audio/')) {
                        $messageData['attachment_type'] = 'audio';
                    } else {
                        $messageData['attachment_type'] = 'document';
                    }

                    \Log::info("🔍 Using MIME type detection", [
                        'mime_type' => $mimeType,
                        'detected_type' => $messageData['attachment_type'],
                    ]);
                }
            } catch (\Exception $e) {
                \Log::error("❌ File upload failed", [
                    'error' => $e->getMessage(),
                    'trace' => $e->getTraceAsString(),
                ]);

                return response()->json([
                    'success' => false,
                    'message' => 'File upload failed: ' . $e->getMessage()
                ], 500);
            }
        } else {
            \Log::info("📭 No file in request");
        }

        \Log::info("💬 Creating message", ['data' => $messageData]);

        $message = Message::create($messageData);

        \Log::info("✅ Message created", [
            'id' => $message->id,
            'attachment_type' => $message->attachment_type,
            'attachment_path' => $message->attachment_path,
            'attachment_url' => $message->attachment_path ? asset('storage/' . $message->attachment_path) : null,
        ]);

        // Broadcast the message in real-time
        broadcast(new MessageSent($message, $conversationId, $companyId))->toOthers();

        // Update conversation's last_message_at
        $conversation->update(['last_message_at' => now()]);

        return response()->json([
            'success' => true,
            'message' => [
                'id' => $message->id,
                'body' => $message->message,
                'user_id' => $message->user_id,
                'user_name' => auth()->user()->name ?? auth()->user()->email ?? "User #" . auth()->user()->id,
                'created_at' => $message->created_at->toIso8601String(),
                'is_mine' => true,
                'attachment_type' => $message->attachment_type,
                'attachment_name' => $message->attachment_name,
                'attachment_size' => $message->attachment_size,
                'attachment_url' => $message->attachment_path ? asset('storage/' . $message->attachment_path) : null,
            ]
        ]);
    }

    /**
     * Get available users for creating new conversation
     */
    public function getUsers(Request $request)
    {
        if (!auth()->check()) {
            return response()->json(['error' => 'Unauthenticated'], 401);
        }

        $companyId = $request->get('company_id');

        if (!$companyId) {
            return response()->json(['error' => 'Company ID required'], 400);
        }

        // Skip company verification for now

        // Get only users from the same company
        $users = User::whereHas('companies', function ($query) use ($companyId) {
                $query->where('companies.id', $companyId);
            })
            ->where('id', '!=', auth()->id())
            ->whereNull('deleted_at')
            ->select('id', 'name', 'email')
            ->get();

        return response()->json([
            'success' => true,
            'users' => $users
        ]);
    }

    /**
     * Create new conversation
     */
    public function createConversation(Request $request)
    {
        if (!auth()->check()) {
            return response()->json(['error' => 'Unauthenticated'], 401);
        }

        $validator = Validator::make($request->all(), [
            'company_id' => 'required|exists:companies,id',
            'user_ids' => 'required|array|min:1',
            'user_ids.*' => 'integer',
            'type' => 'nullable|in:private,group',
            'name' => 'nullable|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }


        $companyId = $request->company_id;

        // Set company_id in session for CurrentCompanyScope (MUST be before ANY Conversation query)
        session(['current_company_id' => $companyId]);

        // Skip company verification for now
        $type = $request->type ?? (count($request->user_ids) > 1 ? 'group' : 'private');
        // Check if private conversation already exists
        if ($type === 'private') {
            // Get both user IDs and sort them for comparison
            $userId1 = $this->normalizeUserId(auth()->id());
            $userId2 = $this->normalizeUserId($request->user_ids[0]);
            $targetUserIds = [$userId1, $userId2];
            sort($targetUserIds);

            // Find all private conversations where current user participates
            $conversations = Conversation::forUser($userId1)
                ->forCompany($companyId)
                ->where('type', 'private')
                ->with('users')
                ->get();

            // Check each conversation to find one with EXACTLY these 2 users
            foreach ($conversations as $conv) {
                $convUserIds = $conv->users->pluck('user_id')->sort()->values()->toArray();
                if ($convUserIds === $targetUserIds) {
                    // Found existing conversation!
                    return response()->json([
                        'success' => true,
                        'conversation' => [
                            'id' => $conv->id,
                        ]
                    ]);
                }
            }
        }


        // Create new conversation
        $conversation = Conversation::create([
            'company_id' => $companyId,
            'type' => $type,
            'name' => $type === 'group' ? ($request->name ?? 'مجموعة جديدة') : null,
            'created_by' => $this->normalizeUserId(auth()->id()),
        ]);

        // Add participants (normalize IDs)
        $normalizedAuthId = $this->normalizeUserId(auth()->id());
        $normalizedUserIds = array_map(function($id) {
            return $this->normalizeUserId($id);
        }, $request->user_ids);

        $participants = array_merge($normalizedUserIds, [$normalizedAuthId]);
        $participants = array_unique($participants);

        foreach ($participants as $userId) {
            $conversation->users()->attach($userId);
        }

        return response()->json([
            'success' => true,
            'conversation' => [
                'id' => $conversation->id,
            ]
        ]);
    }

    /**
     * Get company ID from request
     */
    private function getCompanyIdFromRequest(Request $request)
    {
        // Try to get from query string
        $companyId = $request->get('company_id');

        if (!$companyId) {
            // Try to get from URL path
            $path = $request->path();
            if (preg_match('/\/(\d+)\//', $path, $matches)) {
                $companyId = $matches[1];
            }
        }

        if (!$companyId) {
            // Try to get from header
            $companyId = $request->header('X-Company-Id');
        }

        if (!$companyId) {
            // Get first company of user
            $companyId = auth()->user()->companies()->first()?->id;
        }

        return $companyId;
    }
}
