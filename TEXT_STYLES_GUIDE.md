# 📖 دليل استخدام أنماط النصوص (TextStyles Guide)

## نظرة عامة

تم توحيد جميع أنماط النصوص في التطبيق باستخدام `AppTextStyles`. هذا الدليل يوضح كيفية استخدام هذه الأنماط بشكل صحيح.

---

## ⚡ القواعد الأساسية

### ✅ **استخدم دائماً**
```dart
import '../../../../core/styles/app_text_styles.dart';

Text(
  'Welcome Back',
  style: AppTextStyles.welcomeTitle.copyWith(
    color: textColor,
  ),
)
```

### ❌ **لا تستخدم أبداً**
```dart
Text(
  'Welcome Back',
  style: TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: textColor,
  ),
)
```

---

## 📋 الأنماط المتاحة

### 1. **Display Styles** (العناوين الضخمة - نادرة الاستخدام)

```dart
AppTextStyles.displayLarge   // 57px, w400
AppTextStyles.displayMedium  // 45px, w400
AppTextStyles.displaySmall   // 36px, w400
```

**الاستخدام:**
- شاشات الترحيب الكبيرة
- Splash screens
- شاشات Empty states كبيرة

---

### 2. **Headline Styles** (العناوين الرئيسية)

```dart
AppTextStyles.headlineLarge  // 32px, w600
AppTextStyles.headlineMedium // 28px, w600
AppTextStyles.headlineSmall  // 24px, w600
```

**الاستخدام:**
```dart
// عناوين الصفحات الرئيسية
Text(
  'Dashboard',
  style: AppTextStyles.headlineMedium.copyWith(
    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
  ),
)
```

---

### 3. **Title Styles** (العناوين الفرعية)

```dart
AppTextStyles.titleLarge   // 22px, w600
AppTextStyles.titleMedium  // 16px, w600
AppTextStyles.titleSmall   // 14px, w600
```

**الاستخدام:**
```dart
// عناوين الكروت والأقسام
Text(
  'Today\'s Attendance',
  style: AppTextStyles.titleLarge.copyWith(
    color: AppColors.textPrimary,
  ),
)
```

---

### 4. **Body Styles** (النصوص العادية)

```dart
AppTextStyles.bodyLarge   // 16px, w400
AppTextStyles.bodyMedium  // 14px, w400
AppTextStyles.bodySmall   // 12px, w400
```

**الاستخدام:**
```dart
// النصوص العادية والفقرات
Text(
  'Sign in to continue',
  style: AppTextStyles.bodyMedium.copyWith(
    color: AppColors.textSecondary,
  ),
)
```

---

### 5. **Label Styles** (التسميات)

```dart
AppTextStyles.labelLarge   // 14px, w500
AppTextStyles.labelMedium  // 12px, w500
AppTextStyles.labelSmall   // 11px, w500
```

**الاستخدام:**
```dart
// تسميات الحقول والأزرار الصغيرة
Text(
  'Email',
  style: AppTextStyles.labelLarge.copyWith(
    color: AppColors.textSecondary,
  ),
)
```

---

### 6. **Button Styles** (أزرار)

```dart
AppTextStyles.button       // 16px, w600, white
AppTextStyles.buttonSmall  // 14px, w600, white
```

**الاستخدام:**
```dart
ElevatedButton(
  onPressed: () {},
  child: Text(
    'Login',
    style: AppTextStyles.button,  // لا تحتاج copyWith - اللون أبيض بالفعل
  ),
)
```

---

### 7. **Input/Form Styles** (حقول الإدخال)

```dart
AppTextStyles.inputText    // 16px, w400 - النص داخل الحقل
AppTextStyles.inputLabel   // 14px, w500 - تسمية الحقل
AppTextStyles.inputHint    // 16px, w400, tertiary - placeholder
AppTextStyles.inputError   // 12px, w400, error - رسائل الخطأ
AppTextStyles.inputHelper  // 12px, w400, tertiary - نص المساعدة
```

