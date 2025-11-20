# Chat Sticky Date Headers Fix

## المشكلة (Problem)

في شاشة الشات، كان فيه مشكلة في عرض التواريخ:
- **Date separator** (Today, Yesterday, التاريخ) كان عادي مش ثابت
- لما تسكرول، التاريخ يختفي مع الرسائل
- الرسائل مش متجمعة صح تحت التاريخ بتاعها
- آخر رسالة بس تحت "Today" والباقي كله "Yesterday"

### Before (قبل)
```
┌─────────────────┐
│   Today         │  ← يختفي لما تسكرول
├─────────────────┤
│ Message 1       │
│ Message 2       │
├─────────────────┤
│   Yesterday     │  ← يختفي لما تسكرول
├─────────────────┤
│ Message 3       │
│ Message 4       │
└─────────────────┘
```

## الحل (Solution)

استخدام `CustomScrollView` مع `SliverPersistentHeader` لعمل **sticky headers**:
- التاريخ يفضل ثابت في أعلى الشاشة
- كل ما تسكرول، التاريخ الجديد يدفع اللي قبله
- الرسائل متجمعة صح حسب التاريخ

### After (بعد)
```
عند السكرول من أسفل لأعلى:
┌─────────────────┐
│   Today         │  ← ثابت في الأعلى (sticky)
├─────────────────┤
│ Message 1       │  ← أقدم رسالة اليوم
│ Message 2       │
│ Message 3       │  ← أحدث رسالة اليوم
├─────────────────┤
│   Yesterday     │  ← لما تسكرول يطلع ويدفع "Today"
├─────────────────┤
│ Message 4       │  ← أقدم رسالة أمس
│ Message 5       │  ← أحدث رسالة أمس
└─────────────────┘
```

**ترتيب العرض الصحيح**:
1. التاريخ في **أعلى** كل مجموعة
2. الرسائل **تحت** التاريخ (من الأقدم للأحدث)
3. لما تسكرول، التاريخ الجديد يدفع القديم لأعلى

## التغييرات التقنية (Technical Changes)

### 1. تغيير من ListView إلى CustomScrollView
```dart
// ❌ Before
ListView.builder(
  controller: scrollController,
  reverse: true,
  itemBuilder: (context, index) {
    // Date separator inline مع الرسائل
    return Column(
      children: [
        if (showDateSeparator) _buildDateSeparator(...),
        MessageBubble(...),
      ],
    );
  },
)

// ✅ After
CustomScrollView(
  controller: scrollController,
  reverse: true,
  slivers: _buildSlivers(groupedMessages),
)
```

### 2. تجميع الرسائل حسب التاريخ
```dart
/// Group messages by date
Map<String, List<MessageModel>> _groupMessagesByDate(List<MessageModel> messages) {
  final Map<String, List<MessageModel>> grouped = {};

  for (final message in messages) {
    final dateKey = _getDateKey(message.createdAt);
    if (!grouped.containsKey(dateKey)) {
      grouped[dateKey] = [];
    }
    grouped[dateKey]!.add(message);
  }

  return grouped;
}
```

### 3. إنشاء Sticky Headers بالترتيب الصحيح
```dart
/// Build slivers for CustomScrollView
List<Widget> _buildSlivers(Map<String, List<MessageModel>> groupedMessages) {
  final slivers = <Widget>[];

  // Get dates in reverse order (newest first because of reverse: true)
  final dates = groupedMessages.keys.toList().reversed.toList();

  for (final date in dates) {
    final messagesForDate = groupedMessages[date]!;

    // Reverse messages so they appear oldest to newest
    final reversedMessages = messagesForDate.reversed.toList();

    // ⚠️ IMPORTANT: Add messages FIRST, then header
    // Because CustomScrollView is reversed, this makes header appear ABOVE messages

    // 1. Messages for this date (added FIRST)
    slivers.add(
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final message = reversedMessages[index];
            return MessageBubble(...);
          },
          childCount: reversedMessages.length,
        ),
      ),
    );

    // 2. Sticky Header (added AFTER)
    // Due to reverse: true, this appears ABOVE the messages ✅
    slivers.add(
      SliverPersistentHeader(
        pinned: true, // Makes it sticky!
        delegate: _DateHeaderDelegate(
          date: date,
          isDark: isDark,
        ),
      ),
    );
  }

  return slivers;
}
```

**ملاحظة مهمة**:
- بما إن الـ `CustomScrollView` معكوس (`reverse: true`)
- نضيف الرسائل **أولاً** ثم الـ header **ثانياً**
- عند العرض المعكوس، الـ header يظهر **فوق** الرسائل ✅

### 4. Sticky Header Delegate
```dart
class _DateHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String date;
  final bool isDark;

  @override
  double get minExtent => 44.0; // ارتفاع ثابت

  @override
  double get maxExtent => 44.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(...), // خلفية شبه شفافة
        boxShadow: overlapsContent ? [...] : [], // Shadow لما يكون فوق رسائل
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF1F2C34) : Color(0xFFE1F5FE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(date, ...),
      ),
    );
  }

  @override
  bool shouldRebuild(_DateHeaderDelegate oldDelegate) {
    return date != oldDelegate.date || isDark != oldDelegate.isDark;
  }
}
```

## المميزات (Features)

### ✅ Sticky Headers
- التاريخ يفضل ثابت في أعلى الشاشة
- لما تسكرول، التاريخ التالي يدفع اللي قبله
- تجربة مستخدم زي WhatsApp تماماً

### ✅ تجميع صحيح
- كل رسائل نفس اليوم تحت نفس التاريخ
- "Today" للرسائل اليوم
- "Yesterday" لأمس
- التاريخ الكامل للأيام الأقدم (MMM dd, yyyy)

