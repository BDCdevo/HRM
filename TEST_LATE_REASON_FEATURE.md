# اختبار ميزة سبب التأخير (Late Reason Feature)

## ✅ الخطوات للتأكد من أن الميزة تعمل بشكل صحيح

### 1️⃣ التحقق من Work Plan في الباك اند

تأكد أن الموظف لديه Work Plan مع Start Time:

```bash
cd D:\php_project\filament-hrm
php artisan tinker
```

```php
$user = \App\Models\User::where('email', 'mohamed@bdc.com')->first();
if ($user && $user->employee) {
    $employee = $user->employee;
    $workPlan = $employee->workPlan;

    if ($workPlan) {
        echo "Work Plan Name: " . $workPlan->name . "\n";
        echo "Start Time: " . $workPlan->start_time . "\n";
        echo "End Time: " . $workPlan->end_time . "\n";
    } else {
        echo "No work plan assigned!\n";
    }
}
```

**مثال على النتيجة المتوقعة:**
```
Work Plan Name: plan1
Start Time: 10:00:00
End Time: 18:00:00
```

---

### 2️⃣ سيناريوهات الاختبار

#### ✅ سيناريو 1: موظف يسجل حضور في الوقت المحدد (On Time)

**الشروط:**
- Work Plan Start Time: `10:00 AM`
- وقت تسجيل الحضور: `09:30 AM` (قبل الموعد)

**النتيجة المتوقعة:**
- ❌ Bottom Sheet **لا يظهر**
- ✅ يتم تسجيل الحضور مباشرة
- ✅ لا يتم إرسال `late_reason` للباك اند

---

#### ✅ سيناريو 2: موظف يسجل حضور متأخر (Late)

**الشروط:**
- Work Plan Start Time: `10:00 AM`
- وقت تسجيل الحضور: `10:30 AM` (بعد الموعد بـ 30 دقيقة)

**النتيجة المتوقعة:**
1. ✅ Bottom Sheet **يظهر** تلقائياً
2. ✅ الموظف يختار سبب التأخير (مثل: "Traffic")
3. ✅ يضغط "Submit & Check In"
4. ✅ يتم إرسال `late_reason` مع طلب الـ API
5. ✅ يتم تسجيل الحضور بنجاح

**Logs المتوقعة في Flutter Console:**
```
⏰ ========== Late Detection Check ==========
⏰ Raw Start Time from API: "10:00:00"
⏰ Current Time: 10:30:45
⏰ Parsed as 24-hour format: 10:00
⏰ Work Start Time (parsed): 10:00 AM
⏰ Current Time: 10:30 AM
⏰ Is Late: true
⏰ Minutes Late: 30 minutes
⏰ ========================================
⏰ Is employee late? true
⏰ Showing late reason bottom sheet...
⏰ Late reason from bottom sheet: Traffic
🚀 Calling checkIn with location and late reason...
⏰ Cubit - Late Reason: Traffic
📦 Request data: {latitude: 30.0444, longitude: 31.2357, late_reason: Traffic}
```

---

#### ✅ سيناريو 3: موظف يلغي إدخال سبب التأخير (Cancel)

**الشروط:**
- Work Plan Start Time: `10:00 AM`
- وقت تسجيل الحضور: `10:30 AM` (متأخر)
- الموظف يضغط "Cancel" في Bottom Sheet

**النتيجة المتوقعة:**
1. ✅ Bottom Sheet يظهر
2. ✅ الموظف يضغط "Cancel"
3. ✅ Bottom Sheet يُغلق
4. ❌ **لا يتم** تسجيل الحضور
5. ✅ الموظف يبقى في نفس الشاشة

**Logs المتوقعة:**
```
⏰ Is Late: true
⏰ Showing late reason bottom sheet...
⏰ Late reason from bottom sheet: null
⚠️ User cancelled late reason input
```

---

### 3️⃣ التحقق من الباك اند

تأكد أن الباك اند يستقبل `late_reason`:

في ملف `app/Http/Controllers/Api/V1/Employee/AttendanceController.php`:

```php
public function checkIn(Request $request)
{
    // Log the request to verify late_reason is received
    \Log::info('Check-in Request Data:', $request->all());

    $validated = $request->validate([
        'latitude' => 'nullable|numeric',
        'longitude' => 'nullable|numeric',
        'notes' => 'nullable|string',
        'late_reason' => 'nullable|string', // ⬅️ تأكد من وجود هذا
    ]);

    // Store late_reason in attendance record
    $attendance->late_reason = $validated['late_reason'] ?? null;
    $attendance->save();
}
```

