# 🎨 Unified Color System Guide

## نظام الألوان الموحد

نظام موحد وذكي للألوان يدعم Light/Dark Mode تلقائياً بدون الحاجة للتحقق اليدوي من الثيم.

---

## ✨ المميزات

✅ **مصدر واحد للحقيقة** - جميع الألوان في مكان واحد
✅ **دعم تلقائي للـ Dark Mode** - بدون كود إضافي
✅ **سهولة الصيانة** - تغيير لون واحد يؤثر على كل التطبيق
✅ **Type-safe** - IntelliSense يساعدك في كتابة الكود
✅ **أداء عالي** - بدون overhead إضافي

---

## 📖 كيفية الاستخدام

### الطريقة القديمة ❌ (لا تستخدمها)

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? AppColors.darkCard : AppColors.white,  // ❌ معقد
      child: Text(
        'Hello',
        style: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,  // ❌ طويل
        ),
      ),
    );
  }
}
```

### الطريقة الجديدة ✅ (استخدم هذه)

```dart
import '../../../core/styles/app_colors_extension.dart';  // أضف هذا

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.cardColor,  // ✅ بسيط وتلقائي!
      child: Text(
        'Hello',
        style: TextStyle(
          color: context.colors.textPrimary,  // ✅ واضح ومباشر!
        ),
      ),
    );
  }
}
```

---

## 🎯 الألوان المتاحة

### 1. Background Colors (ألوان الخلفيات)

```dart
context.colors.background           // الخلفية الرئيسية
context.colors.backgroundLight      // خلفية فاتحة
context.colors.backgroundAlt        // خلفية بديلة
context.colors.surface              // سطح
context.colors.surfaceVariant       // نسخة بديلة للسطح
```

**مثال:**
```dart
Scaffold(
  backgroundColor: context.colors.background,  // ✅
  body: Container(
    color: context.colors.surface,  // ✅
  ),
)
```

---

### 2. Card Colors (ألوان الكروت)

```dart
context.colors.cardColor            // لون الكارت العادي
context.colors.cardElevated         // كارت بارز (مرفوع)
```

**مثال:**
```dart
Card(
  color: context.colors.cardColor,  // ✅
  child: Container(
    decoration: BoxDecoration(
      color: context.colors.cardElevated,  // للكروت المحددة
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)
```

---

### 3. Text Colors (ألوان النصوص)

```dart
context.colors.textPrimary          // نص أساسي
context.colors.textSecondary        // نص ثانوي
context.colors.textTertiary         // نص ثالثي
context.colors.textDisabled         // نص معطل
context.colors.textOnPrimary        // نص على اللون الأساسي
context.colors.textOnDark           // نص على خلفية داكنة
```

**مثال:**
```dart
Text(
  'عنوان رئيسي',
  style: TextStyle(
    color: context.colors.textPrimary,  // ✅
    fontSize: 24,
    fontWeight: FontWeight.bold,
  ),
),
Text(
  'وصف ثانوي',
  style: TextStyle(
    color: context.colors.textSecondary,  // ✅
    fontSize: 14,
  ),
),
```

---

### 4. Icon Colors (ألوان الأيقونات)

```dart
context.colors.iconPrimary          // أيقونة أساسية
context.colors.iconSecondary        // أيقونة ثانوية
context.colors.iconTertiary         // أيقونة ثالثية
context.colors.iconOnDark           // أيقونة على خلفية داكنة
```

**مثال:**
```dart
Icon(
  Icons.home,
  color: context.colors.iconPrimary,  // ✅
),
IconButton(
  icon: Icon(Icons.settings),
  color: context.colors.iconSecondary,  // ✅
  onPressed: () {},
),
```

---

### 5. Border & Divider Colors (حدود وفواصل)

```dart
context.colors.border               // حدود عادية
context.colors.borderLight          // حدود فاتحة
context.colors.borderMedium         // حدود متوسطة
context.colors.divider              // فاصل
context.colors.dividerLight         // فاصل فاتح
```

**مثال:**
```dart
Container(
  decoration: BoxDecoration(
    color: context.colors.cardColor,
    border: Border.all(
      color: context.colors.border,  // ✅
    ),
    borderRadius: BorderRadius.circular(12),
  ),
),
Divider(color: context.colors.divider),  // ✅
```

---

### 6. Input/Field Colors (حقول الإدخال)

```dart
context.colors.fieldBackground      // خلفية الحقل
context.colors.fieldBorder          // حدود الحقل
context.colors.fieldBorderFocused   // حدود الحقل عند التركيز
```

**مثال:**
```dart
TextField(
  decoration: InputDecoration(
    filled: true,
    fillColor: context.colors.fieldBackground,  // ✅
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: context.colors.fieldBorder,  // ✅
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: context.colors.fieldBorderFocused,  // ✅
      ),
    ),
  ),
),
```

---

### 7. Brand Colors (ألوان العلامة التجارية)

```dart
context.colors.primary              // اللون الأساسي
context.colors.primaryLight         // أساسي فاتح
context.colors.primaryDark          // أساسي داكن
context.colors.accent               // لون مميز
context.colors.accentLight          // مميز فاتح
context.colors.accentDark           // مميز داكن
```

**مثال:**
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: context.colors.primary,  // ✅
  ),
  onPressed: () {},
  child: Text('اضغط هنا'),
),
```

---

### 8. Semantic Colors (ألوان دلالية)

```dart
context.colors.success              // نجاح
context.colors.successLight         // نجاح فاتح
context.colors.successDark          // نجاح داكن
context.colors.error                // خطأ
context.colors.errorLight           // خطأ فاتح
context.colors.errorDark            // خطأ داكن
context.colors.warning              // تحذير
context.colors.warningLight         // تحذير فاتح
context.colors.warningDark          // تحذير داكن
context.colors.info                 // معلومات
context.colors.infoLight            // معلومات فاتحة
```

