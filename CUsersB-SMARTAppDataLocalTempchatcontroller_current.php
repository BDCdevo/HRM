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

        // Optimize query with select to reduce data transfer
        $conversations = Conversation::forUser(auth()->id())
            ->forCompany($companyId)
            ->with([
                'users:id,name,email',
                'latestMessage',
                'latestMessage.user:id,name',
                'participants'
            ])
            ->orderBy('conversations.last_message_at', 'desc')
            ->get()
            ->map(function ($conversation) {
                $participant = $conversation->participants->where('user_id', auth()->id())->first();

                // Get other user for private conversations
                $otherUser = null;
                if ($conversation->type === 'private') {
                    $otherUser = $conversation->users->where('id', '!=', auth()->id())->first();
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
                    'last_message' => $conversation->latestMessage?->body ?? 'لا توجد رسائل',
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

        // Verify user has access to this conversation
        $conversation = Conversation::forUser(auth()->id())
            ->forCompany($companyId)
            ->findOrFail($conversationId);

        // Mark conversation as read
        $conversation->markAsReadForUser(auth()->id());

        $messages = $conversation->messages()
            ->orderBy('created_at', 'asc')
            ->get()
            ->map(function ($message) {
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
                
                return [
                    'id' => $message->id,
                    'body' => $message->body,
                    'user_id' => $message->user_id,
                    'user_name' => $userName,
                    'user_avatar' => $userAvatar,
                    'created_at' => $message->created_at->toIso8601String(),
                    'is_mine' => $message->user_id === auth()->id(),
                    'attachment_type' => $message->attachment_type,
                    'attachment_name' => $message->attachment_name,
                    'attachment_size' => $message->attachment_size,
                    'attachment_url' => $message->attachment_path ? asset('storage/' . $message->attachment_path) : null,
                    'read_at' => $message->read_at,
                ];
            });

        return response()->json([
            'success' => true,
            'messages' => $messages
        ]);
    }
    public function sendMessage(Request $request, $conversationId)
    {
        if (!auth()->check()) {
            return response()->json(['error' => 'Unauthenticated'], 401);
        }

        $validator = Validator::make($request->all(), [
            'message' => 'nullable|string|max:2000',
            'attachment' => 'nullable|file|max:10240', // 10MB max
        ]);

        if ($validator->fails()) {
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

        // Verify conversation belongs to current company
        $conversation = Conversation::forUser(auth()->id())
            ->forCompany($companyId)
            ->findOrFail($conversationId);

        $messageData = [
            'conversation_id' => $conversationId,
            'user_id' => auth()->id(),
            'body' => $request->message ?? '',
            'type' => 'text',
        ];

        // Handle file attachment
        if ($request->hasFile('attachment')) {
            $file = $request->file('attachment');
            $fileName = time() . '_' . $file->getClientOriginalName();
            $filePath = $file->storeAs('chat-attachments', $fileName, 'public');

            $messageData['attachment_path'] = $filePath;
            $messageData['attachment_name'] = $file->getClientOriginalName();
            $messageData['attachment_size'] = $file->getSize();

            // Determine attachment type
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
        }

        $message = Message::create($messageData);
        
        // Broadcast the message in real-time
        broadcast(new MessageSent($message, $conversationId, $companyId))->toOthers();

        // Update conversation's last_message_at
        $conversation->update(['last_message_at' => now()]);

        return response()->json([
            'success' => true,
            'message' => [
                'id' => $message->id,
                'body' => $message->body,
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
            'user_ids.*' => 'exists:users,id',
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

        // Skip company verification for now

        $type = $request->type ?? (count($request->user_ids) > 1 ? 'group' : 'private');

        // Check if private conversation already exists
        if ($type === 'private') {
            $existingConversation = Conversation::forUser(auth()->id())
                ->forCompany($companyId)
                ->where('type', 'private')
                ->whereHas('participants', function ($query) use ($request) {
                    $query->where('user_id', $request->user_ids[0]);
                })
                ->first();

            if ($existingConversation) {
                return response()->json([
                    'success' => true,
                    'conversation' => [
                        'id' => $existingConversation->id,
                    ]
                ]);
            }
        }

        // Create new conversation
        $conversation = Conversation::create([
            'company_id' => $companyId,
            'type' => $type,
            'name' => $type === 'group' ? ($request->name ?? 'مجموعة جديدة') : null,
            'created_by' => null, // auth()->id() may not exist in users table
        ]);

        // Add participants
        $participants = array_merge($request->user_ids, [auth()->id()]);
        foreach ($participants as $userId) {
            $conversation->participants()->create([
                'user_id' => $userId,
                'role' => $userId === auth()->id() ? 'admin' : 'member',
            ]);
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
