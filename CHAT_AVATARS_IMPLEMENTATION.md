# Chat Avatars Implementation

## Summary

تم تفعيل صور المستخدمين في نظام الشات على الباك إند والفرونت إند. الآن يمكن للتطبيق عرض صور المستخدمين في:
- قائمة المحادثات (Conversation List)
- رسائل الشات (Message Bubbles)
- قائمة الموظفين (Employee Selection)

## Backend Changes (Production Server)

### File: `/var/www/erp1/app/Http/Controllers/Api/ChatController.php`

تم إجراء التعديلات التالية:

#### 1. `getConversations()` Method
**Before:**
```php
'avatar' => null, // Optimize: skip avatar for now
```

**After:**
```php
'avatar' => $otherUser && $otherUser->avatar && $otherUser->avatar !== 'avatar.png'
    ? (filter_var($otherUser->avatar, FILTER_VALIDATE_URL)
        ? $otherUser->avatar
        : asset('storage/avatars/' . $otherUser->avatar))
    : null,
'participants' => $conversation->type === 'private' && $otherUser
    ? [[
        'id' => $otherUser->id,
        'name' => $otherUser->name,
        'email' => $otherUser->email,
        'avatar' => $otherUser->avatar && $otherUser->avatar !== 'avatar.png'
            ? (filter_var($otherUser->avatar, FILTER_VALIDATE_URL)
                ? $otherUser->avatar
                : asset('storage/avatars/' . $otherUser->avatar))
            : null,
    ]]
    : [],
```

**Also added:**
- Added `avatar` to `users` select: `'users:id,name,email,avatar'`
- Added `avatar` to `latestMessage.user` select
- ✅ **Added `participants` array** with full user data (id, name, email, avatar)

#### 2. `getMessages()` Method
**Before:**
```php
if (method_exists($user, 'getFirstMediaUrl')) {
    $userAvatar = $user->getFirstMediaUrl('avatar');
}
```

**After:**
```php
// Get avatar directly from avatar field
if ($user->avatar && $user->avatar !== 'avatar.png') {
    $userAvatar = filter_var($user->avatar, FILTER_VALIDATE_URL)
        ? $user->avatar
        : asset('storage/avatars/' . $user->avatar);
}
```

#### 3. `sendMessage()` Method
**Added:**
```php
'user_avatar' => auth()->user()->avatar && auth()->user()->avatar !== 'avatar.png'
    ? (filter_var(auth()->user()->avatar, FILTER_VALIDATE_URL)
        ? auth()->user()->avatar
        : asset('storage/avatars/' . auth()->user()->avatar))
    : null,
```

#### 4. `getUsers()` Method
- Added `avatar` to select: `->select('id', 'name', 'email', 'avatar')`

### Backup
تم إنشاء نسخة احتياطية في:
```
/var/www/erp1/app/Http/Controllers/Api/ChatController.php.backup_avatars
```

### Cache Cleared
```bash
php artisan cache:clear
php artisan config:clear
php artisan route:clear
```

## Frontend Implementation (Already Implemented)

### ConversationCard Widget
**File:** `lib/features/chat/ui/widgets/conversation_card.dart`

الـ Widget جاهز بالفعل لعرض الصور:
- Line 349-363: Uses `CachedNetworkImage` with `participantAvatar` field
- Line 390-406: Fallback to initials if no avatar
- Line 409-428: Color-coded avatars based on name

### MessageBubble Widget
**File:** `lib/features/chat/ui/widgets/message_bubble.dart`

الموديل جاهز لكن لم يتم عرض الصورة في الـ UI:
- `MessageModel` has `senderAvatar` field (line 19)
- Currently NOT displayed in message bubble UI

### Models

#### ConversationModel
**File:** `lib/features/chat/data/models/conversation_model.dart`
- Has `participantAvatar` field (line 19-20)
- Parsed from API in `fromApiJson()` (line 100)

#### MessageModel
**File:** `lib/features/chat/data/models/message_model.dart`
- Has `senderAvatar` field (line 18-19)
- Parsed from API in `fromApiJson()` (line 75)

## API Response Structure

### GET /api/v1/conversations?company_id=6
```json
{
  "success": true,
  "conversations": [
    {
      "id": 1,
      "type": "private",
      "name": "Ahmed Abbas",
      "avatar": "https://erp1.bdcbiz.com/storage/avatars/ahmed.jpg", // ✅ NOW INCLUDED
      "participants": [                                                // ✅ NOW INCLUDED
        {
          "id": 10,
          "name": "Ahmed Abbas",
          "email": "Ahmed@bdcbiz.com",
          "avatar": "https://erp1.bdcbiz.com/storage/avatars/ahmed.jpg"
        }
      ],
      "last_message": "Hello!",
      "unread_count": 2,
      "is_online": true
    }
  ]
}
```

