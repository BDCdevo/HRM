# 🧪 دليل اختبار ميزة سبب التأخير - خطوة بخطوة

## 📋 الإعداد قبل الاختبار

### 1️⃣ تأكد من تشغيل الباك اند

```bash
cd D:\php_project\filament-hrm
php artisan serve
```

**يجب أن ترى:**
```
Starting Laravel development server: http://127.0.0.1:8000
```

---

### 2️⃣ تأكد من أن الموظف لديه Work Plan

**طريقة 1: من خلال Filament Admin Panel**
1. افتح: http://127.0.0.1:8000/admin
2. سجل دخول كـ Admin
3. اذهب إلى: HR Management > Work Plans
4. افتح "plan1" (أو أي خطة)
5. تأكد من:
   - ✅ Start Time: **10:00 AM** (أو 10:00:00)
   - ✅ End Time: **06:00 PM** (أو 18:00:00)
   - ✅ الموظف "Hany" مُضاف في "Assign Employees"

**طريقة 2: من خلال Tinker**
```bash
php artisan tinker
```

```php
// ابحث عن الموظف
$user = \App\Models\User::where('email', 'mohamed@bdc.com')->first();

// تحقق من Work Plan
if ($user && $user->employee) {
    $workPlan = $user->employee->workPlan;

    if ($workPlan) {
        echo "✅ Work Plan Found!\n";
        echo "Name: " . $workPlan->name . "\n";
        echo "Start Time: " . $workPlan->start_time . "\n";
        echo "End Time: " . $workPlan->end_time . "\n";
    } else {
        echo "❌ No Work Plan assigned to this employee!\n";
        echo "Please assign a work plan from admin panel.\n";
    }
} else {
    echo "❌ Employee not found!\n";
}
```

**إذا لم يكن هناك Work Plan:**
```php
// ابحث عن أول work plan
$workPlan = \App\Models\WorkPlan::first();

// اربط الموظف بالـ Work Plan
if ($user && $user->employee && $workPlan) {
    $user->employee->work_plan_id = $workPlan->id;
    $user->employee->save();
    echo "✅ Work Plan assigned successfully!\n";
}
```

---

## 🧪 خطوات الاختبار

### Test 1: تسجيل حضور في الوقت المحدد ✅

**الهدف:** التأكد أن Bottom Sheet **لا يظهر** إذا كان الموظف في الوقت

**الخطوات:**
1. افتح التطبيق: `flutter run`
2. سجل دخول بحساب: `mohamed@bdc.com`
3. تأكد أن الوقت الحالي **قبل** 10:00 صباحاً
   - مثلاً: 09:30 صباحاً
4. اذهب إلى تبويب "Attendance"
5. اضغط "Check In"

**النتيجة المتوقعة:**
```
✅ يطلب GPS Location
✅ يتم تسجيل الحضور مباشرة
❌ Bottom Sheet لا يظهر
```

**Logs المتوقعة في Flutter Console:**
```
⏰ ========== Late Detection Check ==========
⏰ Raw Start Time from API: "10:00:00"
⏰ Current Time: 09:30:45
⏰ Is Late: false
⏰ Employee is NOT late - proceeding with normal check-in
```

---

### Test 2: تسجيل حضور متأخر (السيناريو الأهم!) 🔥

**الهدف:** التأكد أن Bottom Sheet **يظهر** إذا كان الموظف متأخر

**الخطوات:**
1. **انتظر** حتى الساعة تصبح **بعد** 10:00 صباحاً
   - مثلاً: 10:15 صباحاً، أو 11:00 صباحاً
2. افتح التطبيق (أو اعمل Hot Restart إذا كان مفتوح)
3. سجل دخول (إذا لم تكن مسجل)
4. اذهب إلى "Attendance"
5. اضغط "Check In"

**النتيجة المتوقعة:**
```
✅ يطلب GPS Location
✅ Bottom Sheet يظهر مع قائمة الأسباب
✅ يمكن اختيار سبب أو كتابة سبب مخصص
✅ عند الضغط "Submit & Check In" يتم التسجيل
✅ عند الضغط "Cancel" يتم إلغاء التسجيل
```

**Logs المتوقعة:**
```
🔍 ========== DEBUG: Checking if late ==========
🔍 _lastStatus is null? false
🔍 Work Plan exists? true
🔍 Work Plan Name: plan1
🔍 Work Plan Start Time: 10:00:00
🔍 Work Plan End Time: 18:00:00
🔍 ==========================================

⏰ ========== Late Detection Check ==========
⏰ Raw Start Time from API: "10:00:00"
⏰ Current Time: 10:15:30
⏰ Parsed as 24-hour format: 10:00
⏰ Work Start Time (parsed): 10:00 AM
⏰ Current Time: 10:15 AM
⏰ Is Late: true
⏰ Minutes Late: 15 minutes
⏰ ========================================

⏰ Is employee late? true
⏰ Showing late reason bottom sheet...
```