---

### 4️⃣ فحص Console Logs

عند تشغيل التطبيق وتسجيل الحضور، راقب الـ Logs:

**في Flutter Console:**
```bash
flutter run
```

ابحث عن:
- `⏰ ========== Late Detection Check ==========`
- `⏰ Is Late: true`
- `⏰ Showing late reason bottom sheet...`
- `⏰ Late reason from bottom sheet: [السبب المختار]`
- `⏰ Cubit - Late Reason: [السبب المختار]`
- `📦 Request data: {..., late_reason: [السبب المختار]}`

**في Laravel Logs:**
```bash
cd D:\php_project\filament-hrm
tail -f storage/logs/laravel.log
```

ابحث عن:
- `Check-in Request Data`
- تأكد من وجود `late_reason` في البيانات

---

### 5️⃣ اختبار صيغ الوقت المختلفة

الكود يدعم صيغتين:

#### صيغة 24 ساعة:
```json
{
  "start_time": "10:00:00"
}
```

#### صيغة 12 ساعة:
```json
{
  "start_time": "10:00 AM"
}
```

كلا الصيغتين سيعملان بشكل صحيح! ✅

---

### 6️⃣ حالات الـ Edge Cases

| الحالة | النتيجة |
|--------|---------|
| لا يوجد Work Plan للموظف | لا يظهر Bottom Sheet، يتم التسجيل مباشرة |
| Work Plan بدون Start Time | لا يظهر Bottom Sheet، يتم التسجيل مباشرة |
| الوقت الحالي = Start Time بالضبط | لا يظهر Bottom Sheet (ليس متأخر) |
| الوقت الحالي > Start Time بدقيقة واحدة | يظهر Bottom Sheet (متأخر!) |

---

## 🎯 ملخص سريع

### الميزة تعمل إذا:
✅ Bottom Sheet يظهر **فقط** عندما يكون الموظف متأخر
✅ الموظف يستطيع اختيار سبب من القائمة أو كتابة سبب مخصص
✅ الموظف يستطيع إلغاء التسجيل بالضغط على "Cancel"
✅ `late_reason` يُرسل للباك اند في طلب الـ API
✅ Logs واضحة وتوضح كل خطوة

---

## 🔧 إذا لم تعمل الميزة

### المشكلة: Bottom Sheet لا يظهر رغم أن الموظف متأخر

**الحل:**
1. تأكد من أن الموظف لديه Work Plan
2. تأكد من أن Start Time موجود في Work Plan
3. تحقق من الـ Logs في Flutter Console
4. تأكد من أن `_lastStatus` ليس `null`

### المشكلة: Late Reason لا يصل للباك اند

**الحل:**
1. تحقق من Logs في Flutter: `⏰ Cubit - Late Reason:`
2. تحقق من Request Data: `📦 Request data:`
3. تأكد من أن الباك اند يقبل `late_reason` parameter
4. راجع Laravel logs

---

## 📝 ملاحظات مهمة

1. **Grace Period (فترة السماح):**
   - حالياً، إذا كان الموظف متأخر حتى دقيقة واحدة، سيظهر Bottom Sheet
   - إذا أردت إضافة فترة سماح (مثل 15 دقيقة)، يمكن تعديل الكود

2. **تنسيق الوقت:**
   - الكود يدعم كلا الصيغتين: 12-hour و 24-hour
   - يتم تحديد الصيغة تلقائياً بناءً على وجود "AM" أو "PM"

3. **البيانات المحفوظة:**
   - `late_reason`: سبب التأخير (نص)
   - `late_minutes`: عدد دقائق التأخير (يأتي من الباك اند)

---

## 🚀 ابدأ الاختبار الآن!

```bash
# 1. شغل الباك اند
cd D:\php_project\filament-hrm
php artisan serve

# 2. شغل التطبيق
cd C:\Users\B-SMART\AndroidStudioProjects\hrm
flutter run

# 3. سجل دخول بحساب mohamed@bdc.com
# 4. انتظر حتى بعد الساعة 10:00 صباحاً
# 5. اضغط "Check In"
# 6. شاهد Bottom Sheet يظهر! 🎉
```
