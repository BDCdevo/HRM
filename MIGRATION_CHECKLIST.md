# 🔄 Migration Checklist - Unified Color System

## ملفات تحتاج تحديث (15 ملف)

تم فحص جميع الملفات في التطبيق ووجدنا **15 ملف** يستخدمون طرق قديمة للألوان.

---

## 📋 قائمة الملفات

### ✅ مكتمل (1)
- [x] `lib/features/settings/ui/screens/settings_screen.dart` - تم التحديث

### 🔄 جاري العمل عليها (0)

### ⏳ في الانتظار (15)

#### Dashboard Files (4)
- [ ] `lib/features/dashboard/ui/screens/dashboard_screen.dart`
- [ ] `lib/features/dashboard/ui/widgets/services_grid_widget.dart`
- [ ] `lib/features/dashboard/ui/widgets/today_attendance_stats_card.dart`
- [ ] `lib/features/dashboard/ui/widgets/check_in_counter_card.dart`

#### Leaves Files (4)
- [ ] `lib/features/leaves/ui/screens/leaves_main_screen.dart` - تم تحديث جزئي
- [ ] `lib/features/leaves/ui/widgets/leaves_apply_widget.dart` - تم تحديث جزئي
- [ ] `lib/features/leaves/ui/widgets/leaves_balance_widget.dart`
- [ ] `lib/features/leaves/ui/widgets/leaves_history_widget.dart`

#### Attendance Files (5)
- [ ] `lib/features/attendance/ui/screens/attendance_main_screen.dart`
- [ ] `lib/features/attendance/ui/screens/attendance_summary_screen.dart`
- [ ] `lib/features/attendance/ui/widgets/attendance_check_in_widget.dart`
- [ ] `lib/features/attendance/ui/widgets/attendance_history_widget.dart`
- [ ] `lib/features/attendance/ui/widgets/sessions_list_widget.dart`

#### Other Files (2)
- [ ] `lib/features/auth/ui/screens/login_screen.dart`
- [ ] `lib/features/more/ui/screens/more_main_screen.dart`

---

## 🔧 التغييرات المطلوبة

### 1. إضافة Import

```dart
import '../../../../core/styles/app_colors_extension.dart';  // أضف هذا السطر
```

### 2. استبدال التحققات اليدوية

**قبل:**
```dart
final isDark = Theme.of(context).brightness == Brightness.dark;
final cardColor = isDark ? AppColors.darkCard : AppColors.white;
```

**بعد:**
```dart
// احذف السطر الأول واستخدم مباشرة:
final cardColor = context.colors.cardColor;
```

أو استخدم مباشرة في الكود:
```dart
Container(
  color: context.colors.cardColor,  // بدلاً من cardColor
)
```

### 3. جدول التحويل السريع

| القديم | الجديد |
|--------|--------|
| `isDark ? AppColors.darkBackground : AppColors.background` | `context.colors.background` |
| `isDark ? AppColors.darkCard : AppColors.white` | `context.colors.cardColor` |
| `isDark ? AppColors.darkTextPrimary : AppColors.textPrimary` | `context.colors.textPrimary` |
| `isDark ? AppColors.darkTextSecondary : AppColors.textSecondary` | `context.colors.textSecondary` |
| `isDark ? AppColors.darkIcon : AppColors.iconPrimary` | `context.colors.iconPrimary` |
| `isDark ? AppColors.darkBorder : AppColors.border` | `context.colors.border` |
| `isDark ? AppColors.darkDivider : AppColors.divider` | `context.colors.divider` |
| `isDark ? AppColors.darkAppBar : AppColors.primary` | `context.colors.appBarBackground` |
| `isDark ? AppColors.darkInput : AppColors.fieldBackground` | `context.colors.fieldBackground` |

### 4. الظلال (Shadows)

**قبل:**
```dart
boxShadow: isDark ? [] : [
  BoxShadow(
    color: AppColors.shadow,
    blurRadius: 10,
  ),
],
```

**بعد:**
```dart
boxShadow: context.isDarkMode ? [] : [
  BoxShadow(
    color: context.colors.shadow,
    blurRadius: 10,
  ),
],
```

---

## 🚀 خطوات التنفيذ

### لكل ملف:

1. **افتح الملف**
2. **أضف import** للـ extension في بداية الملف:
   ```dart
   import '../../../../core/styles/app_colors_extension.dart';
   ```

3. **ابحث عن** `final isDark = Theme.of(context).brightness == Brightness.dark;`

4. **احذف** السطر إذا كان يُستخدم فقط للألوان

5. **استبدل** جميع استخدامات `isDark ? AppColors.dark... : AppColors....` بـ `context.colors....`

6. **استخدم** `context.isDarkMode` فقط للحالات الشرطية (مثل الظلال)

7. **احفظ الملف**

8. **اختبر** الشاشة في Light و Dark Mode

---

## ✅ معايير الاكتمال

- [x] تم إضافة import للـ extension
- [ ] لا توجد تحققات يدوية من `Theme.of(context).brightness`
- [ ] جميع الألوان تستخدم `context.colors.*`
- [ ] تم الاختبار في Light Mode
- [ ] تم الاختبار في Dark Mode
- [ ] لا توجد أخطاء في console

---

## 📊 التقدم

- **المكتمل**: 1 / 16 ملف (6%)
- **المتبقي**: 15 ملف
- **الوقت المقدر**: ~30 دقيقة (2 دقيقة لكل ملف)

---

## 🐛 المشاكل الشائعة

### 1. Import Path خاطئ
❌ `import '../../core/styles/app_colors_extension.dart';`
✅ `import '../../../../core/styles/app_colors_extension.dart';`

**الحل**: عد المجلدات للخلف بشكل صحيح.

### 2. نسيان context
❌ `colors.cardColor`
✅ `context.colors.cardColor`

### 3. استخدام Theme.of بدلاً من context.colors
❌ `Theme.of(context).cardColor`
✅ `context.colors.cardColor`

---

## 📝 ملاحظات

- **لا تحذف** متغير `isDark` إذا كان يُستخدم لغير الألوان (مثل conditional logic)
- **احتفظ بـ** `context.isDarkMode` للحالات الشرطية فقط
- **اختبر** كل شاشة بعد التعديل
- **استخدم hot reload** (اضغط `r` في terminal)

---

## 🎯 الهدف النهائي

```dart
// الكود النهائي يجب أن يبدو هكذا:
import 'package:flutter/material.dart';
import '../../../../core/styles/app_colors_extension.dart';  // ✅

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.cardColor,  // ✅ بسيط وواضح
      child: Text(
        'Hello',
        style: TextStyle(
          color: context.colors.textPrimary,  // ✅ مباشر
        ),
      ),
    );
  }
}
```

---

**تم إنشاؤه**: 2025-11-12
**آخر تحديث**: 2025-11-12
**الحالة**: 🔄 جاري العمل