**عند اختيار سبب (مثلاً "Traffic"):**
```
⏰ Late reason from bottom sheet: Traffic
🚀 Calling checkIn with location and late reason...
⏰ Cubit - Late Reason: Traffic
📦 Request data: {latitude: 30.0444, longitude: 31.2357, late_reason: Traffic}
✅ Check-in Response: {...}
```

---

### Test 3: إلغاء تسجيل الحضور ❌

**الهدف:** التأكد أن الموظف يمكنه إلغاء التسجيل

**الخطوات:**
1. كن متأخراً (بعد 10:00 صباحاً)
2. اضغط "Check In"
3. Bottom Sheet يظهر
4. اضغط "Cancel" أو اسحب الـ Sheet لأسفل

**النتيجة المتوقعة:**
```
✅ Bottom Sheet يُغلق
✅ لا يتم تسجيل الحضور
✅ تبقى في نفس الشاشة
```

**Logs المتوقعة:**
```
⏰ Late reason from bottom sheet: null
⚠️ User cancelled late reason input
```

---

## 🔍 تشخيص المشاكل

### مشكلة: Bottom Sheet لا يظهر رغم أنني متأخر

**احتمال 1: Work Plan غير موجود**

ابحث في Logs عن:
```
⏰ No status or work plan found - cannot determine if late
```
أو
```
🔍 Work Plan exists? false
```

**الحل:** راجع الخطوة 2️⃣ في الأعلى وتأكد من ربط Work Plan بالموظف

---

**احتمال 2: Start Time غير موجود في Work Plan**

ابحث في Logs عن:
```
⏰ No start time in work plan - cannot determine if late
```

**الحل:** تأكد من أن Work Plan لديه `start_time` في قاعدة البيانات

---

**احتمال 3: صيغة الوقت غير صحيحة**

ابحث في Logs عن:
```
❌ Could not parse work start time
```

**الحل:** تأكد أن `start_time` في قاعدة البيانات بأحد الصيغ:
- `10:00:00` (24-hour)
- `10:00 AM` (12-hour)

---

**احتمال 4: أنت فعلاً في الوقت المحدد!**

ابحث في Logs عن:
```
⏰ Is Late: false
```

تحقق من:
- الوقت الحالي على جهازك
- `start_time` في Work Plan
- هل الوقت الحالي **بعد** start_time فعلاً؟

---

## 📱 خطوات الاختبار السريع (TL;DR)

```bash
# 1. شغل الباك اند
cd D:\php_project\filament-hrm && php artisan serve

# 2. في terminal آخر، شغل التطبيق
cd C:\Users\B-SMART\AndroidStudioProjects\hrm
flutter run

# 3. تأكد من Work Plan
# اذهب للـ admin panel أو استخدم tinker

# 4. انتظر حتى بعد 10:00 صباحاً

# 5. في التطبيق:
#    - سجل دخول
#    - Attendance Tab
#    - اضغط Check In
#    - 🎉 شاهد Bottom Sheet يظهر!
```

---

## 🐛 Debug Mode: إذا لم تعمل

### أضف هذا في الكود مؤقتاً للاختبار:

في `attendance_check_in_widget.dart` في method `_checkIfLate`:

```dart
// أضف هذا في بداية الـ method لإجبار النظام على اعتبار الموظف متأخر
bool _checkIfLate(AttendanceStatusModel? status) {
  // ⚠️ DEBUG ONLY - Remove in production
  return true; // <--- Force late detection

  // باقي الكود...
}
```

**بعد هذا التعديل:**
- Bottom Sheet سيظهر **دائماً** عند Check-in
- استخدم هذا فقط للاختبار
- **احذف السطر** بعد التأكد من أن Bottom Sheet يعمل

---

## ✅ Checklist

قبل الاختبار، تأكد من:

- [ ] الباك اند يعمل (`php artisan serve`)
- [ ] التطبيق يعمل (`flutter run`)
- [ ] الموظف لديه Work Plan مُعيّن
- [ ] Work Plan لديه `start_time`
- [ ] `start_time` بصيغة صحيحة (10:00:00 أو 10:00 AM)
- [ ] الوقت الحالي **بعد** `start_time` (للاختبار Late)
- [ ] Flutter Console مفتوح لرؤية الـ Logs

---

## 🎯 الخلاصة

الميزة تعمل بشكل صحيح إذا رأيت:

```
⏰ Is Late: true
⏰ Showing late reason bottom sheet...
```

وبعدها Bottom Sheet يظهر على الشاشة! 🎉