**الاستخدام:**
```dart
// تسمية الحقل
Text(
  'Email',
  style: AppTextStyles.inputLabel.copyWith(
    color: secondaryTextColor,
  ),
)

// الحقل نفسه
TextField(
  style: AppTextStyles.inputText.copyWith(
    color: textColor,
  ),
  decoration: InputDecoration(
    hintText: 'Enter your email',
    hintStyle: AppTextStyles.inputHint.copyWith(
      color: secondaryTextColor.withOpacity(0.6),
    ),
  ),
)
```

---

### 8. **Form Styles** (النماذج)

```dart
AppTextStyles.formTitle        // 18px, w700 - عنوان النموذج
AppTextStyles.formDescription  // 14px, w400 - وصف النموذج
```

**الاستخدام:**
```dart
Text(
  'Personal Information',
  style: AppTextStyles.formTitle,
)

Text(
  'Please fill in your details below',
  style: AppTextStyles.formDescription,
)
```

---

### 9. **Chat & Messaging Styles** 💬

```dart
AppTextStyles.messageText          // 15px, w400 - نص الرسالة
AppTextStyles.messageTime          // 11px, w400 - وقت الرسالة
AppTextStyles.conversationTitle    // 16px, w600 - عنوان المحادثة
AppTextStyles.conversationSubtitle // 13px, w400 - آخر رسالة
AppTextStyles.voiceTimer           // 14px, w500 - عداد الصوت
```

**الاستخدام:**
```dart
// رسالة الشات
Text(
  message.text,
  style: AppTextStyles.messageText.copyWith(
    color: isSentByMe ? Colors.white : AppColors.textPrimary,
  ),
)

// وقت الرسالة
Text(
  '10:30 AM',
  style: AppTextStyles.messageTime.copyWith(
    color: AppColors.textTertiary,
  ),
)
```

---

### 10. **Greeting & Welcome Styles** 👋

```dart
AppTextStyles.greeting         // 12px, w400, white - التحية
AppTextStyles.userName         // 22px, w700, white - اسم المستخدم
AppTextStyles.welcomeTitle     // 26px, w700 - عنوان الترحيب
AppTextStyles.welcomeSubtitle  // 16px, w400 - نص فرعي
```

**الاستخدام:**
```dart
// في Dashboard
Text(
  'Good Morning',
  style: AppTextStyles.greeting.copyWith(
    color: AppColors.white.withOpacity(0.7),
  ),
)

Text(
  user.name,
  style: AppTextStyles.userName,  // أبيض بالفعل
)

// في Login Screen
Text(
  'Welcome Back',
  style: AppTextStyles.welcomeTitle.copyWith(
    color: textColor,
  ),
)
```

---

### 11. **Stats & Numbers Styles** 📊

```dart
AppTextStyles.statNumberLarge  // 28px, w700 - رقم كبير
AppTextStyles.statNumberMedium // 20px, w600 - رقم متوسط
AppTextStyles.statLabel        // 12px, w400 - تسمية الإحصائية
```

**الاستخدام:**
```dart
// عدد الموظفين الحاضرين
Text(
  '42',
  style: AppTextStyles.statNumberLarge.copyWith(
    color: AppColors.success,
  ),
)

Text(
  'Present',
  style: AppTextStyles.statLabel,
)
```

---

### 12. **Timer & Counter Styles** ⏱️

```dart
AppTextStyles.timerLarge  // 24px, w600
AppTextStyles.timerMedium // 18px, w600
AppTextStyles.timerSmall  // 14px, w500
```

**الاستخدام:**
```dart
// عداد الحضور
Text(
  '08:32:15',
  style: AppTextStyles.timerLarge.copyWith(
    color: AppColors.primary,
  ),
)

// عداد التسجيل الصوتي
Text(
  '0:42',
  style: AppTextStyles.voiceTimer.copyWith(
    color: AppColors.textPrimary,
  ),
)
```

---

### 13. **Badge & Chip Styles** 🏷️

```dart
AppTextStyles.badgeText  // 10px, w600, white - بادج
AppTextStyles.chipText   // 12px, w500 - شريحة
```

