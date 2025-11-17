# 🐛 مشكلة تمييز رسائل المرسل والمستقبل

**التاريخ:** 2025-11-17
**الحالة:** 🔍 **قيد التحقيق**

---

## 🐛 المشكلة

**الوصف:**
جميع الرسائل تظهر على الشمال باللون الأبيض، ولا يوجد تمييز بين رسائل المرسل ورسائل المستقبل.

**السبب المتوقع:**
مشكلة User ID Mismatch في المقارنة:
```dart
isSentByMe: message.senderId == widget.currentUserId
```

---

## 🔍 التحقيق

### 1. Message Model:
```dart
// في message_model.dart
final int senderId;

factory MessageModel.fromApiJson(Map<String, dynamic> json) {
  return MessageModel(
    senderId: json['user_id'] as int,  // ← يأخذ من user_id في API
  );
}
```

**النتيجة:** `message.senderId` يحتوي على **user_id** من قاعدة البيانات (مثلاً: 27)

---

### 2. Current User ID:
```dart
// في main_navigation_screen.dart
final user = authState.user;
final userId = user?.id ?? 0;  // ← يأخذ من auth state

ChatListScreen(
  currentUserId: userId,  // ← يمرر لـ ChatListScreen
)
```

**المشكلة المحتملة:** `auth().user.id` قد يكون **employee_id** (مثلاً: 49) وليس **user_id** (27)!

---

### 3. المقارنة:
```dart
// في chat_room_screen.dart
MessageBubble(
  message: message,
  isSentByMe: message.senderId == widget.currentUserId,
  //           ↑ user_id (27)     ↑ employee_id (49)?
  //           ❌ لن يتطابقوا أبداً!
)
```

**النتيجة:** جميع الرسائل `isSentByMe = false` → كلها على الشمال!

---

## ✅ الحلول المقترحة

### الحل 1: Normalize currentUserId (الأفضل)

تحويل `currentUserId` من `employee_id` إلى `user_id` قبل تمريره:

```dart
// في main_navigation_screen.dart
final userId = user?.id ?? 0;

// تحويل employee_id إلى user_id
final normalizedUserId = await _normalizeUserId(userId);

ChatListScreen(
  currentUserId: normalizedUserId,  // ✅ user_id صحيح
)
```

**الفائدة:**
- ✅ يضمن تطابق IDs
- ✅ يعمل مع جميع الرسائل
- ✅ لا حاجة لتغيير MessageModel

---

### الحل 2: استخدام is_mine من API

إذا كان Backend يرسل `is_mine` field:

```dart
// في message_model.dart
final bool isMine;

factory MessageModel.fromApiJson(Map<String, dynamic> json) {
  return MessageModel(
    isMine: json['is_mine'] as bool? ?? false,  // ✅ Backend يحدد
  );
}

// في chat_room_screen.dart
MessageBubble(
  message: message,
  isSentByMe: message.isMine,  // ✅ مباشرة من API
)
```

**الفائدة:**
- ✅ لا حاجة للمقارنة في Flutter
- ✅ Backend يعرف المستخدم الحالي بدقة
- ❌ يحتاج تعديل في Backend

---

### الحل 3: Normalize في MessageModel

```dart
// في message_model.dart
bool isSentByMe(int employeeOrUserId) {
  // جرب المقارنة المباشرة أولاً
  if (senderId == employeeOrUserId) return true;

  // جرب normalize
  final normalizedId = await normalizeUserId(employeeOrUserId);
  return senderId == normalizedId;
}
```

**المشكلة:**
- ❌ يحتاج API call في UI
- ❌ سيبطئ الرسم
- ❌ غير عملي

---

## 🧪 التحقق من المشكلة

### Debug Logs المضافة:

```dart
// في main_navigation_screen.dart
print('🔍 userId from auth: $userId');
print('🔍 user email: ${user?.email}');

// في chat_room_screen.dart
print('🔍 message.senderId: ${message.senderId}');
print('🔍 widget.currentUserId: ${widget.currentUserId}');
print('🔍 isSentByMe: $isMine');
```

**الخطوات:**
1. افتح التطبيق
2. اذهب للشات
3. افتح محادثة
4. شوف الـ Console logs

**النتيجة المتوقعة:**
```
🔍 userId from auth: 49        ← employee_id
🔍 user email: Ahmed@bdcbiz.com
🔍 message.senderId: 27        ← user_id
🔍 widget.currentUserId: 49    ← employee_id
🔍 isSentByMe: false           ← ❌ خطأ!
```

---

## 📝 خطة الإصلاح

### الخطوة 1: تأكيد المشكلة
- ✅ إضافة debug logs
- ⏳ **جاري الانتظار:** المستخدم يفحص logs

### الخطوة 2: تطبيق الحل
إذا تأكدنا من المشكلة:

#### Option A: تحويل في Flutter
```dart
// أضف helper function
Future<int> _normalizeUserId(int id) async {
  // TODO: استدعاء API أو استخدام cached mapping
  return id; // placeholder
}
```

#### Option B: استخدام email للمقارنة
```dart
isSentByMe: message.senderEmail == user?.email
```

#### Option C: إصلاح Backend ليرسل is_mine
```php
// في ChatController.php
$message->is_mine = $message->user_id === $normalizedUserId;
```

---

## 🎯 التوصية

**الحل الأمثل:** استخدام `is_mine` من Backend (Option C)

**السبب:**
1. ✅ Backend يعرف المستخدم بدقة (من auth token)
2. ✅ لا حاجة لـ normalization في Flutter
3. ✅ أسرع وأكثر موثوقية
4. ✅ يعمل مع جميع الحالات

**التطبيق:**
```php
// في getMessages() method
$messages = $conversation->messages()
    ->orderBy('created_at', 'asc')
    ->get()
    ->map(function ($message) use ($normalizedUserId) {
        return [
            'id' => $message->id,
            'user_id' => $message->user_id,
            'user_name' => $message->user->name ?? 'Unknown',
            'body' => $message->body,
            'is_mine' => $message->user_id === $normalizedUserId,  // ✅ إضافة
            // ... rest of fields
        ];
    });
```

```dart
// في message_model.dart
final bool isMine;

factory MessageModel.fromApiJson(Map<String, dynamic> json) {
  return MessageModel(
    isMine: json['is_mine'] as bool? ?? false,  // ✅ قراءة
  );
}

// في chat_room_screen.dart
MessageBubble(
  message: message,
  isSentByMe: message.isMine,  // ✅ استخدام
)
```

---

**الحالة:** 🔍 **انتظار نتائج الـ Debug Logs**
**التالي:** تطبيق الحل بناءً على النتائج
