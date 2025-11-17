<?php

namespace App\Events;

use App\Models\Message;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class MessageSent implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $message;
    public $conversationId;
    public $companyId;

    /**
     * Create a new event instance.
     */
    public function __construct(Message $message, int $conversationId, int $companyId)
    {
        $this->message = $message;
        $this->conversationId = $conversationId;
        $this->companyId = $companyId;
    }

    /**
     * Get the channels the event should broadcast on.
     *
     * @return array<int, \Illuminate\Broadcasting\Channel>
     */
    public function broadcastOn(): array
    {
        // Broadcast to a private channel for this specific conversation
        return [
            new PrivateChannel("chat.{$this->companyId}.conversation.{$this->conversationId}"),
        ];
    }

    /**
     * The event's broadcast name.
     */
    public function broadcastAs(): string
    {
        return 'message.sent';
    }

    /**
     * Get the data to broadcast.
     */
    public function broadcastWith(): array
    {
        // Try to get user info safely
        $userName = 'Unknown User';
        $userAvatar = null;
        
        try {
            if ($this->message->user_id) {
                $user = \App\Models\User::find($this->message->user_id);
                if ($user) {
                    $userName = $user->name ?? $user->email ?? "User #{$user->id}";
                    if (method_exists($user, 'getFirstMediaUrl')) {
                        $userAvatar = $user->getFirstMediaUrl('avatar');
                    }
                }
            }
        } catch (\Exception $e) {
            // Use default if user not found
        }

        return [
            'id' => $this->message->id,
            'body' => $this->message->body,
            'user_id' => $this->message->user_id,
            'user_name' => $userName,
            'user_avatar' => $userAvatar,
            'created_at' => $this->message->created_at->format('H:i'),
            'attachment_type' => $this->message->attachment_type,
            'attachment_name' => $this->message->attachment_name,
            'attachment_size' => $this->message->attachment_size,
            'attachment_url' => $this->message->attachment_path ? asset('storage/' . $this->message->attachment_path) : null,
            'read_at' => $this->message->read_at,
        ];
    }
}
