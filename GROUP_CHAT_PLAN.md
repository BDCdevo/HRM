# 📋 خطة تطبيق ميزة المجموعات (Group Chat)

**التاريخ:** 2025-11-17
**الهدف:** تطبيق نظام المجموعات بنفس أسلوب WhatsApp

---

## 🎯 المتطلبات

### ميزات WhatsApp المطلوب تطبيقها:
1. ✅ زر "New Group" في شاشة اختيار الموظف
2. ✅ اختيار عدة موظفين (Multiple Selection)
3. ✅ إدخال اسم المجموعة وصورة اختيارية
4. ✅ إنشاء المجموعة وبدء المحادثة
5. ✅ عرض المجموعات في قائمة المحادثات
6. ✅ عرض أسماء المرسلين في رسائل المجموعة
7. ✅ شاشة تفاصيل المجموعة (أعضاء، إعدادات)

---

## 📊 التحليل الحالي

### ✅ Backend - جاهز 100%!

#### API Endpoints الموجودة:

**1. إنشاء محادثة/مجموعة:**
```
POST /api/v1/conversations
Body:
{
  "company_id": 6,
  "user_ids": [27, 30, 35],  // Array من الموظفين
  "type": "group",           // "private" أو "group"
  "name": "فريق التطوير"     // اسم المجموعة (مطلوب للـ group)
}
```

**2. جلب قائمة الموظفين:**
```
GET /api/v1/users?company_id=6
```

**3. جلب المحادثات (تدعم المجموعات):**
```
GET /api/v1/conversations?company_id=6
Response:
{
  "conversations": [
    {
      "id": 28,
      "type": "group",
      "name": "فريق التطوير",
      "participants": [...],
      "unread_count": 5
    }
  ]
}
```

**4. إرسال/استقبال رسائل في المجموعة:**
```
GET /api/v1/conversations/28/messages?company_id=6
POST /api/v1/conversations/28/messages
```

### ✅ Database - جاهز!

**conversations table:**
- `type`: 'private' أو 'group'
- `name`: اسم المجموعة (NULL للـ private)
- `description`: وصف المجموعة

**conversation_participants table:**
- `role`: 'admin' أو 'member'
- `joined_at`: وقت الانضمام

**messages table:**
- تدعم المجموعات بالفعل
- `read_by`: JSON array لتتبع القراءة لكل عضو

---

## 🚀 خطة التنفيذ

### المرحلة 1: تحسين شاشة اختيار نوع الشات ✅
**الملف:** `employee_selection_screen.dart`

**التعديلات المطلوبة:**
1. إضافة زر "New Group" في الـ AppBar
2. تحويل الشاشة لدعم:
   - **Single Selection** → Private Chat
   - **Multiple Selection** → Group Chat

**التصميم المقترح:**
```dart
AppBar(
  title: Text('New Chat'),
  actions: [
    TextButton(
      onPressed: () => _navigateToGroupCreation(),
      child: Text('New Group', style: TextStyle(color: Colors.white)),
    ),
  ],
)
```

---

### المرحلة 2: شاشة إنشاء المجموعة 🆕
**ملف جديد:** `group_creation_screen.dart`

**الخطوات:**
1. **Step 1: Add Group Participants** (اختيار الأعضاء)
   - Multi-select من قائمة الموظفين
   - عرض الأعضاء المختارين في الأعلى (Chips)
   - زر "Next" للخطوة التالية

2. **Step 2: Group Subject** (اسم وصورة المجموعة)
   - TextField لاسم المجموعة (مطلوب)
   - زر لإضافة صورة المجموعة (اختياري)
   - زر "Create" لإنشاء المجموعة

**UI Components:**
```dart
// Step 1: Add Participants
- SearchBar
- Selected Members Chips (Scrollable Horizontal)
- Employee List (Multi-select Checkboxes)
- FloatingActionButton: "Next" (when >= 1 selected)

// Step 2: Group Subject
- Circle Avatar (placeholder + image picker)
- TextField: Group Name
- TextField: Description (optional)
- Button: "Create Group"
```

---