**مثال:**
```dart
SnackBar(
  content: Text('تم الحفظ بنجاح'),
  backgroundColor: context.colors.success,  // ✅
),
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: context.colors.errorLight,
    borderRadius: BorderRadius.circular(8),
  ),
  child: Row(
    children: [
      Icon(Icons.error, color: context.colors.error),  // ✅
      SizedBox(width: 8),
      Text('حدث خطأ', style: TextStyle(color: context.colors.error)),
    ],
  ),
),
```

---

### 9. Navigation Colors (ألوان التنقل)

```dart
context.colors.appBarBackground     // خلفية AppBar
context.colors.navBarBackground     // خلفية شريط التنقل
context.colors.navBarSelected       // عنصر محدد
context.colors.navBarUnselected     // عنصر غير محدد
```

**مثال:**
```dart
AppBar(
  backgroundColor: context.colors.appBarBackground,  // ✅
),
BottomNavigationBar(
  backgroundColor: context.colors.navBarBackground,  // ✅
  selectedItemColor: context.colors.navBarSelected,  // ✅
  unselectedItemColor: context.colors.navBarUnselected,  // ✅
),
```

---

### 10. Shadow & Overlay Colors (ظلال وطبقات)

```dart
context.colors.shadow               // ظل عادي
context.colors.shadowLight          // ظل خفيف
context.colors.shadowMedium         // ظل متوسط
context.colors.overlay              // طبقة
context.colors.overlayLight         // طبقة خفيفة
```

**مثال:**
```dart
Container(
  decoration: BoxDecoration(
    color: context.colors.cardColor,
    borderRadius: BorderRadius.circular(16),
    boxShadow: context.isDarkMode ? [] : [  // لا ظلال في الوضع الداكن
      BoxShadow(
        color: context.colors.shadow,  // ✅
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  ),
),
```

---

## 🔍 Helper Methods

### تحقق من الوضع الحالي

```dart
if (context.isDarkMode) {
  // الوضع الداكن نشط
  print('Dark Mode is ON');
} else {
  // الوضع الفاتح نشط
  print('Light Mode is ON');
}
```

---

## 📋 قواعد الاستخدام

### ✅ افعل

1. **استخدم `context.colors` دائماً** بدلاً من `AppColors` المباشرة
2. **استورد الـ extension** في كل ملف:
   ```dart
   import '../../../core/styles/app_colors_extension.dart';
   ```
3. **استخدم أسماء دلالية** مثل `textPrimary` بدلاً من `white` أو `black`

### ❌ لا تفعل

1. **لا تستخدم ألوان ثابتة** مثل:
   ```dart
   Color(0xFFFFFFFF)  // ❌
   Colors.white       // ❌
   AppColors.white    // ❌ (إلا للألوان الثابتة فقط)
   ```

2. **لا تكتب منطق للتحقق من الثيم يدوياً**:
   ```dart
   final isDark = Theme.of(context).brightness == Brightness.dark;
   final color = isDark ? darkColor : lightColor;  // ❌
   ```

3. **لا تخزن الألوان في متغيرات**:
   ```dart
   final cardColor = context.colors.cardColor;  // ❌ قد يتغير الثيم
   // بدلاً من ذلك استخدم context.colors.cardColor مباشرة
   ```

---

## 🔄 مثال كامل للتحويل

### قبل التحديث ❌

```dart
class ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'أحمد محمد',
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'مطور تطبيقات',
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
```

### بعد التحديث ✅

```dart
import '../../../core/styles/app_colors_extension.dart';  // أضف هذا

class ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.cardColor,  // ✅ بسيط!
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.border,  // ✅ تلقائي!
        ),
        boxShadow: context.isDarkMode ? [] : [
          BoxShadow(
            color: context.colors.shadow,  // ✅ واضح!
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'أحمد محمد',
            style: TextStyle(
              color: context.colors.textPrimary,  // ✅ سهل القراءة!
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'مطور تطبيقات',
            style: TextStyle(
              color: context.colors.textSecondary,  // ✅ مفهوم!
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
```

**الفرق:**
- 🔴 **قبل**: 20 سطر مع 4 تحققات يدوية من الثيم
- 🟢 **بعد**: 15 سطر فقط، بدون أي تحققات يدوية!
- ⚡ **أسرع في الكتابة**
- 🧹 **أنظف في القراءة**
- 🛠️ **أسهل في الصيانة**

---

## 🚀 الخطوات التالية

1. ✅ أضف `import '../../../core/styles/app_colors_extension.dart';` في ملفاتك
2. ✅ استبدل جميع `AppColors.white` بـ `context.colors.cardColor`
3. ✅ استبدل جميع `AppColors.darkCard` بـ `context.colors.cardColor`
4. ✅ استبدل جميع التحققات اليدوية بـ `context.colors.*`
5. ✅ استخدم `context.isDarkMode` للتحققات الشرطية إذا لزم الأمر

---

## 💡 نصائح

- استخدم **IntelliSense** (Ctrl+Space) لرؤية جميع الألوان المتاحة
- جميع الألوان **type-safe** - الأخطاء ستظهر أثناء الكتابة
- النظام **reactive** - يتغير تلقائياً عند تغيير الثيم
- لا تحتاج `setState` أو `rebuild` يدوي

---

## 📞 للمساعدة

إذا كان عندك سؤال أو مشكلة:
1. راجع الأمثلة أعلاه
2. استخدم IntelliSense لرؤية الألوان المتاحة
3. اسأل الفريق إذا احتجت مساعدة

---

**تم إنشاؤه بواسطة**: Claude Code
**التاريخ**: 2025-11-12
**الإصدار**: 1.0