### ✅ تصميم محسّن
- Gradient background للـ header (شبه شفاف)
- Shadow لما الـ header يكون فوق رسائل (`overlapsContent`)
- متوافق مع Dark/Light mode
- Animation سلس عند التبديل

## الملفات المعدّلة
- ✅ `lib/features/chat/ui/widgets/chat_messages_list_widget.dart`

## كيفية الاختبار (Testing)

### Test Steps
1. افتح محادثة فيها رسائل من أيام مختلفة
2. اسكرول لأعلى ولأسفل
3. لاحظ:
   - ✅ التاريخ يفضل ثابت في الأعلى
   - ✅ لما توصل لتاريخ جديد، يطلع فوق ويدفع القديم
   - ✅ الرسائل متجمعة صح تحت التواريخ بتاعتها
   - ✅ "Today" للرسائل اليوم فقط
   - ✅ "Yesterday" لأمس فقط
   - ✅ التاريخ الكامل للأيام الأقدم

### Expected Behavior
```
عند السكرول لأعلى:
┌─────────────────┐
│   Today         │ ← ثابت
│ Message 1       │
│ Message 2       │ ← تسكرول
│ ...             │
├─ Yesterday ─────┤ ← يطلع تدريجياً
│ Message 3       │
│ ...             │
├─ Dec 15, 2024 ─┤ ← يدفع "Yesterday"
│ Message 4       │
└─────────────────┘
```

## كيف يعمل Sticky Headers؟

### SliverPersistentHeader
```dart
SliverPersistentHeader(
  pinned: true,  // ✅ يخلي الـ header "يلتصق" في أعلى الشاشة
  delegate: _DateHeaderDelegate(...),
)
```

**كيف يعمل `pinned: true`؟**
1. لما الـ header يوصل لأعلى viewport (الشاشة المرئية)
2. يفضل "ملتصق" هناك بدل ما يسكرول ويختفي
3. لما تيجي header جديد، يدفع القديم لفوق
4. ده بيعمل تجربة WhatsApp-style

### overlapsContent Parameter
```dart
Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
  // overlapsContent = true لما الـ header فوق محتوى تاني
  boxShadow: overlapsContent ? [BoxShadow(...)] : [],
}
```

**الفايدة**:
- لما الـ header يكون فوق رسائل، يظهر shadow
- يعطي إحساس بالعمق (depth)
- يوضح إن الـ header "طافي" فوق الرسائل

## الفرق بين ListView و CustomScrollView

### ListView.builder
```dart
// ✅ مناسب لـ: قوائم بسيطة، كل الـ items متشابهة
ListView.builder(
  itemBuilder: (context, index) {
    return ListTile(...);
  },
)
```

### CustomScrollView with Slivers
```dart
// ✅ مناسب لـ: قوائم معقدة، headers ثابتة، layouts مختلفة
CustomScrollView(
  slivers: [
    SliverPersistentHeader(...),  // Sticky header
    SliverList(...),               // قائمة رسائل
    SliverPersistentHeader(...),  // Sticky header تاني
    SliverList(...),               // قائمة رسائل تانية
  ],
)
```

## Performance Notes

### ✅ Efficient
- `SliverList` with `SliverChildBuilderDelegate` = lazy loading
- فقط الـ items المرئية يتم بناؤها
- Memory efficient حتى مع آلاف الرسائل

### ✅ Smooth Scrolling
- Flutter's Sliver framework محسّن للأداء
- 60 FPS على معظم الأجهزة
- No jank أو lag

## Dark Mode Support

الـ sticky headers تتغير حسب الـ theme:

### Light Mode
```dart
gradient: LinearGradient(
  colors: [
    Color(0xFFECE5DD).withOpacity(0.95), // خلفية الشات الفاتحة
    Color(0xFFECE5DD).withOpacity(0.90),
  ],
)
```

### Dark Mode
```dart
gradient: LinearGradient(
  colors: [
    Color(0xFF0B141A).withOpacity(0.95), // خلفية الشات الداكنة
    Color(0xFF0B141A).withOpacity(0.90),
  ],
)
```

## Future Improvements (تحسينات مستقبلية)

### 1. Animated Transitions
يمكن إضافة animation لما header جديد يطلع:
```dart
AnimatedOpacity(
  opacity: overlapsContent ? 1.0 : 0.0,
  duration: Duration(milliseconds: 200),
  child: BoxShadow(...),
)
```

### 2. Jump to Date
إضافة زر للقفز لتاريخ معين:
```dart
void jumpToDate(String date) {
  // Find index of first message for that date
  // Scroll to that position
}
```

### 3. Today/Yesterday Badge
إضافة badge يقول كام رسالة جديدة:
```dart
Text(
  'Today (5 new)',
  style: ...,
)
```

## Troubleshooting

### مشكلة: Headers مش بتظهر
**الحل**: تأكد إن messages متجمعة صح:
```dart
final groupedMessages = _groupMessagesByDate(messages);
print(groupedMessages.keys); // ['Today', 'Yesterday', ...]
```

### مشكلة: Headers مش sticky
**الحل**: تأكد من `pinned: true`:
```dart
SliverPersistentHeader(
  pinned: true, // ✅ مهم جداً!
  delegate: ...,
)
```

### مشكلة: Performance بطيء
**الحل**: استخدم `addAutomaticKeepAlives: false`:
```dart
SliverChildBuilderDelegate(
  (context, index) => ...,
  childCount: ...,
  addAutomaticKeepAlives: false, // لو مش محتاج state preservation
)
```

## تاريخ التعديل
2025-11-19

## Status
✅ Implemented and tested successfully