### المرحلة 3: تحديث Chat List Screen ✅
**الملف:** `chat_list_screen.dart`

**التعديلات:**
1. عرض المجموعات مع أيقونة مميزة
2. عرض اسم المجموعة بدلاً من اسم المشارك
3. عرض عدد الأعضاء تحت الاسم (اختياري)

**مثال:**
```dart
// في ConversationCard
leading: conversation.type == 'group'
    ? CircleAvatar(
        child: Icon(Icons.group),
        backgroundColor: AppColors.primary,
      )
    : CircleAvatar(
        backgroundImage: NetworkImage(avatar),
      ),

title: conversation.type == 'group'
    ? conversation.name
    : conversation.participantName,

subtitle: conversation.type == 'group'
    ? '${conversation.participantsCount} members • ${lastMessage}'
    : lastMessage,
```

---

### المرحلة 4: تحديث Chat Room Screen ✅
**الملف:** `chat_room_screen.dart`

**التعديلات:**
1. عرض اسم المجموعة في الـ AppBar
2. عرض اسم المرسل فوق كل رسالة (للمجموعات فقط)
3. زر Group Info في الـ AppBar

**مثال:**
```dart
// في MessageBubble - للمجموعات فقط
if (isGroupChat && !isSentByMe) {
  Padding(
    padding: EdgeInsets.only(bottom: 4),
    child: Text(
      message.senderName,
      style: TextStyle(
        color: _getColorForUser(message.senderId),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
}
```

---

### المرحلة 5: شاشة تفاصيل المجموعة 🆕
**ملف جديد:** `group_info_screen.dart`

**المحتويات:**
1. **Header:**
   - صورة المجموعة (قابلة للتعديل من Admin)
   - اسم المجموعة (قابل للتعديل من Admin)
   - عدد الأعضاء

2. **Participants Section:**
   - قائمة بجميع الأعضاء
   - عرض دور كل عضو (Admin/Member)
   - زر "Add Participant" (للـ Admin فقط)
   - زر "Remove" بجانب كل عضو (للـ Admin فقط)

3. **Actions:**
   - Mute Notifications
   - Exit Group
   - Delete Group (للـ Admin فقط)

**UI Layout:**
```dart
Column(
  children: [
    // Header
    GroupHeader(
      avatar: groupAvatar,
      name: groupName,
      membersCount: members.length,
    ),

    // Add Participant (Admin only)
    if (isAdmin)
      ListTile(
        leading: Icon(Icons.person_add),
        title: Text('Add participant'),
        onTap: () => _addParticipant(),
      ),

    // Participants List
    Text('$membersCount participants'),
    ListView.builder(
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return ParticipantTile(
          member: member,
          isAdmin: isAdmin,
          onRemove: () => _removeMember(member),
        );
      },
    ),

    // Actions
    ListTile(
      leading: Icon(Icons.exit_to_app, color: Colors.red),
      title: Text('Exit group', style: TextStyle(color: Colors.red)),
      onTap: () => _exitGroup(),
    ),
  ],
)
```

---

## 📁 هيكل الملفات الجديدة

```
lib/features/chat/
├── ui/
│   ├── screens/
│   │   ├── chat_list_screen.dart              # ✅ موجود - يحتاج تحديث
│   │   ├── employee_selection_screen.dart      # ✅ موجود - يحتاج تحديث
│   │   ├── chat_room_screen.dart              # ✅ موجود - يحتاج تحديث
│   │   ├── group_creation_screen.dart         # 🆕 جديد
│   │   └── group_info_screen.dart             # 🆕 جديد
│   └── widgets/
│       ├── conversation_card.dart              # ✅ موجود - يحتاج تحديث
│       ├── message_bubble.dart                 # ✅ موجود - يحتاج تحديث
│       ├── group_avatar_widget.dart            # 🆕 جديد
│       ├── participant_tile_widget.dart        # 🆕 جديد
│       └── selected_members_chips.dart         # 🆕 جديد
```

---

## 🎨 تصميم WhatsApp Style