**الاستخدام:**
```dart
// عدد الإشعارات
Container(
  child: Text(
    '5',
    style: AppTextStyles.badgeText,  // أبيض بالفعل
  ),
)

// Chip/Tag
Chip(
  label: Text(
    'Approved',
    style: AppTextStyles.chipText,
  ),
)
```

---

### 14. **Menu & List Styles** 📝

```dart
AppTextStyles.menuItem     // 14px, w500 - عنصر القائمة
AppTextStyles.listTitle    // 16px, w600 - عنوان القائمة
AppTextStyles.listSubtitle // 13px, w400 - نص فرعي
```

**الاستخدام:**
```dart
// PopupMenuItem
PopupMenuItem(
  child: Text(
    'Edit',
    style: AppTextStyles.menuItem,
  ),
)

// ListTile
ListTile(
  title: Text(
    'Ahmed Mohamed',
    style: AppTextStyles.listTitle,
  ),
  subtitle: Text(
    'Developer',
    style: AppTextStyles.listSubtitle,
  ),
)
```

---

### 15. **Calendar & Date Styles** 📅

```dart
AppTextStyles.calendarDay    // 14px, w500
AppTextStyles.calendarHeader // 16px, w600
AppTextStyles.dateLabel      // 13px, w400
```

**الاستخدام:**
```dart
// رقم اليوم
Text(
  '15',
  style: AppTextStyles.calendarDay.copyWith(
    color: isSelected ? Colors.white : AppColors.textPrimary,
  ),
)

// شهر/سنة
Text(
  'January 2025',
  style: AppTextStyles.calendarHeader,
)
```

---

### 16. **Special Styles** ✨

```dart
AppTextStyles.link     // 14px, w500, primary, underline
AppTextStyles.caption  // 12px, w400, secondary
AppTextStyles.overline // 10px, w500, tertiary - نص علوي صغير
```

**الاستخدام:**
```dart
// رابط
TextButton(
  onPressed: () {},
  child: Text(
    'Forgot Password?',
    style: AppTextStyles.link,
  ),
)

// caption
Text(
  '© 2025 BDC. All rights reserved',
  style: AppTextStyles.caption,
)
```

---

## 🎨 الألوان الجديدة (WhatsApp Colors)

### Light Mode:
```dart
AppColors.whatsappGrayDark     // 0xFF667781
AppColors.whatsappGrayMedium   // 0xFF54656F
AppColors.whatsappGrayLight    // 0xFF8696A0
AppColors.whatsappBlack        // 0xFF111B21
AppColors.whatsappSentBubble   // 0xFFD9FDD3 (فقاعة الإرسال)
AppColors.whatsappReceivedBubble // 0xFFFFFFFF (فقاعة الاستقبال)
```

### Dark Mode:
```dart
AppColors.darkWhatsappSentBubble     // 0xFF005C4B
AppColors.darkWhatsappReceivedBubble // 0xFF1F2C33
AppColors.darkWhatsappGray           // 0xFF8696A0
AppColors.darkWhatsappText           // 0xFFE9EDEF
```

**الاستخدام:**
```dart
// استبدل الألوان المشفرة
// ❌ قبل
color: Color(0xFF8696A0)

// ✅ بعد
color: isDark ? AppColors.darkWhatsappGray : AppColors.whatsappGrayLight
```

---

## 🔄 أمثلة كاملة للتحويل

### مثال 1: Login Screen

#### ❌ قبل:
```dart
Text(
  'Welcome Back',
  style: TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: textColor,
  ),
)
```

#### ✅ بعد:
```dart
Text(
  'Welcome Back',
  style: AppTextStyles.welcomeTitle.copyWith(
    color: textColor,
  ),
)
```

---

### مثال 2: Input Field

#### ❌ قبل:
```dart
TextField(
  style: TextStyle(
    fontSize: 15,
    color: textColor,
  ),
  decoration: InputDecoration(
    hintText: 'Enter email',
    hintStyle: TextStyle(
      fontSize: 16,
      color: Colors.grey,
    ),
  ),
)
```

#### ✅ بعد:
```dart
TextField(
  style: AppTextStyles.inputText.copyWith(
    color: textColor,
  ),
  decoration: InputDecoration(
    hintText: 'Enter email',
    hintStyle: AppTextStyles.inputHint.copyWith(
      color: secondaryTextColor.withOpacity(0.6),
    ),
  ),
)
```

