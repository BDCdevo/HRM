# Services Grid Widget - Documentation

## 📋 Overview

تم إضافة **Services Grid Widget** إلى Dashboard Screen يعرض أيقونات الخدمات بنفس التصميم الموضح في الصورة.

## 🎨 Design Features

### التصميم:
- ✅ Grid من 2 أعمدة × 3 صفوف (6 خدمات إجمالاً)
- ✅ كل كارد منفصل بخلفية بيضاء وظل خفيف
- ✅ أيقونة داخل دائرة ملونة
- ✅ نص تحت الأيقونة
- ✅ تأثير Ripple عند الضغط

### الخدمات المتاحة:

1. **Attendance** 📅
   - اللون: أخضر (#4CAF50)
   - الأيقونة: `Icons.calendar_today`
   - الوظيفة: يفتح شاشة الحضور

2. **Track Leave** 🏖️
   - اللون: برتقالي (#FF9800)
   - الأيقونة: `Icons.beach_access` (مع دوران خفيف -0.3)
   - الوظيفة: يفتح شاشة الإجازات

3. **Claims** 📄
   - اللون: برتقالي فاتح (#FFA726)
   - الأيقونة: `Icons.article_outlined`
   - الوظيفة: قريباً (Coming Soon)

4. **Notice Board** 🔔
   - اللون: أزرق (#2196F3)
   - الأيقونة: `Icons.notifications_outlined`
   - الوظيفة: قريباً (Coming Soon)

5. **Holidays** ☂️
   - اللون: بنفسجي (#9C27B0)
   - الأيقونة: `Icons.umbrella_outlined`
   - الوظيفة: قريباً (Coming Soon)

6. **Reports** 📊
   - اللون: سماوي (#00BCD4)
   - الأيقونة: `Icons.bar_chart`
   - الوظيفة: يفتح شاشة التقارير

## 📁 الملفات المُضافة/المُعدّلة

### 1. ملف جديد: `services_grid_widget.dart`
**الموقع:** `lib/features/dashboard/ui/widgets/services_grid_widget.dart`

```dart
class ServicesGridWidget extends StatelessWidget {
  // Widget رئيسي يعرض Grid الخدمات
}

class _ServiceCard extends StatelessWidget {
  // Widget للكارد الواحد (قابل لإعادة الاستخدام)
}
```

### 2. ملف مُعدّل: `dashboard_screen.dart`
**التعديلات:**
- إضافة import للـ `services_grid_widget.dart`
- إضافة `const ServicesGridWidget()` بعد Today's Attendance Card

```dart
// Today's Attendance Stats Card
TodayAttendanceStatsCard(...),

const SizedBox(height: 24),

// Services Grid - NEW!
const ServicesGridWidget(),

const SizedBox(height: 24),

// Overview Stats
_buildOverviewSection(stats, constraints),
```

## 🔧 كيفية الاستخدام

### لإضافة خدمة جديدة:

1. افتح `services_grid_widget.dart`
2. أضف `_ServiceCard` جديد في الـ Grid
3. حدد الأيقونة واللون والـ `onTap` handler

**مثال:**
```dart
_ServiceCard(
  icon: Icons.payment,  // أيقونة جديدة
  label: 'Payroll',     // اسم الخدمة
  color: const Color(0xFFE91E63), // اللون (Pink)
  onTap: () {
    // Navigation logic
    Navigator.pushNamed(context, '/payroll');
  },
),
```

### لتغيير لون خدمة:

```dart
_ServiceCard(
  icon: Icons.umbrella_outlined,
  label: 'Holidays',
  color: const Color(0xFF9C27B0), // ⬅️ غير هذا
  onTap: () { ... },
),
```

### لتدوير أيقونة:

```dart
_ServiceCard(
  icon: Icons.beach_access,
  label: 'Track Leave',
  color: const Color(0xFFFF9800),
  iconRotation: -0.3, // ⬅️ دوران بزاوية (راديان)
  onTap: () { ... },
),
```

## 🎯 الوظائف المُفعّلة

| الخدمة | الحالة | Route |
|--------|--------|-------|
| Attendance | ✅ مُفعّل | `/attendance` |
| Track Leave | ✅ مُفعّل | `/leaves` |
| Claims | ⏳ قريباً | - |
| Notice Board | ⏳ قريباً | - |
| Holidays | ⏳ قريباً | - |
| Reports | ✅ مُفعّل | `/reports` |

**الخدمات "قريباً"** تعرض SnackBar عند الضغط عليها:
```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text('Notice Board feature coming soon!'),
  ),
);
```

## 🎨 التخصيص

### تغيير عدد الأعمدة:

حالياً الـ Grid يستخدم `Row` و `Column`. لتغيير التخطيط إلى 3 أعمدة:

```dart
Row(
  children: [
    Expanded(child: _ServiceCard(...)),
    const SizedBox(width: 12),
    Expanded(child: _ServiceCard(...)),
    const SizedBox(width: 12),
    Expanded(child: _ServiceCard(...)), // العمود الثالث
  ],
),
```

### تغيير حجم الأيقونة:

في `_ServiceCard` class:

```dart
Container(
  width: 52,  // ⬅️ حجم الدائرة
  height: 52,
  child: Icon(
    icon,
    color: color,
    size: 26, // ⬅️ حجم الأيقونة
  ),
),
```

### تغيير الظل:

```dart
boxShadow: [
  BoxShadow(
    color: Colors.black.withOpacity(0.06), // ⬅️ شفافية الظل
    blurRadius: 8,  // ⬅️ مدى الـ blur
    offset: const Offset(0, 2), // ⬅️ اتجاه الظل
  ),
],
```

## 📱 اختبار الميزة

```bash
# 1. شغل التطبيق
cd C:\Users\B-SMART\AndroidStudioProjects\hrm
flutter run

# 2. سجل دخول

# 3. انظر إلى Dashboard
#    ستجد Services Grid تحت Today's Attendance Card

# 4. اضغط على أي كارد
#    - Attendance: يفتح شاشة الحضور
#    - Track Leave: يفتح شاشة الإجازات
#    - Reports: يفتح شاشة التقارير
#    - الباقي: يعرض "Coming Soon"
```

## 🚀 التحسينات المستقبلية

### اقتراحات:
1. **Dynamic Services**: تحميل الخدمات من الـ API بناءً على صلاحيات الموظف
2. **Badge Counts**: عرض أرقام (مثل عدد الإشعارات) على الكروت
3. **Animations**: إضافة animations عند الضغط
4. **More Services**: إضافة خدمات جديدة (Payroll, Documents, etc.)

### مثال Badge Count:

```dart
Stack(
  children: [
    _ServiceCard(...),
    // Badge
    Positioned(
      right: 8,
      top: 8,
      child: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: Text(
          '5', // عدد الإشعارات
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  ],
)
```

## ✅ Checklist

تأكد من:
- [x] Services Grid يظهر في Dashboard
- [x] كل كارد لديه أيقونة ولون مختلف
- [x] Attendance و Track Leave و Reports يعملون
- [x] الكروت الأخرى تعرض "Coming Soon"
- [x] التصميم يطابق الصورة المرجعية
- [x] Ripple effect يعمل عند الضغط

---

🎉 **تم بنجاح!** Services Grid جاهز للاستخدام!