### الألوان:
```dart
// Group Colors (for sender names)
static const List<Color> groupMemberColors = [
  Color(0xFF00A884), // WhatsApp Green
  Color(0xFF0088CC), // Blue
  Color(0xFFFF8800), // Orange
  Color(0xFF9C27B0), // Purple
  Color(0xFFE91E63), // Pink
  Color(0xFF009688), // Teal
  Color(0xFFFF5722), // Deep Orange
];

Color getColorForUser(int userId) {
  return groupMemberColors[userId % groupMemberColors.length];
}
```

### الأيقونات:
- 👥 Group Icon: `Icons.group`
- ➕ Add Member: `Icons.person_add`
- 🚪 Exit Group: `Icons.exit_to_app`
- 🔕 Mute: `Icons.notifications_off`

---

## 🔄 User Flow (WhatsApp Style)

### إنشاء مجموعة جديدة:
```
1. User → Chat List Screen
   ↓
2. Click: FloatingActionButton (New Chat)
   ↓
3. Employee Selection Screen
   ↓
4. Click: "New Group" button (AppBar)
   ↓
5. Group Creation Screen - Step 1
   - Select participants (multi-select)
   - Show selected chips at top
   - Click: "Next" FAB
   ↓
6. Group Creation Screen - Step 2
   - Enter group name
   - Upload group image (optional)
   - Click: "Create Group"
   ↓
7. API: POST /conversations
   {
     "type": "group",
     "user_ids": [27, 30, 35],
     "name": "فريق التطوير"
   }
   ↓
8. Navigate to Chat Room Screen
   - Show group chat
   - Display sender names
```

### فتح تفاصيل المجموعة:
```
Chat Room Screen → AppBar → Group Info Icon
   ↓
Group Info Screen
   - View/Edit group details
   - Manage participants
   - Group actions
```

---

## ✅ Checklist التنفيذ

### Phase 1: UI Components (يوم 1)
- [ ] تحديث `employee_selection_screen.dart`
  - [ ] إضافة زر "New Group"
  - [ ] تحويل لـ Multi-select mode
- [ ] إنشاء `group_creation_screen.dart`
  - [ ] Step 1: Select participants
  - [ ] Step 2: Group subject
- [ ] إنشاء Widgets:
  - [ ] `selected_members_chips.dart`
  - [ ] `group_avatar_widget.dart`

### Phase 2: Group List & Chat (يوم 2)
- [ ] تحديث `conversation_card.dart`
  - [ ] عرض أيقونة المجموعة
  - [ ] عرض عدد الأعضاء
- [ ] تحديث `chat_room_screen.dart`
  - [ ] عرض اسم المجموعة
  - [ ] إضافة Group Info button
- [ ] تحديث `message_bubble.dart`
  - [ ] عرض اسم المرسل (للمجموعات)
  - [ ] ألوان مميزة لكل مرسل

### Phase 3: Group Management (يوم 3)
- [ ] إنشاء `group_info_screen.dart`
  - [ ] عرض تفاصيل المجموعة
  - [ ] قائمة الأعضاء
  - [ ] إضافة/حذف أعضاء
  - [ ] الخروج من المجموعة
- [ ] إنشاء `participant_tile_widget.dart`

### Phase 4: Testing & Polish
- [ ] اختبار إنشاء مجموعة
- [ ] اختبار إرسال رسائل في المجموعة
- [ ] اختبار إضافة/حذف أعضاء
- [ ] اختبار read receipts للمجموعات
- [ ] إصلاح الأخطاء

---

## 🎯 الخلاصة

### ما هو موجود:
✅ Backend كامل وجاهز
✅ Database تدعم المجموعات
✅ APIs جاهزة

### ما يحتاج تطبيق:
🆕 UI Screens جديدة (2 شاشات)
🔄 تحديثات على شاشات موجودة (3 شاشات)
🆕 Widgets جديدة (3 components)

### التقدير الزمني:
- **Phase 1:** 4-6 ساعات
- **Phase 2:** 3-4 ساعات
- **Phase 3:** 3-4 ساعات
- **Phase 4:** 2-3 ساعات

**الإجمالي:** 2-3 أيام عمل

---

**جاهز للبدء؟** 🚀