---

### مثال 3: Chat Message

#### ❌ قبل:
```dart
Text(
  message.text,
  style: TextStyle(
    fontSize: 15,
    color: isSentByMe ? Colors.white : Color(0xFF1F2937),
  ),
)

Text(
  '10:30 AM',
  style: TextStyle(
    fontSize: 11,
    color: Color(0xFF667781),
  ),
)
```

#### ✅ بعد:
```dart
Text(
  message.text,
  style: AppTextStyles.messageText.copyWith(
    color: isSentByMe ? Colors.white : AppColors.textPrimary,
  ),
)

Text(
  '10:30 AM',
  style: AppTextStyles.messageTime.copyWith(
    color: isDark ? AppColors.darkWhatsappGray : AppColors.whatsappGrayDark,
  ),
)
```

---

## 📌 نصائح مهمة

### 1. **استخدم copyWith فقط عند الحاجة**
```dart
// ✅ جيد - استخدم النمط مباشرة
Text('Login', style: AppTextStyles.button)

// ✅ جيد - استخدم copyWith للتعديل
Text(
  'Login',
  style: AppTextStyles.button.copyWith(color: Colors.red),
)

// ❌ سيء - لا داعي لـ copyWith
Text(
  'Login',
  style: AppTextStyles.button.copyWith(),
)
```

### 2. **استخدم الألوان من AppColors**
```dart
// ✅ جيد
color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary

// ❌ سيء
color: Color(0xFF1F2937)
```

### 3. **دعم Dark Mode**
```dart
// ✅ جيد - يدعم الوضع الليلي
Text(
  'Hello',
  style: AppTextStyles.bodyLarge.copyWith(
    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
  ),
)
```

### 4. **لا تعدل fontSize إلا للضرورة**
```dart
// ✅ مفضل - استخدم النمط كما هو
Text('Title', style: AppTextStyles.titleMedium)

// ⚠️ مقبول لكن تجنبه - إذا كنت تحتاج حجم مخصص
Text(
  'Title',
  style: AppTextStyles.titleMedium.copyWith(fontSize: 17),
)
```

---

## 🛠️ الملفات المحدّثة

### ✅ تم التحديث:
1. ✅ `lib/core/styles/app_text_styles.dart` - إضافة 30+ نمط جديد
2. ✅ `lib/core/styles/app_colors.dart` - إضافة ألوان WhatsApp
3. ✅ `lib/features/auth/ui/screens/login_screen.dart` - 8 تحديثات
4. ✅ `lib/features/chat/ui/widgets/chat_input_bar_widget.dart` - 2 تحديث
5. ✅ `lib/features/chat/ui/widgets/voice_recording_widget.dart` - 2 تحديث

### ⏳ قيد الانتظار (TODO):
- `lib/features/attendance/ui/screens/attendance_summary_screen.dart` (24 تحديث)
- `lib/features/holidays/ui/screens/holidays_screen.dart` (4 تحديثات)
- `lib/core/widgets/error_widgets.dart` (3 تحديثات)
- ملفات Chat الأخرى (message_bubble, conversation_card)

---

## 📚 المراجع

- **AppTextStyles**: `lib/core/styles/app_text_styles.dart`
- **AppColors**: `lib/core/styles/app_colors.dart`
- **CLAUDE.md**: دليل المشروع الكامل

---

## 🎯 الخلاصة

### قواعد ذهبية:
1. ✅ **استخدم دائماً** `AppTextStyles.*`
2. ✅ **استخدم دائماً** `AppColors.*`
3. ✅ **استخدم** `.copyWith()` فقط عند الحاجة
4. ✅ **دعم Dark Mode** في كل نمط
5. ❌ **لا تستخدم أبداً** `TextStyle()` مباشرة
6. ❌ **لا تستخدم أبداً** `Color(0xFF...)` مباشرة

---

**تم إنشاؤه بواسطة:** Claude Code
**التاريخ:** نوفمبر 2025
**الإصدار:** 1.0