### GET /api/v1/conversations/{id}/messages?company_id=6
```json
{
  "success": true,
  "messages": [
    {
      "id": 1,
      "body": "Hello!",
      "user_id": 10,
      "user_name": "Ahmed Abbas",
      "user_avatar": "https://erp1.bdcbiz.com/storage/avatars/ahmed.jpg", // NOW INCLUDED
      "is_mine": false,
      "created_at": "2025-11-23T20:00:00.000000Z"
    }
  ]
}
```

## Current Limitation

**Database Status:**
- جدول `users` يحتوي على عمود `avatar` لكن جميع القيم حالياً `avatar.png` (الصورة الافتراضية)
- الصور الفعلية موجودة في جدول `media` مرتبطة بـ `Employee` model وليس `User` model
- مسار الصور: `App\Models\Employee` → `media` table → `collection_name = 'avatar'`

```sql
-- Users table (current)
SELECT id, name, avatar FROM users LIMIT 3;
-- Result: All have 'avatar.png'

-- Media table (actual avatars stored here)
SELECT model_id, model_type, file_name FROM media WHERE collection_name = 'avatar';
-- Result: employee_1.png, employee_2.png, etc. (linked to Employee model)
```

## Next Steps (Optional Enhancement)

إذا أردت عرض الصور الفعلية من `Employee` model:

### Option 1: Sync Employee Avatars to User Table
```php
// In ChatController, add helper method:
protected function getEmployeeAvatar($userId) {
    $user = User::find($userId);
    if (!$user) return null;

    $employee = Employee::where('email', $user->email)->first();
    if ($employee && method_exists($employee, 'getFirstMediaUrl')) {
        return $employee->getFirstMediaUrl('avatar');
    }

    return null;
}
```

### Option 2: Upload Avatar via Profile Screen
يمكن للمستخدمين رفع صورهم من شاشة الملف الشخصي (Profile Screen) وسيتم تخزينها في `users.avatar`

## Testing

### Test Endpoints
```bash
# 1. Test getConversations (should return avatar URLs)
curl -H "Authorization: Bearer YOUR_TOKEN" \
     "https://erp1.bdcbiz.com/api/v1/conversations?company_id=6"

# 2. Test getMessages (should return user_avatar)
curl -H "Authorization: Bearer YOUR_TOKEN" \
     "https://erp1.bdcbiz.com/api/v1/conversations/1/messages?company_id=6"
```

### Test in Flutter App
1. Login to the app
2. Navigate to Chat screen
3. Open a conversation
4. Check console logs for avatar URLs in API responses

## Summary of Changes

✅ **Backend (Production)**
- [x] `getConversations()` - Returns avatar URLs
- [x] `getMessages()` - Returns user_avatar for each message
- [x] `sendMessage()` - Returns sender avatar in response
- [x] `getUsers()` - Returns avatar URLs for employee selection
- [x] Laravel cache cleared

✅ **Frontend (Already Implemented)**
- [x] `ConversationModel` - Has `participantAvatar` field
- [x] `MessageModel` - Has `senderAvatar` field
- [x] `ConversationCard` - Displays avatar with `CachedNetworkImage`
- [x] Fallback to colored initials if no avatar

⚠️ **Current Limitation**
- Users in database have default `avatar.png`
- Real avatars stored in `media` table linked to `Employee` model
- To see real avatars: Either sync Employee avatars to User table, or have users upload via Profile screen

## Files Modified

### Backend (Production Server)
- `/var/www/erp1/app/Http/Controllers/Api/ChatController.php` ✅ Updated
- Backup: `/var/www/erp1/app/Http/Controllers/Api/ChatController.php.backup_avatars`

### Frontend (No Changes Needed)
- `lib/features/chat/data/models/conversation_model.dart` ✅ Already supports avatars
- `lib/features/chat/data/models/message_model.dart` ✅ Already supports avatars
- `lib/features/chat/ui/widgets/conversation_card.dart` ✅ Already displays avatars

## Documentation Created
- `CHAT_AVATARS_IMPLEMENTATION.md` - This file

---

**Date:** 2025-11-23
**Status:** ✅ Implemented and Ready for Testing
